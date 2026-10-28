
import json
import math
import re
import subprocess
import sys
from pathlib import Path


# =====================================================
# CẤU HÌNH
# =====================================================

BASE_DIR = Path(__file__).resolve().parent

UPLOAD_DIR = BASE_DIR / "uploads"
WORKSPACE_DIR = BASE_DIR / "colmap_workspace"

COLMAP_EXE = r"D:\COLMAP\COLMAP.bat"
FFMPEG_EXE = "ffmpeg"

FRAME_FPS = 2
MAX_IMAGE_SIZE = 1600


# =====================================================
# CHẠY LỆNH HỆ THỐNG
# =====================================================

def run_command(command):
    command = [str(item) for item in command]

    print("\n" + "=" * 60)
    print("ĐANG CHẠY:", " ".join(command))
    print("=" * 60, flush=True)

    subprocess.run(command, check=True)


# =====================================================
# KIỂM TRA SCAN ID
# =====================================================

def validate_scan_id(scan_id):
    if not re.fullmatch(r"[0-9a-f]{32}", scan_id):
        raise ValueError("Scan ID không hợp lệ.")


# =====================================================
# TÌM VIDEO
# =====================================================

def find_video(scan_id):
    validate_scan_id(scan_id)

    for extension in (".mp4", ".mov", ".m4v"):
        video_path = UPLOAD_DIR / f"{scan_id}{extension}"

        if video_path.is_file():
            return video_path

    raise FileNotFoundError(
        f"Không tìm thấy video cho scan_id: {scan_id}"
    )


# =====================================================
# TRÍCH XUẤT FRAME BẰNG FFMPEG
# =====================================================

def extract_frames(video_path, images_dir):
    images_dir.mkdir(parents=True, exist_ok=True)

    for image_path in images_dir.glob("frame_*.jpg"):
        image_path.unlink()

    run_command([
        FFMPEG_EXE,
        "-y",
        "-i", video_path,
        "-vf", f"fps={FRAME_FPS}",
        "-q:v", "2",
        images_dir / "frame_%04d.jpg",
    ])

    images = sorted(images_dir.glob("frame_*.jpg"))

    if len(images) < 3:
        raise RuntimeError(
            "Video không tạo đủ ảnh để dựng 3D."
        )

    print(
        f"\nĐã trích xuất thành công {len(images)} ảnh.",
        flush=True,
    )


# =====================================================
# CHUYỂN QUATERNION THÀNH MA TRẬN XOAY
# =====================================================

def quaternion_to_rotation(qw, qx, qy, qz):
    norm = math.sqrt(
        qw * qw + qx * qx + qy * qy + qz * qz
    )

    if norm == 0:
        raise ValueError("Quaternion không hợp lệ.")

    qw /= norm
    qx /= norm
    qy /= norm
    qz /= norm

    return [
        [
            1 - 2 * (qy * qy + qz * qz),
            2 * (qx * qy - qw * qz),
            2 * (qx * qz + qw * qy),
        ],
        [
            2 * (qx * qy + qw * qz),
            1 - 2 * (qx * qx + qz * qz),
            2 * (qy * qz - qw * qx),
        ],
        [
            2 * (qx * qz - qw * qy),
            2 * (qy * qz + qw * qx),
            1 - 2 * (qx * qx + qy * qy),
        ],
    ]


# =====================================================
# PHÉP TOÁN MA TRẬN
# =====================================================

def matrix_transpose(matrix):
    return [
        [matrix[j][i] for j in range(3)]
        for i in range(3)
    ]


def matrix_vector_multiply(matrix, vector):
    return [
        sum(
            matrix[i][j] * vector[j]
            for j in range(3)
        )
        for i in range(3)
    ]


# =====================================================
# ĐỌC DANH SÁCH CAMERA TỪ IMAGES.TXT
# =====================================================

def read_camera_poses(images_txt):
    if not images_txt.is_file():
        raise FileNotFoundError(
            f"Không tìm thấy file: {images_txt}"
        )

    with images_txt.open(
        "r",
        encoding="utf-8",
    ) as file:
        lines = [
            line.strip()
            for line in file
            if not line.lstrip().startswith("#")
        ]

    # COLMAP dùng 2 dòng cho mỗi ảnh.
    # Dòng thứ hai chứa các điểm 2D và có thể rỗng.
    while lines and not lines[0]:
        lines.pop(0)

    while lines and not lines[-1]:
        lines.pop()

    if len(lines) % 2 != 0:
        lines.append("")

    cameras = []

    for index in range(0, len(lines), 2):
        parts = lines[index].split()

        if len(parts) < 10:
            raise ValueError(
                "Dữ liệu camera không hợp lệ "
                f"tại dòng {index + 1} của {images_txt}"
            )

        image_id = int(parts[0])

        qw, qx, qy, qz = map(
            float, parts[1:5]
        )

        tx, ty, tz = map(
            float, parts[5:8]
        )

        camera_id = int(parts[8])
        image_name = " ".join(parts[9:])

        rotation = quaternion_to_rotation(
            qw, qx, qy, qz
        )

        rotation_inverse = matrix_transpose(
            rotation
        )

        position = matrix_vector_multiply(
            rotation_inverse,
            [-tx, -ty, -tz],
        )

        right = matrix_vector_multiply(
            rotation_inverse,
            [1, 0, 0],
        )

        down = matrix_vector_multiply(
            rotation_inverse,
            [0, 1, 0],
        )

        forward = matrix_vector_multiply(
            rotation_inverse,
            [0, 0, 1],
        )

        cameras.append({
            "image_id": image_id,
            "camera_id": camera_id,
            "image_name": image_name,
            "position": position,
            "right": right,
            "down": down,
            "forward": forward,
        })

    return cameras


# =====================================================
# XUẤT CAMERAS.JSON
# =====================================================

def export_cameras(images_txt, output_json, scan_id):
    cameras = read_camera_poses(images_txt)

    if not cameras:
        raise RuntimeError(
            "Không tìm thấy camera nào trong images.txt."
        )

    result = {
        "scan_id": scan_id,
        "camera_count": len(cameras),
        "cameras": cameras,
    }

    output_json.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with output_json.open(
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            result,
            file,
            ensure_ascii=False,
            indent=2,
        )

    print(
        f"\nĐã xuất thành công {len(cameras)} camera.",
        flush=True,
    )


# =====================================================
# ĐẾM SỐ ĐIỂM 3D TỪ POINTS3D.TXT
# =====================================================

def count_3d_points(points_txt):
    if not points_txt.is_file():
        return 0

    count = 0

    with points_txt.open(
        "r",
        encoding="utf-8",
    ) as file:
        for line in file:
            line = line.strip()

            if line and not line.startswith("#"):
                count += 1

    return count


# =====================================================
# KIỂM TRA CÁC BẢN TÁI DỰNG SPARSE
# =====================================================

def find_sparse_models(sparse_dir):
    if not sparse_dir.is_dir():
        raise RuntimeError(
            "Không tìm thấy thư mục Sparse."
        )

    models = []

    for model_dir in sparse_dir.iterdir():
        if not model_dir.is_dir():
            continue

        # COLMAP tạo các thư mục 0, 1, 2, ...
        if not model_dir.name.isdigit():
            continue

        has_binary = (
            (model_dir / "cameras.bin").is_file()
            and (model_dir / "images.bin").is_file()
            and (model_dir / "points3D.bin").is_file()
        )

        has_text = (
            (model_dir / "cameras.txt").is_file()
            and (model_dir / "images.txt").is_file()
            and (model_dir / "points3D.txt").is_file()
        )

        if has_binary or has_text:
            models.append(model_dir)

    models.sort(key=lambda path: int(path.name))

    if not models:
        raise RuntimeError(
            "COLMAP không tạo được mô hình Sparse hợp lệ."
        )

    return models


# =====================================================
# TỰ ĐỘNG CHỌN BẢN TÁI DỰNG TỐT NHẤT
# =====================================================

def select_best_sparse_model(sparse_dir):
    models = find_sparse_models(sparse_dir)

    print("\n" + "=" * 60)
    print("ĐÁNH GIÁ CÁC BẢN TÁI DỰNG SPARSE")
    print("=" * 60, flush=True)

    candidates = []

    for model_dir in models:
        images_txt = model_dir / "images.txt"
        points_txt = model_dir / "points3D.txt"

        # Chuyển sang TXT nếu chưa có đủ dữ liệu.
        if not (
            images_txt.is_file()
            and points_txt.is_file()
        ):
            run_command([
                COLMAP_EXE,
                "model_converter",
                "--input_path", model_dir,
                "--output_path", model_dir,
                "--output_type", "TXT",
            ])

        cameras = read_camera_poses(images_txt)
        camera_count = len(cameras)
        point_count = count_3d_points(points_txt)

        print(
            f"Sparse {model_dir.name}: "
            f"{camera_count} camera, "
            f"{point_count} điểm 3D",
            flush=True,
        )

        if camera_count > 0 and point_count > 0:
            candidates.append({
                "path": model_dir,
                "camera_count": camera_count,
                "point_count": point_count,
            })

    if not candidates:
        raise RuntimeError(
            "Không có bản tái dựng Sparse nào hợp lệ."
        )

    # Ưu tiên số camera đăng ký.
    # Nếu bằng nhau, ưu tiên số điểm 3D.
    best = max(
        candidates,
        key=lambda item: (
            item["camera_count"],
            item["point_count"],
        ),
    )

    print("\nĐÃ CHỌN BẢN TÁI DỰNG:")
    print(f"Thư mục: {best['path']}")
    print(f"Camera: {best['camera_count']}")
    print(f"Điểm 3D: {best['point_count']}")

    return best


# =====================================================
# PIPELINE COLMAP TỰ ĐỘNG
# =====================================================

def process_scan(scan_id):
    validate_scan_id(scan_id)

    video_path = find_video(scan_id)

    scan_dir = WORKSPACE_DIR / scan_id
    images_dir = scan_dir / "images"
    sparse_dir = scan_dir / "sparse"
    database_path = scan_dir / "database.db"

    pointcloud_path = scan_dir / "pointcloud.ply"
    cameras_path = scan_dir / "cameras.json"

    scan_dir.mkdir(
        parents=True,
        exist_ok=True,
    )

    print("\n" + "=" * 60)
    print(f"BẮT ĐẦU XỬ LÝ SCAN: {scan_id}")
    print(f"Video: {video_path}")
    print("=" * 60, flush=True)

    # BẢO VỆ BẢN QUÉT ĐÃ HOÀN THÀNH
    if (
        pointcloud_path.is_file()
        and cameras_path.is_file()
    ):
        print(
            "\nBản quét đã hoàn thành. "
            "Không xử lý đè dữ liệu."
        )

        return {
            "scan_id": scan_id,
            "status": "completed",
            "pointcloud_path": str(pointcloud_path),
            "cameras_path": str(cameras_path),
        }

    # KHÔNG TỰ ĐỘNG XÓA DỮ LIỆU XỬ LÝ DỞ
    if database_path.exists() or sparse_dir.exists():
        raise RuntimeError(
            "Phát hiện dữ liệu COLMAP từ lần chạy trước "
            f"trong: {scan_dir}\n"
            "Pipeline sẽ không tự xóa dữ liệu này. "
            "Hãy kiểm tra trước khi chạy lại."
        )

    # -------------------------------------------------
    # BƯỚC 1: TRÍCH XUẤT FRAME
    # -------------------------------------------------

    print("\n[1/7] TRÍCH XUẤT FRAME")

    extract_frames(
        video_path,
        images_dir,
    )

    # -------------------------------------------------
    # BƯỚC 2: FEATURE EXTRACTION - CPU
    # -------------------------------------------------

    print("\n[2/7] FEATURE EXTRACTION (CPU)")

    run_command([
        COLMAP_EXE,
        "feature_extractor",
        "--database_path", database_path,
        "--image_path", images_dir,
        "--ImageReader.single_camera", "1",
        "--FeatureExtraction.use_gpu", "0",
        "--FeatureExtraction.max_image_size",
        str(MAX_IMAGE_SIZE),
    ])

    # -------------------------------------------------
    # BƯỚC 3: FEATURE MATCHING - CPU
    # -------------------------------------------------

    print("\n[3/7] FEATURE MATCHING (CPU)")

    run_command([
        COLMAP_EXE,
        "sequential_matcher",
        "--database_path", database_path,
        "--FeatureMatching.use_gpu", "0",
    ])

    # -------------------------------------------------
    # BƯỚC 4: SPARSE RECONSTRUCTION
    # -------------------------------------------------

    print("\n[4/7] SPARSE RECONSTRUCTION")

    sparse_dir.mkdir(
        parents=True,
        exist_ok=True,
    )

    run_command([
        COLMAP_EXE,
        "mapper",
        "--database_path", database_path,
        "--image_path", images_dir,
        "--output_path", sparse_dir,
    ])

    # -------------------------------------------------
    # BƯỚC 5: CHỌN BẢN TÁI DỰNG TỐT NHẤT
    # -------------------------------------------------

    print("\n[5/7] CHỌN BẢN SPARSE TỐT NHẤT")

    best = select_best_sparse_model(sparse_dir)
    model_dir = best["path"]

    # -------------------------------------------------
    # BƯỚC 6: XUẤT POINT CLOUD
    # -------------------------------------------------

    print("\n[6/7] XUẤT POINT CLOUD")

    run_command([
        COLMAP_EXE,
        "model_converter",
        "--input_path", model_dir,
        "--output_path", pointcloud_path,
        "--output_type", "PLY",
    ])

    if not pointcloud_path.is_file():
        raise RuntimeError(
            "Không tạo được file pointcloud.ply."
        )

    # -------------------------------------------------
    # BƯỚC 7: XUẤT CAMERAS.JSON
    # -------------------------------------------------

    print("\n[7/7] XUẤT CAMERAS.JSON")

    export_cameras(
        model_dir / "images.txt",
        cameras_path,
        scan_id,
    )

    # -------------------------------------------------
    # HOÀN THÀNH
    # -------------------------------------------------

    print("\n" + "=" * 60)
    print("XỬ LÝ HOÀN THÀNH")
    print("=" * 60)
    print(f"Bản Sparse được chọn: {model_dir.name}")
    print(f"Số camera: {best['camera_count']}")
    print(f"Số điểm 3D: {best['point_count']}")
    print(f"Point Cloud: {pointcloud_path}")
    print(f"Cameras: {cameras_path}")

    return {
        "scan_id": scan_id,
        "status": "completed",
        "selected_sparse_model": model_dir.name,
        "camera_count": best["camera_count"],
        "point_count": best["point_count"],
        "pointcloud_path": str(pointcloud_path),
        "cameras_path": str(cameras_path),
    }


# =====================================================
# CHẠY TRỰC TIẾP TỪ TERMINAL
# =====================================================

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(
            "Cách dùng: python colmap_pipeline.py <scan_id>"
        )
        sys.exit(1)

    try:
        process_scan(sys.argv[1])

    except Exception as exc:
        print(
            f"\nLỖI XỬ LÝ COLMAP: {exc}",
            file=sys.stderr,
        )
        sys.exit(1)
