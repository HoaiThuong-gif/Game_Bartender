
from pathlib import Path
import numpy as np
import open3d as o3d

SCAN_ID = "86840f04e2164e47a8b4590fa1b1c074"

BASE_DIR = Path(__file__).resolve().parent

PLY_PATH = (
    BASE_DIR
    / "colmap_workspace"
    / SCAN_ID
    / "sparse"
    / "points3D.ply"
)

if not PLY_PATH.exists():
    raise FileNotFoundError(f"Không tìm thấy file: {PLY_PATH}")

# Đọc đám mây điểm
pcd = o3d.io.read_point_cloud(str(PLY_PATH))
points = np.asarray(pcd.points)

if len(points) == 0:
    raise RuntimeError("Point Cloud không có điểm 3D!")

print("=== THÔNG TIN POINT CLOUD ===")
print(f"Số điểm: {len(points)}")
print(f"Có màu RGB: {pcd.has_colors()}")
print(f"Tọa độ nhỏ nhất: {points.min(axis=0)}")
print(f"Tọa độ lớn nhất: {points.max(axis=0)}")

center = points.mean(axis=0)
print(f"Tâm đám mây điểm: {center}")

# Tạo bản sao để xem, không sửa file gốc
preview = o3d.geometry.PointCloud(pcd)

# Hiển thị điểm lớn hơn cho dễ quan sát
o3d.visualization.draw_geometries(
    [preview],
    window_name="COLMAP Sparse Point Cloud",
    width=1100,
    height=750,
)
