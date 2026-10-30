"""Measured object reconstruction: calibrated MVS + confidence-filtered AR depth.

OpenMVS DR layout: upstream v2.4.0 libs/MVS/Interface.h (HeaderDepthDataRaw).
Open3D 0.19 ScalableTSDFVolume integrates metric RGB-D with world-to-camera poses.
Silhouettes constrain measurements; they never generate an unobserved surface.
"""
from dataclasses import dataclass
from pathlib import Path
import math
import struct

import cv2
import numpy as np
import open3d as o3d


class CaptureIncomplete(ValueError):
    def __init__(self, message, missing=None):
        super().__init__(message)
        self.missing = missing or []


@dataclass
class DepthView:
    name: str
    k: np.ndarray
    pose: np.ndarray
    depth: np.ndarray
    mask: np.ndarray
    color: np.ndarray
    sensor: np.ndarray | None = None

    @property
    def center(self):
        return -self.pose[:3, :3].T @ self.pose[:3, 3]


def read_dmap(path):
    """Read only upstream's documented little-endian DR arrays, not an MVS archive."""
    with path.open('rb') as stream:
        def read(size):
            data = stream.read(size)
            if len(data) != size:
                raise ValueError(f'Depth-map truncated: {path.name}')
            return data
        magic, flags, _, iw, ih, w, h, near, far = struct.unpack('<2sBB4I2f', read(28))
        if magic != b'DR' or not flags & 1 or not (1 <= w <= iw <= 8192 and 1 <= h <= ih <= 8192):
            raise ValueError(f'Invalid OpenMVS DR header: {path.name}')
        length, = struct.unpack('<H', read(2))
        name = Path(read(length).decode('utf-8').replace('\\', '/')).name
        count, = struct.unpack('<I', read(4))
        if not 1 <= count <= 255:
            raise ValueError('Invalid depth-map neighbor count')
        read(4 * count)
        k = np.frombuffer(read(72), '<f8').copy().reshape(3, 3)
        rotation = np.frombuffer(read(72), '<f8').copy().reshape(3, 3)
        center = np.frombuffer(read(24), '<f8').copy()
        depth = np.frombuffer(read(w*h*4), '<f4').copy().reshape(h, w)
        if flags & 2:
            read(w*h*12)
        confidence = np.frombuffer(read(w*h*4), '<f4').reshape(h, w) if flags & 4 else None
        if not np.isfinite(k).all() or not np.isfinite(rotation).all() or not np.isfinite(center).all():
            raise ValueError('Non-finite depth-map calibration')
        # K is defined at image resolution in the format; resize only when needed.
        k[0] *= w/iw
        k[1] *= h/ih
        valid = np.isfinite(depth) & (depth > max(0, near)) & (depth <= far)
        if confidence is not None:
            valid &= np.isfinite(confidence) & (confidence > 0)
        depth[~valid] = 0
        pose = np.eye(4)
        pose[:3, :3] = rotation
        pose[:3, 3] = -rotation @ center
        return name, k, pose, depth


def mask_depth(depth, mask, metric_scale):
    """No hole filling; reject silhouette edges and discontinuous depth samples."""
    foreground = cv2.erode(mask.astype(np.uint8), np.ones((3, 3), np.uint8)) > 0
    valid = foreground & np.isfinite(depth) & (depth > 0)
    # Test adjacent valid samples without interpreting missing samples as zero depth.
    tolerance = np.maximum(.003/metric_scale, depth*.015)
    edge = np.zeros(depth.shape, bool)
    for axis in (0, 1):
        delta = np.abs(np.diff(depth, axis=axis))
        if axis == 0:
            bad = (valid[1:] & valid[:-1]) & (delta > np.maximum(tolerance[1:], tolerance[:-1]))
            edge[1:] |= bad
            edge[:-1] |= bad
        else:
            bad = (valid[:, 1:] & valid[:, :-1]) & (delta > np.maximum(tolerance[:, 1:], tolerance[:, :-1]))
            edge[:, 1:] |= bad
            edge[:, :-1] |= bad
    return np.where(valid & ~edge, depth, 0).astype(np.float32)


def sensor_depth(directory, frame, shape, metric_scale):
    """Map raw depth via the recorded CPU-image -> depth affine, not aspect ratios."""
    metadata = frame.get('depth')
    if not metadata:
        return None
    w, h = metadata['width'], metadata['height']
    if not (1 <= w <= 1024 and 1 <= h <= 1024):
        raise ValueError('Invalid sensor depth dimensions')
    stem = Path(frame['name']).stem
    raw = np.frombuffer((directory/'depth'/f'{stem}.u16').read_bytes(), '<u2').reshape(h, w)
    confidence = np.frombuffer((directory/'depth'/f'{stem}.u8').read_bytes(), np.uint8).reshape(h, w)
    affine = np.asarray(metadata['imageToDepth'], dtype=np.float64).reshape(2, 3)
    if not np.isfinite(affine).all() or abs(np.linalg.det(affine[:, :2])) < 1e-6:
        raise ValueError('Invalid depth crop calibration')
    height, width = shape
    yy, xx = np.indices(shape, dtype=np.float32)
    u, v = (xx+.5)/width, (yy+.5)/height
    dx = (affine[0, 0]*u+affine[0, 1]*v+affine[0, 2])*w
    dy = (affine[1, 0]*u+affine[1, 1]*v+affine[1, 2])*h
    valid = (dx >= 0) & (dx < w) & (dy >= 0) & (dy < h)
    x = np.floor(dx).astype(int).clip(0, w-1)
    y = np.floor(dy).astype(int).clip(0, h-1)
    measured = raw[y, x]
    valid &= (confidence[y, x] >= 200) & (measured >= 150) & (measured <= 2000)
    # Nearest-neighbor pixel footprints; never interpolate across depth holes.
    return np.where(valid, measured*.001/metric_scale, 0).astype(np.float32)


def load_depth_views(directory, views, frames, metric_scale):
    by_name = {view['image'].name: view for view in views}
    maps = {}
    for path in sorted((directory/'mvs').glob('depth*.dmap')):
        name, k, pose, depth = read_dmap(path)
        if name in by_name:
            maps[name] = (k, pose, depth)
    result, background = [], []
    for name, view in by_name.items():
        if name in maps:
            k, pose, depth = maps[name]
            # A dmap from an interrupted/older calibration must not enter this run.
            if not np.allclose(pose[:3], view['pose'][:3], rtol=1e-4, atol=1e-5):
                raise ValueError('Depth-map camera differs from current SfM calibration')
        else:
            height, width = view['mask'].shape
            k = view['k'].copy()
            pose = np.eye(4)
            pose[:3] = view['pose'][:3]
            depth = np.zeros((height, width), np.float32)
        h, w = depth.shape
        ratio = min(1., 1024/max(h, w))
        if ratio < 1:
            size = (max(1, round(w*ratio)), max(1, round(h*ratio)))
            resized = cv2.resize(depth, size, interpolation=cv2.INTER_NEAREST)
            k[0] *= size[0]/w
            k[1] *= size[1]/h
            depth = resized
        shape = depth.shape
        mask = cv2.resize(view['mask'], (shape[1], shape[0]), interpolation=cv2.INTER_NEAREST)
        color = cv2.resize(view['color'], (shape[1], shape[0]), interpolation=cv2.INTER_AREA)
        depth = mask_depth(depth, mask, metric_scale)
        sensor = sensor_depth(directory, frames[name], shape, metric_scale)
        observation=DepthView(name, k, pose, depth, mask, color)
        if sensor is not None:
            exterior=np.where(cv2.dilate(mask,np.ones((5,5),np.uint8))==0,sensor,0)
            points=unproject(observation,exterior,stride=4)[0]
            if len(points):
                background.append(points[::max(1,len(points)//1000)])
            observation.sensor=mask_depth(sensor, mask, metric_scale)
        result.append(observation)
    return result, np.concatenate(background) if background else np.empty((0,3))


def unproject(view, depth, stride=1):
    y, x = np.where(depth[::stride, ::stride] > 0)
    y, x = y*stride, x*stride
    z = depth[y, x]
    camera = np.column_stack(((x-view.k[0, 2])*z/view.k[0, 0],
                              (y-view.k[1, 2])*z/view.k[1, 1], z))
    return (camera-view.pose[:3, 3]) @ view.pose[:3, :3], y, x


def project(points, view):
    camera = points @ view.pose[:3, :3].T + view.pose[:3, 3]
    z = camera[:, 2]
    p = camera @ view.k.T
    xy = p[:, :2]/np.maximum(z[:, None], 1e-12)
    h, w = view.mask.shape
    inside = (z > 0) & (xy[:, 0] >= 0) & (xy[:, 0] < w-.5) & (xy[:, 1] >= 0) & (xy[:, 1] < h-.5)
    pixels = np.floor(xy+.5).astype(np.int64)
    pixels[:, 0] = pixels[:, 0].clip(0, w-1)
    pixels[:, 1] = pixels[:, 1].clip(0, h-1)
    return pixels[:, 0], pixels[:, 1], z, inside


def silhouette_constraint(points, views):
    votes = np.zeros(len(points), np.uint16)
    available = np.zeros(len(points), np.uint16)
    for view in views[::max(1, len(views)//24)]:
        x, y, _, inside = project(points, view)
        # The complete object must be inside each accepted view; out-of-frame
        # points cannot evade visual-hull carving by claiming occlusion.
        available += 1
        padded = cv2.dilate(view.mask, np.ones((3, 3), np.uint8))
        votes += (inside & (padded[y, x] > 0))
    return votes >= np.maximum(6, np.ceil(available*.9))


def consistent_depth(view, values, neighbors, metric_scale, sensor=False):
    points, y, x = unproject(view, values)
    result = np.zeros_like(values)
    if not len(points):
        return result
    votes = np.zeros(len(points), np.uint8)
    conflicts = np.zeros(len(points), np.uint8)
    # Require actual parallax between rays to the same candidate surface point.
    a = view.center-points
    a /= np.maximum(np.linalg.norm(a, axis=1)[:, None], 1e-12)
    local = sorted((other for other in neighbors if other.name != view.name),
                   key=lambda other: np.linalg.norm(other.center-view.center))[:16]
    for other in local:
        if other.name == view.name:
            continue
        xx, yy, z, inside = project(points, other)
        b = other.center-points
        b /= np.maximum(np.linalg.norm(b, axis=1)[:, None], 1e-12)
        angle = np.sum(a*b, axis=1)
        distinct = (angle < math.cos(math.radians(3))) & (angle > math.cos(math.radians(75)))
        measured = other.depth[yy, xx]
        if other.sensor is not None:
            measured = np.where(measured > 0, measured, other.sensor[yy, xx])
        observed = inside & distinct & (other.mask[yy, xx] > 0) & (measured > 0)
        tolerance = np.maximum((.008 if sensor else .003)/metric_scale, z*(.02 if sensor else .01))
        votes += observed & (np.abs(measured-z) <= tolerance)
        # A point in front of measured depth contradicts measured free space.
        # Points hidden behind a nearer surface are merely occluded.
        conflicts += observed & (z < measured-tolerance*2)
    keep = (votes >= 2) & (conflicts <= 1) & silhouette_constraint(points, neighbors)
    result[y[keep], x[keep]] = values[y[keep], x[keep]]
    return result


def camera_coverage(views, center, alignment):
    cameras = (np.array([view.center for view in views])-center) @ alignment.T
    azimuth = ((np.arctan2(cameras[:, 2], cameras[:, 0])+math.pi)/(2*math.pi)*12).astype(int) % 12
    elevation = np.arctan2(cameras[:, 1], np.linalg.norm(cameras[:, [0, 2]], axis=1)) > .4
    counts = np.bincount(azimuth+elevation.astype(int)*12, minlength=24)
    missing = [dict(angle=int(i % 12)*30, band='high' if i >= 12 else 'low') for i in range(24) if counts[i] < 2]
    return counts, missing


def exclude_measured_support(views, background, metric_scale, alignment):
    """Remove a measured horizontal support only when it meets object-base evidence.

    This uses background Raw Depth, not a guessed table height or a fabricated base.
    With no reliable background plane, segmentation remains the only constraint.
    """
    if len(background)<500:
        return False
    foreground=[]
    for view in views:
        values=view.depth if np.count_nonzero(view.depth)>100 else view.sensor
        if values is not None:
            points=unproject(view,values,stride=6)[0]
            if len(points):
                foreground.append(points[::max(1,len(points)//500)])
    if not foreground:
        return False
    foreground=np.concatenate(foreground)*metric_scale
    remaining=background*metric_scale
    up=alignment[1]
    selected=None
    for _ in range(3):
        if len(remaining)<500:
            break
        cloud=o3d.geometry.PointCloud(o3d.utility.Vector3dVector(remaining))
        plane,inliers=cloud.segment_plane(distance_threshold=.004,ransac_n=3,num_iterations=300)
        if len(inliers)<200:
            break
        normal=np.asarray(plane[:3]);offset=float(plane[3])
        if normal@up<0:
            normal=-normal;offset=-offset
        distances=foreground@normal+offset
        # A shelf elsewhere in the scene must not cut through the object.
        near_base=float(np.quantile(distances,.1))
        if normal@up>.98 and -.004<=near_base<=.015:
            selected=(normal,offset)
            break
        remaining=np.delete(remaining,inliers,axis=0)
    if selected is None:
        return False
    normal,offset=selected
    for view in views:
        for values in (view.depth,view.sensor):
            if values is None:
                continue
            points,y,x=unproject(view,values)
            remove=points*metric_scale@normal+offset<=.003
            values[y[remove],x[remove]]=0
    return True


def filter_supported_surface(mesh, validated, constraints, tolerance):
    """Check corners, edge midpoints and face centers against measured depth."""
    vertices, faces = np.asarray(mesh.vertices), np.asarray(mesh.triangles)
    if not len(faces):
        raise CaptureIncomplete('Khong con be mat duoc phep do ho tro.')
    keep = np.ones(len(faces), bool)
    for weights in ((1, 0, 0), (0, 1, 0), (0, 0, 1), (.5, .5, 0), (.5, 0, .5), (0, .5, .5), (1/3, 1/3, 1/3)):
        points = np.einsum('fvc,v->fc', vertices[faces], weights)
        votes = np.zeros(len(points), np.uint16)
        for view, depth in validated:
            x, y, z, inside = project(points, view)
            measured = depth[y, x]
            votes += inside & (measured > 0) & (np.abs(measured-z) <= tolerance)
        keep &= (votes >= 2) & silhouette_constraint(points, constraints)
    mesh.remove_triangles_by_mask(~keep)
    mesh.remove_unreferenced_vertices()


def reconstruct_volume(directory, views, frames, metric_scale, alignment, progress):
    depths, background = load_depth_views(directory, views, frames, metric_scale)
    if len(depths) < 24:
        raise CaptureIncomplete('Can them nhieu goc nhin da dang ky de tao the tich.')
    progress(66, 'Kiem tra nhat quan MVS/Raw Depth va silhouette da goc')
    support_removed=exclude_measured_support(depths,background,metric_scale,alignment)
    validated = []
    sensor_used = 0
    sensor_views = 0
    sensor_footprints = []
    for index, view in enumerate(depths):
        sensor_pixels=0
        footprint=None
        depth = consistent_depth(view, view.depth, depths, metric_scale)
        if view.sensor is not None:
            raw = consistent_depth(view, view.sensor, depths, metric_scale, sensor=True)
            # AR depth may fill measured gaps only; it never overwrites detailed MVS.
            fill = (depth == 0) & (raw > 0)
            sensor_pixels=int(fill.sum())
            if fill.any():
                frame=frames[view.name]
                calibration=frame['depth']
                affine=np.asarray(calibration['imageToDepth']).reshape(2,3)
                fx=frame['intrinsics'][0]*np.linalg.norm(affine[:,0]*[calibration['width'],calibration['height']])/frame['width']
                fy=frame['intrinsics'][1]*np.linalg.norm(affine[:,1]*[calibration['width'],calibration['height']])/frame['height']
                footprint=float(np.median(raw[fill])*metric_scale/max(1,min(fx,fy)))
            depth[fill] = raw[fill]
        if np.count_nonzero(depth) >= 100:
            validated.append((view, depth))
            sensor_used+=sensor_pixels
            if footprint is not None:
                sensor_views+=1
                sensor_footprints.append(footprint)
        progress(66+int(9*(index+1)/len(depths)), f'Kiem tra depth {index+1}/{len(depths)}')
    if len(validated) < 16:
        raise CaptureIncomplete('Depth da goc chua du: quet them mat ben, mat sau va goc cheo; giu vat dung yen.')
    samples = np.concatenate([unproject(view, depth, stride=3)[0] for view, depth in validated])
    if len(samples) < 1500:
        raise CaptureIncomplete('Qua it phep do be mat. Den gan hon, tang sang va bo sung goc ben.')
    low, high = np.quantile(samples, [.005, .995], axis=0)
    center = (low+high)/2
    span = (high-low)*metric_scale
    if not np.isfinite(span).all() or span.max() > 2 or span.max() < .02:
        raise CaptureIncomplete('Kich thuoc vat/ty le khong tin cay; giu tron vat trong khung va quet lai.')
    sectors, missing = camera_coverage([view for view, _ in validated], center, alignment)
    if (sectors > 0).sum() < 10 or (sectors[:12] > 0).sum() < 6:
        raise CaptureIncomplete('Chua du vong quanh vat. Bo sung mat sau, hai ben va mot vong camera cao hon.', missing)
    # Scale the voxel grid to the measured object, not a user-selected fixed box.
    voxel = float(np.clip(np.linalg.norm(span)/384, .0007, .003))
    if sensor_footprints and sensor_used>sum(np.count_nonzero(d) for _,d in validated)*.5:
        # Upsampling a raw pixel does not add geometric detail. Use its physical
        # footprint to set the resolution when Raw Depth supplies most data.
        voxel=max(voxel,float(np.median(sensor_footprints))*.5)
        if voxel>.006:
            raise CaptureIncomplete('Raw Depth qua tho o khoang cach nay. Den gan hon va thu them anh stereo ro.')
    volume = o3d.pipelines.integration.ScalableTSDFVolume(
        voxel_length=voxel, sdf_trunc=voxel*4,
        color_type=o3d.pipelines.integration.TSDFVolumeColorType.RGB8,
        depth_sampling_stride=1)
    progress(76, 'Hop nhat TSDF thich ung tu depth da goc da kiem dinh')
    for view, depth in validated:
        metric = np.ascontiguousarray(depth*metric_scale, np.float32)
        color = np.ascontiguousarray(view.color[:, :, ::-1])
        rgbd = o3d.geometry.RGBDImage.create_from_color_and_depth(
            o3d.geometry.Image(color), o3d.geometry.Image(metric), depth_scale=1.,
            depth_trunc=5., convert_rgb_to_intensity=False)
        h, w = depth.shape
        intrinsic = o3d.camera.PinholeCameraIntrinsic(w, h, view.k[0, 0], view.k[1, 1], view.k[0, 2], view.k[1, 2])
        extrinsic = view.pose.copy()
        extrinsic[:3, 3] = -extrinsic[:3, :3] @ ((view.center-center)*metric_scale)
        volume.integrate(rgbd, intrinsic, extrinsic)
    mesh = volume.extract_triangle_mesh()
    if len(mesh.triangles) < 1000:
        raise CaptureIncomplete('TSDF chua tao duoc be mat lien tuc; can thu them depth/anh da goc.')
    mesh.vertices = o3d.utility.Vector3dVector(np.asarray(mesh.vertices)/metric_scale+center)
    progress(80, 'Loai mat khong duoc phep do ho tro; khong lap lo hoac dung mat khuat')
    # A TSDF crossing may extend into an unobserved cell. Verify every delivered
    # triangle against real depth at its corners, edges, and center.
    tolerance=max(voxel*3,.003)/metric_scale
    filter_supported_surface(mesh,validated,depths,tolerance)
    mesh.remove_duplicated_vertices()
    mesh.remove_duplicated_triangles()
    mesh.remove_degenerate_triangles()
    labels, counts, _ = mesh.cluster_connected_triangles()
    if not len(counts) or max(counts)/max(1, sum(counts)) < .8:
        raise CaptureIncomplete('Be mat con roi rac: bo sung goc chuyen tiep giua cac mat, khong chi chup rieng tung mat.')
    mesh.remove_triangles_by_mask(np.asarray(labels) != int(np.argmax(counts)))
    mesh.remove_unreferenced_vertices()
    if len(mesh.triangles) > 100000:
        # Vertex clustering/closing/Poisson are deliberately not used to bridge gaps.
        mesh = mesh.simplify_quadric_decimation(100000, maximum_error=(voxel/metric_scale)**2)
        filter_supported_surface(mesh,validated,depths,tolerance)
    return mesh, dict(center=center, voxel=voxel, sensorSamples=sensor_used, rawDepthViews=sensor_views, supportRemoved=support_removed,
                      depthViews=len(validated), sectors=sectors, missing=missing, depths=validated)


def inspect_volume(mesh, metric_scale, validated, center, alignment):
    points = np.asarray(mesh.vertices)
    if len(points) < 100:
        raise CaptureIncomplete('Khong du be mat that sau khi loc.')
    metric = (points-center)*metric_scale
    # PCA measures thickness independently of object orientation. An axis-aligned
    # bounding box alone can label a tilted sheet as a volumetric object.
    singular = np.linalg.svd(metric-metric.mean(axis=0), compute_uv=False)/math.sqrt(len(metric))
    if singular[-1] < .0015 or singular[-1]/max(singular[0], 1e-9) < .025:
        raise CaptureIncomplete('Be mat van gan nhu tam phang. Quet them hai ben, mat sau va mat tren; chua luu thanh vat 3D.')
    scene = o3d.t.geometry.RaycastingScene()
    scene.add_triangles(o3d.t.geometry.TriangleMesh.from_legacy(mesh))
    recalls, ious, missing = [], [], []
    for view, _ in validated[::max(1, len(validated)//16)]:
        h, w = view.mask.shape
        ratio = min(1., 240/max(h, w))
        width, height = max(1, round(w*ratio)), max(1, round(h*ratio))
        k = view.k.copy()
        k[0] *= width/w
        k[1] *= height/h
        rays = o3d.t.geometry.RaycastingScene.create_rays_pinhole(
            o3d.core.Tensor(k, dtype=o3d.core.Dtype.Float64),
            o3d.core.Tensor(view.pose, dtype=o3d.core.Dtype.Float64), width, height)
        rendered = np.isfinite(scene.cast_rays(rays)['t_hit'].numpy())
        target = cv2.resize(view.mask, (width, height), interpolation=cv2.INTER_NEAREST) > 0
        intersection = np.count_nonzero(rendered & target)
        recalls.append(intersection/max(1, np.count_nonzero(target)))
        ious.append(intersection/max(1, np.count_nonzero(rendered | target)))
        if recalls[-1]<.6 or ious[-1]<.5:
            camera=(view.center-center)@alignment.T
            angle=int((math.atan2(camera[2],camera[0])+math.pi)/(2*math.pi)*12)%12*30
            high=math.atan2(camera[1],np.linalg.norm(camera[[0,2]]))>.4
            direction=dict(angle=angle,band='high' if high else 'low')
            if direction not in missing:
                missing.append(direction)
    if np.median(recalls) < .7 or np.quantile(recalls, .1) < .4 or np.median(ious) < .65:
        raise CaptureIncomplete('Mesh chua giu du hinh dang trong cac anh goc ben/sau. Can quet them cac mat thieu, khong tao khoi thay the.',missing)
    return dict(silhouetteRecall=float(np.median(recalls)), silhouetteIoU=float(np.median(ious)),
                thicknessSigmaMeters=float(singular[-1]), measuredOnly=True, inferredFaces=0)
