
import json
import re
import shutil
import threading
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4

from fastapi import (
    BackgroundTasks,
    FastAPI,
    File,
    HTTPException,
    UploadFile,
)
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from colmap_pipeline import process_scan


# =====================================================
# THƯ MỤC DỰ ÁN
# =====================================================

BASE_DIR = Path(__file__).resolve().parent

UPLOAD_DIR = BASE_DIR / "uploads"
MODEL_DIR = BASE_DIR / "models"
COLMAP_DIR = BASE_DIR / "colmap_workspace"
STATUS_DIR = BASE_DIR / "scan_status"

for directory in (
    UPLOAD_DIR,
    MODEL_DIR,
    COLMAP_DIR,
    STATUS_DIR,
):
    directory.mkdir(parents=True, exist_ok=True)


# =====================================================
# FASTAPI
# =====================================================

app = FastAPI(
    title="3D Object Scanner API",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

app.mount(
    "/models",
    StaticFiles(directory=str(MODEL_DIR)),
    name="models",
)


# =====================================================
# KHÓA XỬ LÝ COLMAP
# =====================================================

# COLMAP có thể sử dụng nhiều tài nguyên.
# Tạm thời chỉ cho phép một pipeline chạy mỗi lần.

COLMAP_LOCK = threading.Lock()


# =====================================================
# HÀM HỖ TRỢ
# =====================================================

def validate_scan_id(scan_id: str):
    if not re.fullmatch(r"[0-9a-f]{32}", scan_id):
        raise HTTPException(
            status_code=400,
            detail="Scan ID không hợp lệ",
        )


def get_pointcloud_path(scan_id: str) -> Path:
    return COLMAP_DIR / scan_id / "pointcloud.ply"


def get_cameras_path(scan_id: str) -> Path:
    return COLMAP_DIR / scan_id / "cameras.json"


def get_status_path(scan_id: str) -> Path:
    return STATUS_DIR / f"{scan_id}.json"


def find_video(scan_id: str):
    for extension in (".mp4", ".mov", ".m4v"):
        path = UPLOAD_DIR / f"{scan_id}{extension}"

        if path.is_file():
            return path

    return None


def now_iso():
    return datetime.now(timezone.utc).isoformat()


# =====================================================
# LƯU TRẠNG THÁI XỬ LÝ
# =====================================================

def save_scan_status(
    scan_id: str,
    status: str,
    message: str,
    **extra,
):
    status_path = get_status_path(scan_id)

    data = {
        "scan_id": scan_id,
        "status": status,
        "message": message,
        "updated_at": now_iso(),
        **extra,
    }

    # Ghi file tạm rồi thay thế để tránh Flutter
    # đọc phải JSON đang ghi dở.
    temp_path = STATUS_DIR / (
        f"{scan_id}.{uuid4().hex}.tmp"
    )

    try:
        with temp_path.open(
            "w",
            encoding="utf-8",
        ) as file:
            json.dump(
                data,
                file,
                ensure_ascii=False,
                indent=2,
            )

        temp_path.replace(status_path)

    finally:
        temp_path.unlink(missing_ok=True)

    return data


def load_scan_status(scan_id: str):
    status_path = get_status_path(scan_id)

    if not status_path.is_file():
        return None

    try:
        with status_path.open(
            "r",
            encoding="utf-8",
        ) as file:
            return json.load(file)

    except (OSError, json.JSONDecodeError):
        return None


# =====================================================
# CHẠY PIPELINE COLMAP TRONG NỀN
# =====================================================

def run_scan_pipeline(scan_id: str):
    save_scan_status(
        scan_id,
        "processing",
        "Đang chờ lượt xử lý COLMAP...",
        stage="queued",
    )

    with COLMAP_LOCK:
        save_scan_status(
            scan_id,
            "processing",
            "Đang dựng mô hình 3D bằng COLMAP...",
            stage="reconstruction",
        )

        try:
            result = process_scan(scan_id)

            pointcloud_path = get_pointcloud_path(scan_id)
            cameras_path = get_cameras_path(scan_id)

            if not (
                pointcloud_path.is_file()
                and cameras_path.is_file()
            ):
                raise RuntimeError(
                    "Pipeline hoàn tất nhưng thiếu "
                    "pointcloud.ply hoặc cameras.json."
                )

            save_scan_status(
                scan_id,
                "completed",
                "Đã dựng mô hình 3D thành công.",
                stage="completed",
                result_type="pointcloud",
                pointcloud_url=(
                    f"/scan/{scan_id}/pointcloud"
                ),
                cameras_url=(
                    f"/scan/{scan_id}/cameras"
                ),
                model_url=None,
                selected_sparse_model=(
                    result.get("selected_sparse_model")
                ),
                camera_count=result.get("camera_count"),
                point_count=result.get("point_count"),
            )

            print(
                f"\n[SCAN COMPLETED] {scan_id}",
                flush=True,
            )

        except Exception as exc:
            error_message = str(exc)

            save_scan_status(
                scan_id,
                "failed",
                "Không thể dựng mô hình 3D.",
                stage="failed",
                error=error_message,
            )

            print(
                f"\n[SCAN FAILED] {scan_id}: "
                f"{error_message}",
                flush=True,
            )


# =====================================================
# KIỂM TRA SERVER
# =====================================================

@app.get("/")
def home():
    return {
        "message": "3D Object Scanner API",
        "status": "running",
        "version": "2.0.0",
    }


@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "3D Object Scanner Backend",
    }


# =====================================================
# UPLOAD VIDEO VÀ TỰ ĐỘNG XỬ LÝ
# =====================================================

@app.post("/scan/upload")
def upload_scan(
    background_tasks: BackgroundTasks,
    video: UploadFile = File(...),
):
    extension = Path(
        video.filename or ""
    ).suffix.lower()

    if extension not in {
        ".mp4",
        ".mov",
        ".m4v",
    }:
        raise HTTPException(
            status_code=400,
            detail=(
                "Chỉ hỗ trợ video MP4, MOV hoặc M4V"
            ),
        )

    scan_id = uuid4().hex
    video_filename = f"{scan_id}{extension}"
    video_path = UPLOAD_DIR / video_filename

    try:
        with video_path.open("wb") as output:
            shutil.copyfileobj(
                video.file,
                output,
            )

    except Exception as exc:
        video_path.unlink(missing_ok=True)

        raise HTTPException(
            status_code=500,
            detail="Không thể lưu video",
        ) from exc

    finally:
        video.file.close()

    save_scan_status(
        scan_id,
        "processing",
        "Đã nhận video. Đang chờ xử lý 3D...",
        stage="queued",
    )

    background_tasks.add_task(
        run_scan_pipeline,
        scan_id,
    )

    return {
        "scan_id": scan_id,
        "status": "processing",
        "message": (
            "Đã nhận video và bắt đầu "
            "quy trình dựng 3D."
        ),
        "video_filename": video_filename,
    }


# =====================================================
# TẢI POINT CLOUD
# =====================================================

@app.get("/scan/{scan_id}/pointcloud")
def download_pointcloud(scan_id: str):
    validate_scan_id(scan_id)

    pointcloud_path = get_pointcloud_path(
        scan_id
    )

    if not pointcloud_path.is_file():
        raise HTTPException(
            status_code=404,
            detail=(
                "Chưa có file Point Cloud "
                "cho bản quét này"
            ),
        )

    return FileResponse(
        path=pointcloud_path,
        media_type="application/octet-stream",
        filename=f"{scan_id}.ply",
        content_disposition_type="inline",
    )


# =====================================================
# LẤY DỮ LIỆU CAMERA COLMAP
# =====================================================

@app.get("/scan/{scan_id}/cameras")
def get_scan_cameras(scan_id: str):
    validate_scan_id(scan_id)

    cameras_path = get_cameras_path(
        scan_id
    )

    if not cameras_path.is_file():
        raise HTTPException(
            status_code=404,
            detail=(
                "Chưa có dữ liệu camera "
                "cho bản quét này"
            ),
        )

    return FileResponse(
        path=cameras_path,
        media_type="application/json",
    )


# =====================================================
# KIỂM TRA TRẠNG THÁI BẢN QUÉT
# =====================================================

@app.get("/scan/{scan_id}")
def get_scan_status(scan_id: str):
    validate_scan_id(scan_id)

    video_path = find_video(scan_id)

    if video_path is None:
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy bản quét",
        )

    pointcloud_path = get_pointcloud_path(
        scan_id
    )

    cameras_path = get_cameras_path(
        scan_id
    )

    model_path = MODEL_DIR / f"{scan_id}.glb"

    saved_status = load_scan_status(
        scan_id
    )

    # Nếu đã có đầy đủ kết quả Point Cloud,
    # ưu tiên kết quả hoàn chỉnh.
    if (
        pointcloud_path.is_file()
        and cameras_path.is_file()
    ):
        return {
            "scan_id": scan_id,
            "status": "completed",
            "message": (
                "Đã dựng mô hình 3D thành công."
            ),
            "result_type": "pointcloud",
            "pointcloud_url": (
                f"/scan/{scan_id}/pointcloud"
            ),
            "cameras_url": (
                f"/scan/{scan_id}/cameras"
            ),
            "model_url": None,
            "selected_sparse_model": (
                saved_status.get(
                    "selected_sparse_model"
                )
                if saved_status else None
            ),
            "camera_count": (
                saved_status.get("camera_count")
                if saved_status else None
            ),
            "point_count": (
                saved_status.get("point_count")
                if saved_status else None
            ),
        }

    # Giữ tương thích với mô hình GLB cũ.
    if model_path.is_file():
        return {
            "scan_id": scan_id,
            "status": "completed",
            "message": (
                "Đã có mô hình 3D."
            ),
            "result_type": "mesh",
            "model_url": (
                f"/models/{scan_id}.glb"
            ),
            "pointcloud_url": None,
            "cameras_url": None,
        }

    if saved_status is not None:
        return {
            "scan_id": scan_id,
            "status": saved_status.get(
                "status", "processing"
            ),
            "message": saved_status.get(
                "message", ""
            ),
            "stage": saved_status.get("stage"),
            "error": saved_status.get("error"),
            "result_type": None,
            "model_url": None,
            "pointcloud_url": None,
            "cameras_url": None,
        }

    # Dành cho các video upload trước khi
    # có chức năng xử lý tự động.
    return {
        "scan_id": scan_id,
        "status": "uploaded",
        "message": (
            "Video đã được lưu, "
            "chưa bắt đầu xử lý tự động."
        ),
        "result_type": None,
        "model_url": None,
        "pointcloud_url": None,
        "cameras_url": None,
    }
