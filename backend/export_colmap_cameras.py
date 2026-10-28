
import json
import math
from pathlib import Path

# =====================================================
# CẤU HÌNH
# =====================================================

BASE_DIR = Path(__file__).resolve().parent

SCAN_ID = "86840f04e2164e47a8b4590fa1b1c074"

SCAN_DIR = BASE_DIR / "colmap_workspace" / SCAN_ID
SPARSE_DIR = SCAN_DIR / "sparse" / "0"

IMAGES_TXT = SPARSE_DIR / "images.txt"
OUTPUT_JSON = SCAN_DIR / "cameras.json"


# =====================================================
# CHUYỂN QUATERNION THÀNH MA TRẬN XOAY
# =====================================================

def quaternion_to_rotation(qw, qx, qy, qz):
    norm = math.sqrt(
        qw * qw + qx * qx + qy * qy + qz * qz
    )

    if norm == 0:
        raise ValueError("Quaternion không hợp lệ")

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


def transpose(matrix):
    return [
        [matrix[j][i] for j in range(3)]
        for i in range(3)
    ]


def multiply_matrix_vector(matrix, vector):
    return [
        sum(matrix[i][j] * vector[j] for j in range(3))
        for i in range(3)
    ]


# =====================================================
# ĐỌC IMAGES.TXT
# =====================================================

def export_cameras():
    if not IMAGES_TXT.is_file():
        raise FileNotFoundError(
            f"Không tìm thấy file: {IMAGES_TXT}"
        )

    cameras = []

    with IMAGES_TXT.open(
        "r",
        encoding="utf-8"
    ) as file:
        lines = [
            line.strip()
            for line in file
            if line.strip() and not line.startswith("#")
        ]

    # COLMAP images.txt có 2 dòng cho mỗi ảnh:
    # Dòng 1: thông tin ảnh và tư thế camera
    # Dòng 2: các điểm ảnh 2D
    for index in range(0, len(lines), 2):
        parts = lines[index].split()

        if len(parts) < 10:
            raise ValueError(
                f"Dòng thông tin ảnh không hợp lệ: {lines[index]}"
            )

        image_id = int(parts[0])

        qw, qx, qy, qz = map(float, parts[1:5])
        tx, ty, tz = map(float, parts[5:8])

        camera_id = int(parts[8])
        image_name = " ".join(parts[9:])

        # COLMAP lưu phép biến đổi world -> camera:
        # X_camera = R * X_world + t
        #
        # Tâm camera trong hệ tọa độ thế giới:
        # C = -R^T * t

        rotation = quaternion_to_rotation(
            qw, qx, qy, qz
        )

        rotation_inverse = transpose(rotation)

        center = multiply_matrix_vector(
            rotation_inverse,
            [-tx, -ty, -tz]
        )

        # Các trục camera trong hệ tọa độ thế giới.
        right = multiply_matrix_vector(
            rotation_inverse,
            [1, 0, 0]
        )

        down = multiply_matrix_vector(
            rotation_inverse,
            [0, 1, 0]
        )

        forward = multiply_matrix_vector(
            rotation_inverse,
            [0, 0, 1]
        )

        cameras.append({
            "image_id": image_id,
            "camera_id": camera_id,
            "image_name": image_name,
            "position": center,
            "right": right,
            "down": down,
            "forward": forward
        })

    result = {
        "scan_id": SCAN_ID,
        "camera_count": len(cameras),
        "cameras": cameras
    }

    with OUTPUT_JSON.open(
        "w",
        encoding="utf-8"
    ) as file:
        json.dump(
            result,
            file,
            ensure_ascii=False,
            indent=2
        )

    print("=" * 50)
    print("XUẤT CAMERA COLMAP THÀNH CÔNG")
    print("=" * 50)
    print(f"Số camera: {len(cameras)}")
    print(f"File JSON: {OUTPUT_JSON}")


if __name__ == "__main__":
    export_cameras()
