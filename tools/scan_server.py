"""Local-only reconstruction of continuously captured real camera frames.

COLMAP (BSD-3-Clause), OpenCV (Apache-2.0), Open3D (MIT), MobileSAM (Apache-2.0).
Unmodified OpenMVS CLI, copyright SEACAVE (AGPL-3.0), source:
https://github.com/cdcseacave/openMVS/tree/v2.4.0 ; license retained by setup script.
No pretrained object meshes, image uploads to third parties, or demo fallback.
"""
from __future__ import annotations

import io
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
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

os.environ.setdefault("OMP_NUM_THREADS", "4")

ROOT = Path(__file__).resolve().parents[1] / "build" / "scan-jobs"
ROOT.mkdir(parents=True, exist_ok=True)
JOBS: dict[str, dict] = {}
WORKER = threading.Semaphore(1)


def update(job: str, progress: int, message: str, **extra):
    JOBS[job].update(progress=progress, message=message, **extra)
    (ROOT/job/"status.json").write_text(json.dumps(JOBS[job],ensure_ascii=False),encoding="utf-8")
    print(json.dumps({"job": job, **JOBS[job]}, ensure_ascii=False), flush=True)


def reconstruct(job: str, directory: Path):
    with WORKER:
        try:
            load_engine(job)
            run_reconstruction(job, directory)
        except Exception as error:
            traceback.print_exc()
            update(job, 0, str(error), state="error")


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
            update(job, 2, "Da nhan anh qua USB; dang hoan tat thu vien PC",state="processing")
            time.sleep(3)
    import cv2
    import numpy as np
    import open3d as o3d
    import pycolmap


def reconstruct_openmvs(job, directory, model, views, binaries):
    work=directory/'mvs'
    work.mkdir(exist_ok=True)
    sparse=work/'sparse'
    sparse.mkdir(exist_ok=True)
    model.write_binary(str(sparse))
    for view in views:
        mask=cv2.morphologyEx(view['mask']*255,cv2.MORPH_OPEN,
                             cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(7,7)))
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
                        update(job,50+min(22,measured*22//max(1,len(views))),
                               f'OpenMVS: da uoc luong {measured}/{len(views)} depth-map; dang kiem tra da goc')
            time.sleep(2)
        if process.returncode:
            raise subprocess.CalledProcessError(process.returncode,command)
    update(job,45,'OpenMVS: chuan bi camera va mat na vat the')
    run('InterfaceCOLMAP',['-i',str(work),'-o','scene.mvs','--image-folder',str(directory/'images')])
    update(job,50,'OpenMVS: tai tao depth da goc va kiem tra nhat quan hinh hoc')
    run('DensifyPointCloud',['-i','scene.mvs','-o','dense.mvs','--resolution-level','0',
        '--min-resolution','480','--max-resolution','2048','--number-views','5',
        '--number-views-fuse','3','--ignore-mask-label','0','--tower-mode','0'])
    update(job,80,'OpenMVS: tao luoi tu diem 3D quan sat duoc')
    run('ReconstructMesh',['-i','scene.mvs','-p','dense.ply','-o','mesh.mvs','--close-holes','0'])
    mesh=o3d.io.read_triangle_mesh(str(work/'mesh.ply'))
    cloud=o3d.io.read_point_cloud(str(work/'dense.ply'))
    if len(mesh.triangles)<100 or not cloud.has_colors():
        raise ValueError('OpenMVS chua tai tao duoc be mat mau tu camera.')
    tree=o3d.geometry.KDTreeFlann(cloud)
    nearest=np.array([tree.search_knn_vector_3d(p,1)[1][0] for p in np.asarray(mesh.vertices)])
    mesh.vertex_colors=o3d.utility.Vector3dVector(np.asarray(cloud.colors)[nearest])
    # Silhouette consistency across all cameras removes support-surface leakage.
    vertices=np.asarray(mesh.vertices)
    votes=np.zeros(len(vertices),np.uint16)
    visible=np.zeros(len(vertices),np.uint16)
    for view in views:
        p=(vertices@view['pose'][:3,:3].T+view['pose'][:3,3])@view['k'].T
        z=p[:,2]
        x=np.divide(p[:,0],z,out=np.full_like(z,-1),where=z>0)
        y=np.divide(p[:,1],z,out=np.full_like(z,-1),where=z>0)
        h,w=view['mask'].shape
        inside=(z>0)&(x>=0)&(x<w)&(y>=0)&(y<h)
        visible[inside]+=1
        votes[inside]+=view['mask'][y[inside].astype(int),x[inside].astype(int)]
    keep=(visible>=4)&(votes>=np.ceil(visible*.8))
    mesh.remove_triangles_by_mask(~np.all(keep[np.asarray(mesh.triangles)],axis=1))
    mesh.remove_unreferenced_vertices()
    # Reject bridges/phantom triangles unsupported by the measured dense cloud.
    spacing=np.asarray(cloud.compute_nearest_neighbor_distance())
    tolerance=max(float(np.quantile(spacing,.75))*4,
                  float(np.linalg.norm(cloud.get_max_bound()-cloud.get_min_bound()))*.01)
    probes=o3d.geometry.PointCloud(o3d.utility.Vector3dVector(np.asarray(mesh.vertices)))
    distances=np.asarray(probes.compute_point_cloud_distance(cloud))
    supported=np.all(distances[np.asarray(mesh.triangles)]<=tolerance,axis=1)
    centers=np.asarray(mesh.vertices)[np.asarray(mesh.triangles)].mean(axis=1)
    center_cloud=o3d.geometry.PointCloud(o3d.utility.Vector3dVector(centers))
    supported &= np.asarray(center_cloud.compute_point_cloud_distance(cloud))<=tolerance
    mesh.remove_triangles_by_mask(~supported)
    mesh.remove_unreferenced_vertices()
    mesh.remove_duplicated_vertices();mesh.remove_duplicated_triangles();mesh.remove_degenerate_triangles()
    labels,counts,_=mesh.cluster_connected_triangles()
    if not len(counts) or max(counts)/max(1,sum(counts))<.60:
        raise ValueError("Dense depth qua roi rac; khong du be mat nhat quan.")
    mesh.remove_triangles_by_mask(np.asarray(labels)!=int(np.argmax(counts)))
    mesh.remove_unreferenced_vertices()
    if len(mesh.triangles)>150_000:
        mesh=mesh.simplify_quadric_decimation(150_000)
    o3d.io.write_triangle_mesh(str(work/"supported.ply"),mesh)
    update(job,83,"Tinh chinh hinh hoc da goc, giu cac mat da do duoc")
    run('RefineMesh',['-i','scene.mvs','-m','supported.ply','-o','refined.mvs',
        '--resolution-level','1','--min-resolution','640','--scales','2','--close-holes','0',
        '--decimate','1','--max-views','8'])
    mesh=o3d.io.read_triangle_mesh(str(work/"refined.ply"))
    return mesh,len(list(work.glob('*.dmap')))


def metric_alignment(views, by_name):
    source=np.array([v["center"] for v in views],dtype=np.float64)
    target=np.array([np.asarray(by_name[v["image"].name]["pose"]).reshape(4,4,order="F")[:3,3] for v in views])
    if not np.isfinite(source).all() or not np.isfinite(target).all() or np.abs(target).max()>50:
        raise ValueError("Pose camera khong hop le; bo anh cu can duoc thu lai voi tracking on dinh.")
    if np.linalg.norm(np.ptp(target,axis=0))>6:
        raise ValueError("Quy dao camera bi nhay vuot vung quet vat the; can thu lai.")
    keep=np.ones(len(source),bool)
    for _ in range(4):
        a=source[keep].mean(axis=0);b=target[keep].mean(axis=0)
        x=source[keep]-a;y=target[keep]-b
        u,d,vt=np.linalg.svd(y.T@x)
        correction=np.diag([1,1,np.linalg.det(u@vt)])
        rotation=u@correction@vt
        scale=float(np.sum(d*np.diag(correction))/np.sum(x*x))
        residual=np.linalg.norm((source-a)@rotation.T*scale+b-target,axis=1)
        median=np.median(residual);mad=np.median(np.abs(residual-median))
        keep=residual<max(.01,median+3*1.4826*mad)
        if keep.sum()<max(20,len(source)*.75):
            raise ValueError("Camera ARCore va SfM khong khop; khong the giu dung ty le.")
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
    return dict(acceptable=len(faces)>=300 and manifold and not intersects,
                complete=len(faces)>=1000 and manifold and not intersects and boundary<.12,
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
    tile=max(max(img.shape[:2]) for img in images.values())
    columns=math.ceil(math.sqrt(len(images)));rows=math.ceil(len(images)/columns)
    if tile*max(columns,rows)>4096:raise ValueError("Atlas vuot gioi han Android; can giam so patch texture.")
    atlas=np.zeros((rows*tile,columns*tile,3),np.uint8);slots={}
    for i,(name,img) in enumerate(images.items()):
        row,col=divmod(i,columns);h,w=img.shape[:2]
        atlas[row*tile:row*tile+h,col*tile:col*tile+w]=img
        slots[name]=(col*tile,row*tile,w,h)
    vertices=[];uv=[]
    for name,triangle in faces:
        left,top,w,h=slots[name]
        for p,t in triangle:
            vertices.append(positions[p]);u,v=texcoords[t]
            uv.append(((left+u*(w-1))/max(1,atlas.shape[1]-1),
                       1-(top+(1-v)*(h-1))/max(1,atlas.shape[0]-1)))
    uv=np.asarray(uv,dtype=np.float64)
    if not np.isfinite(uv).all() or (uv<-.001).any() or (uv>1.001).any():
        raise ValueError("UV texture khong hop le")
    return np.asarray(vertices,dtype=np.float64),uv.clip(0,1),atlas


def run_reconstruction(job: str, directory: Path):
    manifest = json.loads((directory / "manifest.json").read_text("utf-8"))
    frames = manifest["frames"]
    if not 30 <= len(frames) <= 120:
        raise ValueError("Can it nhat 30 anh ro va nhieu goc nhin co dich chuyen.")
    images = directory / "images"
    database = directory / "segmented_features.db"
    sparse = directory / "segmented_sparse"
    sparse.mkdir(exist_ok=True)
    first = frames[0]
    intr = first["intrinsics"]
    masks = directory / "object_masks"
    update(job,3,"Tach vat the khoi nen bang MobileSAM",state="processing")
    engine_file=masks/"engine.json"
    if not engine_file.exists() or json.loads(engine_file.read_text()).get("version",0)<3:
        interpreter=os.environ.get("SPATIAL_SEGMENT_PYTHON")
        if not interpreter:
            interpreter=subprocess.check_output(["py","-3.11","-c","import sys;print(sys.executable)"],text=True).strip()
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
        if cv2.Laplacian(roi,cv2.CV_64F).var()>=18 and ((roi<8)|(roi>247)).mean()<.35:
            usable.append(name)
    accepted=usable
    if len(accepted)<30:
        raise ValueError("Khong du 30 anh ro, tach tron vat the.")
    reader = pycolmap.ImageReaderOptions()
    reader.camera_model = "PINHOLE"
    reader.camera_params = ",".join(str(x) for x in intr)
    # Camera poses use the static scene too; masks constrain object depth, not camera tracking.
    extraction = pycolmap.FeatureExtractionOptions()
    extraction.num_threads = 4
    extraction.max_image_size = 2048
    extraction.sift.max_num_features = 8000
    update(job, 5, "Tim dac trung tu anh camera that")
    pycolmap.extract_features(str(database), str(images), camera_mode=pycolmap.CameraMode.SINGLE,
                             image_names=accepted, reader_options=reader, extraction_options=extraction,
                             device=pycolmap.Device.cpu)
    matching = pycolmap.FeatureMatchingOptions()
    matching.num_threads = 4
    update(job, 20, "Ghep da goc va khep vong camera")
    # Exhaustive geometric matching also closes the first/last-view loop.
    pycolmap.match_exhaustive(str(database), matching_options=matching, device=pycolmap.Device.cpu)
    update(job, 35, "Uoc luong camera va hinh hoc 3D")
    options = pycolmap.IncrementalPipelineOptions()
    options.num_threads = 4
    options.ba_refine_focal_length = True
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
    candidates = []
    for view in views:
        h, w = view["mask"].shape
        for point in view["image"].points2D:
            if not point.has_point3D():
                continue
            x, y = np.round(point.xy).astype(int)
            if 0 <= x < w and 0 <= y < h and view["mask"][y,x]:
                p = model.points3D[point.point3D_id]
                if p.track.length() >= 3:
                    candidates.append(np.asarray(p.xyz))
    if len(candidates) < 30:
        raise ValueError("Chua du dac trung tren vat the. Dua vat the vao giua khung, chon mat co hoa tiet va quet lai.")
    cloud = np.asarray(candidates)
    center = np.median(cloud, axis=0)
    radius = float(np.quantile(np.linalg.norm(cloud-center, axis=1), .95))
    if radius <= 1e-6:
        raise ValueError("Khong xac dinh duoc the tich vat the.")
    openmvs=Path(__file__).resolve().parents[1]/".scan-runtime/openmvs/vc17/x64/Release"
    required=("InterfaceCOLMAP","DensifyPointCloud","ReconstructMesh","RefineMesh","TextureMesh")
    if not all((openmvs/(name+".exe")).is_file() for name in required):
        raise RuntimeError("Can OpenMVS day du de kiem tra depth da goc; chay tools/start-scan-server.ps1.")
    mesh,fused=reconstruct_openmvs(job,directory,model,views,openmvs)
    vertices = np.asarray(mesh.vertices)
    triangles = np.asarray(mesh.triangles)
    if len(triangles) < 100:
        raise ValueError("Du lieu that chua tao duoc 100 tam giac; khong sinh mo hinh thay the.")
    valid = np.linalg.norm(vertices-center,axis=1)<radius*1.25
    mesh.remove_triangles_by_mask(~np.all(valid[triangles],axis=1))
    mesh.remove_unreferenced_vertices()
    labels, counts, _ = mesh.cluster_connected_triangles()
    if len(counts):
        mesh.remove_triangles_by_mask(np.asarray(labels)!=int(np.argmax(counts)))
    mesh.remove_unreferenced_vertices()
    if len(mesh.triangles)>150_000:
        mesh = mesh.simplify_quadric_decimation(150_000)
    if len(mesh.triangles)<100:
        raise ValueError("Be mat vat the chua du lien tuc. Hay thu quet lai cham hon.")
    update(job,87,"Kiem tra topology, ty le camera va texture that")
    topology=mesh_quality(mesh)
    if not topology["acceptable"]:
        raise ValueError("Luoi gap/chong mat hoac qua roi rac; can thu lai du lieu, khong danh dau thanh cong.")
    raw_vertices=np.asarray(mesh.vertices).copy()
    positions=(raw_vertices-center)@alignment.T*metric_scale
    floor=float(positions[:,1].min())
    positions[:,1]-=floor
    mesh.vertices=o3d.utility.Vector3dVector(positions)
    mesh.compute_vertex_normals()
    if np.ptp(positions,axis=0).min()<.003:
        raise ValueError("Be mat gan nhu phang; chua do du chieu sau vat the.")
    o3d.io.write_triangle_mesh(str(directory/"reconstructed.ply"),mesh)
    # Texture in the original calibrated SfM coordinates; geometry was already filtered.
    original=o3d.geometry.TriangleMesh(mesh)
    original.vertices=o3d.utility.Vector3dVector(raw_vertices)
    texture_input=directory/"mvs"/"observed.ply"
    o3d.io.write_triangle_mesh(str(texture_input),original)
    work=directory/"mvs"
    command=[str(openmvs/"TextureMesh.exe"),"-i","refined.mvs","-m",str(texture_input),
             "-o","textured.mvs","--export-type","obj","--close-holes","0","--decimate","1",
             "--resolution-level","0","--min-resolution","640","--max-texture-size","2048",
             "--ignore-mask-label","0","--global-seam-leveling","1","--local-seam-leveling","1","--sharpness-weight","0",
             "--max-threads","4"]
    update(job,91,"Tao UV atlas va can bang duong noi texture tu anh da hieu chuan")
    subprocess.run(command,cwd=work,check=True,timeout=15*60,creationflags=getattr(subprocess,"CREATE_NO_WINDOW",0))
    xyz,uv,texture=read_textured_obj(work/"textured.obj")
    xyz=(xyz-center)@alignment.T*metric_scale
    xyz[:,1]-=floor
    tex_h,tex_w=texture.shape[:2]
    samples=texture[np.clip(((1-uv[:,1])*(tex_h-1)).round().astype(int),0,tex_h-1),
                    np.clip((uv[:,0]*(tex_w-1)).round().astype(int),0,tex_w-1)]
    vertices=xyz.astype(">f4")
    colors=samples[:,::-1].astype(">f4")
    encoded=cv2.imencode(".png",texture)[1].tobytes()
    with (directory/"model.mesh").open("wb") as output:
        output.write(struct.pack(">ii",0x53434E32,vertices.size))
        output.write(vertices.tobytes());output.write(colors.tobytes())
        output.write(uv.astype(">f4").tobytes());output.write(struct.pack(">i",len(encoded)));output.write(encoded)
    cameras=(np.array([v["center"] for v in views])-center)@alignment.T
    azimuth=((np.arctan2(cameras[:,2],cameras[:,0])+math.pi)/(2*math.pi)*12).astype(int)%12
    elevation=np.arctan2(cameras[:,1],np.linalg.norm(cameras[:,[0,2]],axis=1))>.40
    sectors=np.bincount(azimuth+elevation.astype(int)*12,minlength=24)
    coverage=int((sectors>=2).sum()*100//24)
    complete=coverage>=75 and (sectors[:12]>=2).sum()>=9 and (sectors[12:]>=2).sum()>=9 and len(views)>=40 and topology["complete"]
    summary=f"{len(mesh.triangles)} tam giac; {topology['boundary']*100:.1f}% canh ho; ty le camera; UV anh that"
    update(job,100,"Da tao ban quet can xem lai hinh dang" if not complete else "Dat kiem tra du lieu; can xem lai vat that",
           state="done",triangles=len(xyz)//3,frames=len(frames),registered=len(views),fused=fused,
           coverage=coverage,complete=bool(complete),scaleEstimated=False,quality=summary,engineVersion=3)



def engine_ready():
    try:
        for name in ("numpy", "opencv-python-headless", "pycolmap", "open3d"):
            if not importlib.metadata.distribution(name).read_text("RECORD"):
                return False
        runtime=Path(__file__).resolve().parents[1]/".scan-runtime"
        return ((runtime/"mobilesam/mobile_sam.pt").is_file() and (runtime/"segmentation-deps/timm").is_dir()
                and all((runtime/"openmvs/vc17/x64/Release"/(name+".exe")).is_file()
                        for name in ("InterfaceCOLMAP","DensifyPointCloud","ReconstructMesh","RefineMesh","TextureMesh")))
    except importlib.metadata.PackageNotFoundError:
        return False


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        if args and str(args[0]).startswith("GET /jobs/"):
            return
        super().log_message(format,*args)

    def json_response(self, code, value):
        data=json.dumps(value,ensure_ascii=False).encode("utf-8")
        self.send_response(code);self.send_header("Content-Type","application/json; charset=utf-8")
        self.send_header("Content-Length",str(len(data)));self.end_headers();self.wfile.write(data)

    def do_GET(self):
        if self.path=="/health":
            mvs=Path(__file__).resolve().parents[1]/'.scan-runtime/openmvs/vc17/x64/Release/DensifyPointCloud.exe'
            return self.json_response(200,{"ready":engine_ready(),"engine":"MobileSAM + COLMAP + OpenMVS geometry/UV","version":3})
        if self.path=="/jobs":
            return self.json_response(200,{"jobs":[{"id":key,**value} for key,value in list(JOBS.items())]})
        parts=self.path.strip("/").split("/")
        if len(parts)<2 or parts[0]!="jobs" or parts[1] not in JOBS:
            return self.json_response(404,{"error":"Unknown job"})
        job=parts[1]
        if len(parts)==3 and parts[2]=="mesh" and JOBS[job]["state"]=="done":
            data=(ROOT/job/"model.mesh").read_bytes()
            self.send_response(200);self.send_header("Content-Type","application/octet-stream")
            self.send_header("Content-Length",str(len(data)));self.end_headers();self.wfile.write(data);return
        self.json_response(200,JOBS[job])

    def do_POST(self):
        if self.path!="/reconstruct":
            return self.json_response(404,{"error":"Unknown route"})
        try:
            length=int(self.headers.get("Content-Length",0))
            if not 0<length<=200_000_000:
                raise ValueError("Invalid upload size")
            archive=zipfile.ZipFile(io.BytesIO(self.rfile.read(length)))
            members=archive.infolist()
            if len(members)>122 or sum(f.file_size for f in members)>200_000_000:
                raise ValueError("Invalid capture archive")
            for member in members:
                name=member.filename
                if name!="manifest.json" and not (name.startswith("images/") and name.endswith(".jpg") and len(name.split("/"))==2):
                    raise ValueError("Unexpected file in capture")
                if ".." in name or "\\" in name or ":" in name:
                    raise ValueError("Unsafe capture path")
            job=str(uuid.uuid4());directory=ROOT/job;directory.mkdir()
            archive.extractall(directory)
            JOBS[job]={"state":"queued","progress":0,"message":"Dang cho xu ly"}
            threading.Thread(target=reconstruct,args=(job,directory),daemon=True).start()
            self.json_response(202,{"id":job})
        except Exception as error:
            self.json_response(400,{"error":str(error)})


if __name__=="__main__":
    print("Local scan server: http://127.0.0.1:8765 (Ctrl+C to stop)",flush=True)
    server=ThreadingHTTPServer(("127.0.0.1",8765),Handler)
    # Recover real captures after restarting the local process, including interrupted jobs.
    for directory in ROOT.iterdir():
        if not directory.is_dir() or not (directory/"manifest.json").is_file():
            continue
        try:
            uuid.UUID(directory.name)
            state=json.loads((directory/"status.json").read_text("utf-8")) if (directory/"status.json").is_file() else {}
            JOBS[directory.name]=state or {"state":"queued","progress":0,"message":"Khoi phuc bo anh da thu"}
            if JOBS[directory.name].get("state") in ("queued","processing"):
                threading.Thread(target=reconstruct,args=(directory.name,directory),daemon=True).start()
        except (ValueError,OSError):
            continue
    server.serve_forever()
