"""Local-only reconstruction of continuously captured real camera frames.

COLMAP (BSD-3-Clause), OpenCV (Apache-2.0), Open3D (MIT), MobileSAM (Apache-2.0).
Unmodified OpenMVS CLI, copyright SEACAVE (AGPL-3.0), source:
https://github.com/cdcseacave/openMVS/tree/v2.4.0 ; license retained by setup script.
No pretrained object meshes, image uploads to third parties, or demo fallback.
"""
from __future__ import annotations

import argparse
import hmac
import json
import math
import os
import re
from pathlib import Path
import struct
import subprocess
import threading
import time
import importlib.metadata
import traceback
import uuid
import zipfile
import queue
import shutil
from http.server import BaseHTTPRequestHandler
os.environ.setdefault("OMP_NUM_THREADS", "4")
from hybrid_geometry import CaptureIncomplete, reconstruct_volume, inspect_volume, filter_supported_surface
from scan_network import LanIdentity, LanHTTPServer

ROOT = Path(__file__).resolve().parents[1] / "build" / "scan-jobs"
ROOT.mkdir(parents=True, exist_ok=True)
JOBS: dict[str, dict] = {}
JOB_DIRS: dict[str, Path] = {}
JOB_LOCK = threading.RLock()
MAX_PENDING = 4  # one reconstruction plus at most three waiting/uploading captures
CAPACITY = threading.BoundedSemaphore(MAX_PENDING)
UPLOAD = threading.BoundedSemaphore(1)
PENDING = queue.Queue(maxsize=MAX_PENDING)


def update(job: str, progress: int, message: str, **extra):
    with JOB_LOCK:
        JOBS[job].update(progress=progress, message=message, **extra)
        temporary=JOB_DIRS[job]/'status.partial'
        temporary.write_text(json.dumps(JOBS[job],ensure_ascii=False),encoding="utf-8")
        temporary.replace(JOB_DIRS[job]/'status.json')
    print(json.dumps({"job": job, **JOBS[job]}, ensure_ascii=False), flush=True)


def reconstruct(job: str, directory: Path):
    try:
        update(job, 1, 'Dang xu ly tren PC', state='processing')
        try:
            load_engine(job)
            run_reconstruction(job, directory)
        except CaptureIncomplete as error:
            update(job, 0, str(error), state="needs_more", missingAngles=error.missing)
        except Exception as error:
            traceback.print_exc()
            update(job, 0, str(error), state="error")
    finally:
        CAPACITY.release()


def reconstruction_worker():
    while True:
        job=PENDING.get()
        try:
            reconstruct(job,JOB_DIRS[job])
        except Exception as error:
            traceback.print_exc()
            with JOB_LOCK:
                JOBS[job].update(state='error',message=str(error))
        finally:
            PENDING.task_done()


def job_status(job):
    with JOB_LOCK:
        value=dict(JOBS[job])
        waiting=sorted((key for key,state in JOBS.items() if state['state']=='queued'),
                       key=lambda key:JOBS[key].get('created',0))
        value['queuePosition']=waiting.index(job)+1 if job in waiting else 0
        return value


def load_engine(job: str):
    global cv2, np, o3d, pycolmap
    # Accept and preserve captures while the isolated environment finishes setup.
    deadline = time.monotonic()+15*60
    while True:
        try:
            for name in ("numpy", "opencv-python-headless", "pycolmap", "open3d"):
                distribution=importlib.metadata.distribution(name)
                if not distribution.read_text("RECORD"):
                    raise importlib.metadata.PackageNotFoundError(name)
            break
        except importlib.metadata.PackageNotFoundError:
            if time.monotonic()>deadline:
                raise RuntimeError("Thu vien PC chua cai xong; anh da duoc giu trong build/scan-jobs.")
            update(job, 2, "Da nhan anh qua Wi-Fi; dang hoan tat thu vien PC",state="processing")
            time.sleep(3)
    import cv2
    import numpy as np
    import open3d as o3d
    import pycolmap


def reconstruct_openmvs(job, directory, model, views, binaries, frames):
    work=directory/'mvs'
    work.mkdir(exist_ok=True)
    sparse=work/'sparse'
    sparse.mkdir(exist_ok=True)
    model.write_binary(str(sparse))
    for view in views:
        mask=view['mask']*255
        cv2.imwrite(str(directory/'images'/(Path(view['image'].name).stem+'.mask.png')),mask)
    def run(name,args):
        command=[str(binaries/(name+'.exe')),*args,'--max-threads','4']
        process=subprocess.Popen(command,cwd=work,creationflags=getattr(subprocess,"CREATE_NO_WINDOW",0))
        deadline=time.monotonic()+45*60
        reported=-1
        while process.poll() is None:
            if time.monotonic()>deadline:
                process.kill();process.wait()
                raise TimeoutError(name+' exceeded 45 minutes; captured images remain on PC')
            if name=='DensifyPointCloud':
                logs=list(work.glob('DensifyPointCloud-*.log'))
                if logs:
                    log=max(logs,key=lambda path:path.stat().st_mtime).read_text(errors='replace')
                    measured=len(set(re.findall(r'Depth-map for image\s+(\d+) estimated using',log)))
                    if measured!=reported:
                        reported=measured
                        update(job,50+min(15,measured*15//max(1,len(views))),
                               f'OpenMVS: da uoc luong {measured}/{len(views)} depth-map; dang kiem tra da goc')
            time.sleep(2)
        if process.returncode:
            raise subprocess.CalledProcessError(process.returncode,command)
    update(job,45,'OpenMVS: chuan bi camera va mat na vat the')
    run('InterfaceCOLMAP',['-i',str(work),'-o','scene.mvs','--image-folder',str(directory/'images')])
    update(job,50,'OpenMVS: tai tao depth da goc va kiem tra nhat quan hinh hoc')
    try:
        run('DensifyPointCloud',['-i','scene.mvs','-o','dense.mvs','--resolution-level','0',
            '--min-resolution','480','--max-resolution','2048','--number-views','5',
            '--number-views-fuse','3','--ignore-mask-label','0','--tower-mode','0'])
    except subprocess.CalledProcessError:
        if sum('depth' in frames[view['image'].name] for view in views)<24:
            raise CaptureIncomplete('Stereo khong du depth va thieu Raw Depth doc lap. Quet lai du sang, them mat ben/sau.')
        update(job,65,'Stereo thieu du lieu: kiem tra Raw Depth da goc; khong sinh hinh hoc thay the')
    # Geometry is now reconstructed from calibrated depth maps by the hybrid
    # volume, rather than triangulating a sparse cloud and refining its sheets.
    return len(list(work.glob('depth*.dmap')))


def filter_dense_support(mesh, cloud, tolerance):
    vertices=np.asarray(mesh.vertices)
    faces=np.asarray(mesh.triangles)
    if not len(faces):
        raise ValueError("Khong con be mat duoc depth da goc ho tro.")
    # Endpoints alone can bridge a hole. Also probe edges and face centers.
    supported=np.ones(len(faces),dtype=bool)
    for barycentric in ((1,0,0),(0,1,0),(0,0,1),(.5,.5,0),(.5,0,.5),(0,.5,.5),(1/3,1/3,1/3)):
        probes=np.einsum('fvc,v->fc',vertices[faces],barycentric)
        points=o3d.geometry.PointCloud(o3d.utility.Vector3dVector(probes))
        supported &= np.asarray(points.compute_point_cloud_distance(cloud))<=tolerance
    mesh.remove_triangles_by_mask(~supported)
    mesh.remove_unreferenced_vertices()


def metric_alignment(views, by_name):
    source=np.array([v["center"] for v in views],dtype=np.float64)
    target=np.array([np.asarray(by_name[v["image"].name]["pose"]).reshape(4,4,order="F")[:3,3] for v in views])
    if not np.isfinite(source).all() or not np.isfinite(target).all() or np.abs(target).max()>50:
        raise ValueError("Pose camera khong hop le; bo anh cu can duoc thu lai voi tracking on dinh.")
    if np.linalg.norm(np.ptp(target,axis=0))>6:
        raise ValueError("Quy dao camera bi nhay vuot vung quet vat the; can thu lai.")
    keep=np.ones(len(source),bool)
    for _ in range(8):
        a=source[keep].mean(axis=0);b=target[keep].mean(axis=0)
        x=source[keep]-a;y=target[keep]-b
        u,d,vt=np.linalg.svd(y.T@x)
        correction=np.diag([1,1,np.linalg.det(u@vt)])
        rotation=u@correction@vt
        denominator=float(np.sum(x*x))
        if denominator<1e-10:
            raise ValueError("Camera khong co du dich chuyen de xac dinh ty le.")
        scale=float(np.sum(d*np.diag(correction))/denominator)
        residual=np.linalg.norm((source-a)@rotation.T*scale+b-target,axis=1)
        median=np.median(residual);mad=np.median(np.abs(residual-median))
        candidate=residual<max(.01,median+3*1.4826*mad)
        if candidate.sum()<max(20,len(source)*.75):
            raise ValueError("Camera ARCore va SfM khong khop; khong the giu dung ty le.")
        if np.array_equal(candidate,keep):
            break
        keep=candidate
    # Centers alone cannot constrain roll along a straight path. Verify camera
    # axes too: COLMAP +Y down,+Z forward; ARCore +Y up,-Z forward.
    angles=[]
    for view in views:
        ar_pose=np.asarray(by_name[view['image'].name]['pose']).reshape(4,4,order='F')
        ar=ar_pose[:3,:3]
        if (not np.isfinite(ar_pose).all() or not np.allclose(ar_pose[3],[0,0,0,1],atol=1e-5) or
            not np.allclose(ar.T@ar,np.eye(3),atol=1e-3) or abs(np.linalg.det(ar)-1)>.001):
            raise CaptureIncomplete('Pose camera khong phai bien doi cung hop le. Can bat dau phien tracking moi.')
        expected=rotation@view['pose'][:3,:3].T@np.diag([1,-1,-1])
        angles.append(np.degrees(np.arccos(np.clip((np.trace(ar.T@expected)-1)/2,-1,1))))
    if np.median(angles)>10 or np.quantile(angles,.9)>20:
        raise ValueError("Huong camera ARCore/SfM khong khop; tracking hoac hieu chuan chua on dinh.")
    span=float(np.linalg.norm(np.ptp(target[keep],axis=0)))
    rms=float(np.sqrt(np.mean(residual[keep]**2)))
    if not np.isfinite(scale) or scale<=0 or span<.15 or rms>max(.008,span*.025):
        raise ValueError(f"Ty le/pose camera chua tin cay (sai lech {rms*100:.1f} cm). Quet lai cham hon.")
    return rotation,scale


def mesh_quality(mesh):
    mesh.remove_duplicated_vertices();mesh.remove_duplicated_triangles();mesh.remove_degenerate_triangles()
    mesh.remove_unreferenced_vertices()
    faces=np.asarray(mesh.triangles)
    edges=np.sort(np.concatenate([faces[:,[0,1]],faces[:,[1,2]],faces[:,[2,0]]]),axis=1)
    _,counts=np.unique(edges,axis=0,return_counts=True)
    boundary=float((counts==1).mean()) if len(counts) else 1.
    manifold=bool(mesh.is_edge_manifold(allow_boundary_edges=True) and mesh.is_vertex_manifold())
    intersects=bool(mesh.is_self_intersecting())
    _,components,_=mesh.cluster_connected_triangles()
    retained=max(components)/max(1,len(faces)) if len(components) else 0
    return dict(acceptable=len(faces)>=300 and manifold and not intersects and retained>=.85,
                complete=len(faces)>=1000 and manifold and not intersects and retained>=.85 and mesh.is_watertight(),
                boundary=boundary)


def read_textured_obj(path):
    positions=[];texcoords=[];faces=[];materials={};material=None
    base=path.parent.resolve()
    def safe(name):
        result=(base/name).resolve()
        if not result.is_relative_to(base):raise ValueError("Invalid texture path")
        return result
    for line in path.read_text(encoding="utf-8").splitlines():
        parts=line.split()
        if not parts:continue
        if parts[0]=="mtllib":
            current=None
            for row in safe(" ".join(parts[1:])).read_text().splitlines():
                item=row.split()
                if not item:continue
                if item[0]=="newmtl":current=" ".join(item[1:])
                elif item[0]=="map_Kd" and current:materials[current]=safe(" ".join(item[1:]))
        elif parts[0]=="v":positions.append([float(x) for x in parts[1:4]])
        elif parts[0]=="vt":texcoords.append([float(x) for x in parts[1:3]])
        elif parts[0]=="usemtl":material=" ".join(parts[1:])
        elif parts[0]=="f":
            corners=[part.split("/") for part in parts[1:]]
            if len(corners)!=3:raise ValueError("Textured mesh must be triangulated")
            faces.append((material,[(int(c[0])-1,int(c[1])-1) for c in corners]))
    if not faces or not materials:raise ValueError("Khong tao duoc UV/texture that")
    images={key:cv2.imread(str(value)) for key,value in materials.items()}
    if any(img is None for img in images.values()):raise ValueError("Missing texture atlas")
    columns=math.ceil(math.sqrt(len(images)));rows=math.ceil(len(images)/columns)
    gutter=2
    tile=min(max(max(img.shape[:2]) for img in images.values())+2*gutter,4096//max(columns,rows))
    if tile<260:raise ValueError("Qua nhieu atlas; khong giam texture xuong muc mo khong dung duoc.")
    atlas=np.zeros((rows*tile,columns*tile,3),np.uint8);slots={}
    for i,(name,img) in enumerate(images.items()):
        row,col=divmod(i,columns);h,w=img.shape[:2]
        ratio=min(1.,(tile-2*gutter)/max(h,w))
        if ratio<1:
            img=cv2.resize(img,(max(1,round(w*ratio)),max(1,round(h*ratio))),interpolation=cv2.INTER_AREA)
            h,w=img.shape[:2]
        padded=cv2.copyMakeBorder(img,gutter,gutter,gutter,gutter,cv2.BORDER_REPLICATE)
        atlas[row*tile:row*tile+h+2*gutter,col*tile:col*tile+w+2*gutter]=padded
        slots[name]=(col*tile+gutter,row*tile+gutter,w,h)
    vertices=[];uv=[]
    for name,triangle in faces:
        left,top,w,h=slots[name]
        for p,t in triangle:
            vertices.append(positions[p]);u,v=texcoords[t]
            uv.append(((left+u*(w-1)+.5)/atlas.shape[1],
                       1-(top+(1-v)*(h-1)+.5)/atlas.shape[0]))
    uv=np.asarray(uv,dtype=np.float64)
    if not np.isfinite(uv).all() or (uv<-.001).any() or (uv>1.001).any():
        raise ValueError("UV texture khong hop le")
    return np.asarray(vertices,dtype=np.float64),uv.clip(0,1),atlas


def run_reconstruction(job: str, directory: Path):
    manifest = json.loads((directory / "manifest.json").read_text("utf-8"))
    frames = manifest["frames"]
    if not 30 <= len(frames) <= 180:
        raise ValueError("Can it nhat 30 anh ro va nhieu goc nhin co dich chuyen.")
    images = directory / "images"
    database = directory / "hybrid_features_v5.db"
    sparse = directory / "hybrid_sparse_v5"
    sparse.mkdir(exist_ok=True)
    masks = directory / "object_masks"
    update(job,3,"Tach vat the khoi nen bang MobileSAM",state="processing")
    engine_file=masks/"engine.json"
    if not engine_file.exists() or json.loads(engine_file.read_text()).get("version",0)<5:
        import sys
        interpreter=os.environ.get("SPATIAL_SEGMENT_PYTHON",sys.executable)
        helper=Path(__file__).with_name("segment_scan.py")
        process=subprocess.Popen([interpreter,"-B","-u",str(helper),str(directory)],stdout=subprocess.PIPE,text=True)
        for line in process.stdout:
            try:
                result=json.loads(line)
                update(job,3+int(result["frame"]/len(frames)*7),f"Tach vat the {result['frame']}/{len(frames)} anh")
            except (ValueError,KeyError):
                print(line.rstrip(),flush=True)
        if process.wait()!=0:
            raise ValueError("Khong tach duoc vat the; giu vat the dung yen va o giua khung.")
    accepted=json.loads(engine_file.read_text())["frames"]
    usable=[]
    for name in accepted:
        image=cv2.imread(str(images/name),cv2.IMREAD_GRAYSCALE)
        if image is None:continue
        h,w=image.shape;roi=image[h//5:h*4//5,w//5:w*4//5]
        if (cv2.Laplacian(roi,cv2.CV_64F).var()>=18 or roi.std()<12) and ((roi<8)|(roi>247)).mean()<.35:
            usable.append(name)
    accepted=usable
    if len(accepted)<30:
        raise ValueError("Khong du 30 anh ro, tach tron vat the.")
    # Camera poses use the static scene too; masks constrain object depth, not camera tracking.
    extraction = pycolmap.FeatureExtractionOptions()
    extraction.num_threads = 4
    extraction.max_image_size = 2048
    extraction.sift.max_num_features = 8000
    update(job, 5, "Tim dac trung tu anh camera that")
    by_name = {f["name"]: f for f in frames}
    # AUTO focus may change intrinsics. A single camera plus unconstrained focal
    # refinement can explain parallax as focal change and flatten the object.
    # Keep each ARCore-calibrated pinhole camera fixed while solving poses.
    for name in accepted:
        reader = pycolmap.ImageReaderOptions()
        reader.camera_model = "PINHOLE"
        reader.camera_params = ",".join(str(x) for x in by_name[name]["intrinsics"])
        pycolmap.extract_features(str(database), str(images), camera_mode=pycolmap.CameraMode.PER_IMAGE,
                                 image_names=[name], reader_options=reader, extraction_options=extraction,
                                 device=pycolmap.Device.cpu)
    matching = pycolmap.FeatureMatchingOptions()
    matching.num_threads = 4
    update(job, 20, "Ghep da goc va khep vong camera")
    # Exhaustive geometric matching also closes the first/last-view loop.
    pycolmap.match_exhaustive(str(database), matching_options=matching, device=pycolmap.Device.cpu)
    update(job, 35, "Uoc luong camera va hinh hoc 3D")
    options = pycolmap.IncrementalPipelineOptions()
    options.num_threads = 4
    options.ba_refine_focal_length = False
    options.ba_refine_principal_point = False
    options.ba_refine_extra_params = False
    maps = pycolmap.incremental_mapping(str(database), str(images), str(sparse), options=options)
    if not maps:
        raise ValueError("Khong tim duoc thi sai 3D. Can dich chuyen quanh vat the, khong chi xoay camera tai cho.")
    model = max(maps.values(), key=lambda m: m.num_reg_images())
    registered = sorted(model.images.values(), key=lambda im: im.name)
    if len(registered) < 24 or len(registered) < len(accepted)*.65:
        raise ValueError(f"Chi ghep duoc {len(registered)} anh. Hay quet cham hon, giu vat the dung yen va du sang.")
    by_name = {f["name"]: f for f in frames}
    views = []
    for image in registered:
        color = cv2.imread(str(images / image.name))
        if color is None:
            raise ValueError("Khong doc duoc anh da thu.")
        camera = model.cameras[image.camera_id]
        k = np.asarray(camera.calibration_matrix(), dtype=np.float64)
        foreground=(cv2.imread(str(masks/(image.name+".png")),cv2.IMREAD_GRAYSCALE)>0).astype(np.uint8)
        pose = np.asarray(image.cam_from_world().matrix())
        center = -pose[:3,:3].T @ pose[:3,3]
        views.append(dict(image=image, color=color, mask=foreground, k=k, pose=pose, center=center))
    alignment,metric_scale=metric_alignment(views,by_name)
    openmvs=Path(__file__).resolve().parents[1]/".scan-runtime/openmvs/vc17/x64/Release"
    required=("InterfaceCOLMAP","DensifyPointCloud","TextureMesh")
    if not all((openmvs/(name+".exe")).is_file() for name in required):
        raise RuntimeError("Can OpenMVS day du de kiem tra depth da goc; chay backend/tools/start-scan-server.ps1 tu thu muc du an lon.")
    fused=reconstruct_openmvs(job,directory,model,views,openmvs,by_name)
    mesh,fusion=reconstruct_volume(directory,views,by_name,metric_scale,alignment,
                                   lambda percent,message:update(job,percent,message))
    center=fusion['center']
    shape=inspect_volume(mesh,metric_scale,fusion['depths'],center,alignment)
    update(job,87,"Kiem tra topology, ty le camera va texture that")
    topology=mesh_quality(mesh)
    if not topology["acceptable"]:
        raise CaptureIncomplete("Luoi gap/chong mat hoac qua roi rac; can thu lai du lieu, khong danh dau thanh cong.")
    raw_vertices=np.asarray(mesh.vertices).copy()
    positions=(raw_vertices-center)@alignment.T*metric_scale
    floor=float(positions[:,1].min())
    positions[:,1]-=floor
    mesh.vertices=o3d.utility.Vector3dVector(positions)
    mesh.compute_vertex_normals()
    o3d.io.write_triangle_mesh(str(directory/"reconstructed.ply"),mesh)
    # Texture in the original calibrated SfM coordinates; geometry was already filtered.
    original=o3d.geometry.TriangleMesh(mesh)
    original.vertices=o3d.utility.Vector3dVector(raw_vertices)
    # Normals must return to SfM coordinates along with vertices; keeping the
    # gravity-aligned normals biases texture view selection toward wrong cameras.
    original.compute_vertex_normals()
    original.compute_triangle_normals()
    texture_input=directory/"mvs"/"observed.ply"
    o3d.io.write_triangle_mesh(str(texture_input),original)
    work=directory/"mvs"
    command=[str(openmvs/"TextureMesh.exe"),"-i","scene.mvs","-m",str(texture_input),
             "-o","textured.mvs","--export-type","obj","--close-holes","0","--decimate","1",
             "--resolution-level","0","--min-resolution","640","--max-texture-size","2048",
             # Pinned 2.4.0 has a seam-leveling sampler bug producing black
             # patches: https://github.com/cdcseacave/openMVS/issues/1251
             "--ignore-mask-label","0","--global-seam-leveling","0","--local-seam-leveling","0","--sharpness-weight","0",
             "--max-threads","4"]
    update(job,91,"Tao UV atlas tu anh da hieu chuan; tranh loi sampler OpenMVS 2.4.0")
    subprocess.run(command,cwd=work,check=True,timeout=15*60,creationflags=getattr(subprocess,"CREATE_NO_WINDOW",0))
    xyz,uv,texture=read_textured_obj(work/"textured.obj")
    # Validate the geometry actually delivered to Android after UV export.
    delivered=o3d.geometry.TriangleMesh(
        o3d.utility.Vector3dVector(xyz),
        o3d.utility.Vector3iVector(np.arange(len(xyz)).reshape(-1,3)))
    delivered_quality=mesh_quality(delivered)
    if not delivered_quality['acceptable']:
        raise ValueError("Mesh sau xuat UV bi gap/chong mat hoac roi rac; khong luu ket qua loi.")
    exported_faces=len(delivered.triangles)
    filter_supported_surface(delivered,fusion['depths'],[v for v,_ in fusion['depths']],
                             max(fusion['voxel']*3,.003)/metric_scale)
    if len(delivered.triangles)!=exported_faces:
        raise ValueError('Xuat UV da thay doi be mat vuot phep do. Khong phat hanh mesh/texture khong khop.')
    inspect_volume(delivered,metric_scale,fusion['depths'],center,alignment)
    topology=delivered_quality
    xyz=(xyz-center)@alignment.T*metric_scale
    xyz[:,1]-=floor
    tex_h,tex_w=texture.shape[:2]
    samples=texture[np.clip(((1-uv[:,1])*tex_h).astype(int),0,tex_h-1),
                    np.clip((uv[:,0]*tex_w).astype(int),0,tex_w-1)]
    vertices=xyz.astype(">f4")
    colors=samples[:,::-1].astype(">f4")
    encoded=cv2.imencode(".png",texture)[1].tobytes()
    with (directory/"model.mesh").open("wb") as output:
        output.write(struct.pack(">ii",0x53434E32,vertices.size))
        output.write(vertices.tobytes());output.write(colors.tobytes())
        output.write(uv.astype(">f4").tobytes());output.write(struct.pack(">i",len(encoded)));output.write(encoded)
    sectors=fusion['sectors']
    coverage=int((sectors>=2).sum()*100//24)
    complete=coverage>=75 and (sectors[:12]>=2).sum()>=9 and (sectors[12:]>=2).sum()>=9 and len(views)>=40 and topology["complete"]
    summary=(f"Hybrid TSDF: {fusion['depthViews']} goc depth; {fusion['rawDepthViews']} khung Raw Depth bo sung; "
             f"voxel {fusion['voxel']*1000:.1f} mm; silhouette IoU {shape['silhouetteIoU']*100:.0f}%; "
             "chi be mat do duoc; khong sinh mat khuat; UV anh goc")
    update(job,100,"Da tao ban quet can xem lai hinh dang" if not complete else "Dat kiem tra du lieu; can xem lai vat that",
           state="done",triangles=len(xyz)//3,frames=len(frames),registered=len(views),fused=fused,
           coverage=coverage,complete=bool(complete),scaleEstimated=False,quality=summary,engineVersion=5,
           measuredOnly=True,inferredFaces=0,missingAngles=fusion['missing'],
           silhouetteIoU=shape['silhouetteIoU'],depthViews=fusion['depthViews'])



def engine_ready():
    try:
        for name in ("numpy", "opencv-python-headless", "pycolmap", "open3d", "torch", "torchvision", "huggingface-hub", "safetensors"):
            if not importlib.metadata.distribution(name).read_text("RECORD"):
                return False
        runtime=Path(__file__).resolve().parents[1]/".scan-runtime"
        return ((runtime/"mobilesam/mobile_sam.pt").is_file() and (runtime/"segmentation-deps/timm").is_dir()
                and all((runtime/"openmvs/vc17/x64/Release"/(name+".exe")).is_file()
                        for name in ("InterfaceCOLMAP","DensifyPointCloud","TextureMesh")))
    except importlib.metadata.PackageNotFoundError:
        return False


class Handler(BaseHTTPRequestHandler):
    def device(self):
        device=self.headers.get('X-Device-ID','')
        try:
            if str(uuid.UUID(device))!=device:
                raise ValueError()
        except ValueError:
            self.json_response(401,{'error':'Invalid device identity'})
            return None
        expected='Bearer '+self.server.identity.device_token(device)
        if not hmac.compare_digest(self.headers.get('Authorization','').encode(),expected.encode()):
            self.json_response(401,{'error':'Pair this device with the PC again'})
            return None
        return device

    def log_message(self, format, *args):
        if args and str(args[0]).startswith("GET /jobs/"):
            return
        super().log_message(format,*args)

    def json_response(self, code, value):
        data=json.dumps(value,ensure_ascii=False).encode("utf-8")
        self.send_response(code);self.send_header("Content-Type","application/json; charset=utf-8")
        self.send_header('Cache-Control','no-store')
        if code==429:self.send_header('Retry-After','10')
        self.send_header("Content-Length",str(len(data)));self.end_headers();self.wfile.write(data)

    def do_GET(self):
        if self.path=="/health":
            with JOB_LOCK:
                waiting=sum(value['state']=='queued' for value in JOBS.values())
                processing=sum(value['state']=='processing' for value in JOBS.values())
            return self.json_response(200,{"ready":engine_ready(),"engine":"Hybrid Object Reconstruction",
                "version":5,"protocol":6,"serverId":self.server.identity.server_id,
                "waiting":waiting,"processing":processing,"capacity":MAX_PENDING})
        device=self.device()
        if device is None:return
        if self.path=="/jobs":
            with JOB_LOCK:
                owned=[key for key,value in JOBS.items() if value.get('device')==device]
            return self.json_response(200,{"jobs":[{"id":key,**job_status(key)} for key in owned]})
        parts=self.path.strip("/").split("/")
        if len(parts)==2 and parts[0]=='captures':
            with JOB_LOCK:
                existing=next((key for key,value in JOBS.items() if value.get('device')==device and value.get('capture')==parts[1]),None)
            return self.json_response(200,{'id':existing})
        if len(parts) not in (2,3) or parts[0]!="jobs" or parts[1] not in JOBS or JOBS[parts[1]].get('device')!=device:
            return self.json_response(404,{"error":"Unknown job"})
        job=parts[1]
        if len(parts)==3 and parts[2]=="mesh" and JOBS[job]["state"]=="done":
            model=JOB_DIRS[job]/'model.mesh'
            self.send_response(200);self.send_header("Content-Type","application/octet-stream")
            self.send_header("Content-Length",str(model.stat().st_size));self.end_headers()
            with model.open('rb') as source:shutil.copyfileobj(source,self.wfile,1024*1024)
            return
        self.json_response(200,job_status(job))

    def do_POST(self):
        if self.path=='/pair':
            device=self.headers.get('X-Device-ID','')
            try:
                if str(uuid.UUID(device))!=device:raise ValueError()
            except ValueError:return self.json_response(400,{'error':'Invalid device identity'})
            if not hmac.compare_digest(self.headers.get('X-Pairing-Key','').encode(),self.server.identity.secret.encode()):
                return self.json_response(403,{'error':'Wrong PC pairing code'})
            return self.json_response(200,{'token':self.server.identity.device_token(device),
                                          'serverId':self.server.identity.server_id})
        if self.path!="/reconstruct":
            return self.json_response(404,{"error":"Unknown route"})
        device=self.device()
        if device is None:return
        capture=self.headers.get('X-Capture-ID','')
        try:
            if str(uuid.UUID(capture))!=capture:raise ValueError()
        except ValueError:return self.json_response(400,{'error':'Invalid capture ID'})
        with JOB_LOCK:
            existing=next((key for key,value in JOBS.items() if value.get('device')==device and value.get('capture')==capture),None)
        if existing:return self.json_response(202,{'id':existing})
        with JOB_LOCK:
            own_pending=sum(value.get('device')==device and value['state'] in ('queued','processing') for value in JOBS.values())
        if own_pending>=2:
            return self.json_response(429,{'error':'Dien thoai nay da co 2 phien dang xu ly/cho. Vui long cho hoan tat.'})
        if not UPLOAD.acquire(blocking=False):
            return self.json_response(429,{'error':'PC dang nhan du lieu tu dien thoai khac. Thu lai sau vai giay.'})
        if not CAPACITY.acquire(blocking=False):
            UPLOAD.release()
            return self.json_response(429,{'error':'Hang doi da day (1 dang xu ly + 3 cho). Giu bo quet va thu lai sau.'})
        admitted=False
        archive=None
        upload=None
        directory=None
        try:
            length=int(self.headers.get("Content-Length",0))
            if not 0<length<=200_000_000:
                raise ValueError("Invalid upload size")
            job=str(uuid.uuid4());directory=ROOT/device/job;directory.mkdir(parents=True)
            upload=directory/'capture.zip.partial'
            remaining=length
            with upload.open('wb') as output:
                while remaining:
                    chunk=self.rfile.read(min(1024*1024,remaining))
                    if not chunk:raise ValueError('Upload interrupted; retry the same capture')
                    output.write(chunk);remaining-=len(chunk)
            archive=zipfile.ZipFile(upload)
            members=archive.infolist()
            if len(members)>541 or len({f.filename for f in members})!=len(members) or sum(f.file_size for f in members)>200_000_000:
                raise ValueError("Invalid capture archive")
            for member in members:
                name=member.filename
                if name!="manifest.json" and not re.fullmatch(r'(images/frame_\d{4}\.jpg|depth/frame_\d{4}\.(u16|u8))',name):
                    raise ValueError("Unexpected file in capture")
                if ".." in name or "\\" in name or ":" in name:
                    raise ValueError("Unsafe capture path")
            manifest=json.loads(archive.read('manifest.json'))
            frames=manifest['frames']
            if not 30<=len(frames)<=180 or len({f['name'] for f in frames})!=len(frames):
                raise ValueError('Invalid keyframe count')
            names={f.filename for f in members}
            for frame in frames:
                if not re.fullmatch(r'frame_\d{4}\.jpg',frame['name']) or 'images/'+frame['name'] not in names:
                    raise ValueError('Missing or invalid RGB keyframe')
                if 'depth' in frame:
                    stem=Path(frame['name']).stem
                    depth=frame['depth']
                    w,h=depth['width'],depth['height']
                    if not (isinstance(w,int) and isinstance(h,int) and 1<=w<=1024 and 1<=h<=1024):
                        raise ValueError('Invalid sensor dimensions')
                    if (archive.getinfo(f'depth/{stem}.u16').file_size!=w*h*2 or
                        archive.getinfo(f'depth/{stem}.u8').file_size!=w*h):
                        raise ValueError('Incomplete depth/confidence pair')
                calibration=frame['intrinsics']
                if len(frame['pose'])!=16 or len(calibration)!=4 or not all(math.isfinite(v) for v in frame['pose']+calibration):
                    raise ValueError('Invalid camera calibration')
                if calibration[0]<=0 or calibration[1]<=0:
                    raise ValueError('Invalid focal length')
            archive.extractall(directory)
            with JOB_LOCK:
                JOB_DIRS[job]=directory
                JOBS[job]={"state":"queued","progress":0,"message":"Dang cho luot tren PC",
                           'device':device,'capture':capture,'created':time.time()}
                update(job,0,'Dang cho luot tren PC')
                PENDING.put_nowait(job)
                admitted=True
            self.json_response(202,{"id":job})
        except Exception as error:
            self.json_response(400,{"error":str(error)})
        finally:
            if archive is not None:archive.close()
            if upload is not None:upload.unlink(missing_ok=True)
            if not admitted:
                if directory is not None:
                    with JOB_LOCK:
                        JOBS.pop(directory.name,None)
                        JOB_DIRS.pop(directory.name,None)
                CAPACITY.release()
                # Remove only this request's incomplete, newly allocated directory.
                if directory is not None and directory.parent==ROOT/device:
                    shutil.rmtree(directory)
            UPLOAD.release()


if __name__=="__main__":
    parser=argparse.ArgumentParser(description="TLS object scanner for a private Wi-Fi subnet")
    parser.add_argument('--host',required=True,help='Specific private IPv4 address of the laptop')
    parser.add_argument('--subnet',required=True,help='Wi-Fi subnet, e.g. 192.168.1.0/24')
    parser.add_argument('--port',type=int,default=8765)
    parser.add_argument('--show-pairing',action='store_true',help='Show the local QR card when launched by the PC user')
    args=parser.parse_args()
    if not 1<=args.port<=65535:parser.error('Port must be between 1 and 65535')
    identity=LanIdentity(args.host,args.subnet)
    server=LanHTTPServer((args.host,args.port),Handler,identity)
    usb_server = server if args.host == '127.0.0.1' else LanHTTPServer(('127.0.0.1',args.port),Handler,identity)
    if usb_server is not server:
        threading.Thread(target=usb_server.serve_forever,daemon=True,name='scan-usb-http').start()
    from scan_usb import watch_usb
    lan_address = f'https://{args.host}:{args.port}' if args.host != '127.0.0.1' else ''
    threading.Thread(target=watch_usb,args=(args.port,identity.pairing_code,lan_address),daemon=True,name='scan-usb-adb').start()
    print(f"Scan server: https://{args.host}:{args.port}; USB: https://127.0.0.1:{args.port}",flush=True)
    print(f"Pairing code (trusted phones only): {identity.pairing_code}",flush=True)
    print(f"Allowed subnet: {identity.subnet}; 1 worker, 3 waiting captures. Ctrl+C to stop.",flush=True)
    discovery = None
    if lan_address:
        from scan_connect import write_pairing_card, advertise
        try:
            card = write_pairing_card(lan_address, identity.pairing_code,
                Path(__file__).resolve().parents[1]/'.scan-runtime/network/Ket-noi-may-quet.html')
            print(f"Open this file on your PC to show the pairing QR: {card}", flush=True)
            if args.show_pairing:
                import webbrowser
                webbrowser.open(card.as_uri())
        except Exception as error:
            print(f"Pairing QR unavailable ({type(error).__name__}); USB/manual pairing still available.", flush=True)
        try:
            discovery = advertise(args.host, args.port, identity.server_id)
        except Exception as error:
            print(f"Local discovery unavailable ({type(error).__name__}); use the QR or USB.", flush=True)
    # Keep legacy, unowned captures in place; never expose them to newly paired devices.
    # Restart only owned jobs admitted by the bounded Wi-Fi queue.
    recovery=[]
    for manifest in sorted(ROOT.glob('*/*/manifest.json')):
        directory=manifest.parent
        try:
            device=str(uuid.UUID(directory.parent.name))
            job=str(uuid.UUID(directory.name))
            status=directory/'status.json'
            if not status.is_file():continue
            state=json.loads(status.read_text('utf-8'))
            if state.get('device')!=device:continue
            JOBS[job]=state
            JOB_DIRS[job]=directory
            if state.get('state') in ('queued','processing'):
                recovery.append(job)
        except (ValueError,OSError):
            continue
    for job in sorted(recovery,key=lambda key:JOBS[key].get('created',0)):
        if CAPACITY.acquire(blocking=False):
            update(job,0,'Khoi phuc hang doi sau khi PC khoi dong lai',state='queued')
            PENDING.put_nowait(job)
        else:
            update(job,0,'Qua gioi han hang doi khi khoi phuc; du lieu van duoc giu tren PC',state='error')
    threading.Thread(target=reconstruction_worker,daemon=True,name='scan-reconstruction').start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        if discovery is not None:
            discovery.close()
        server.server_close()
        if usb_server is not server:
            usb_server.shutdown()
            usb_server.server_close()
