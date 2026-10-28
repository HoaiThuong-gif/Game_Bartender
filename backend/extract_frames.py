
from pathlib import Path
import argparse
import json

import cv2


BASE_DIR = Path(__file__).resolve().parent
UPLOAD_DIR = BASE_DIR / "uploads"
FRAMES_DIR = BASE_DIR / "frames"

FRAMES_DIR.mkdir(parents=True, exist_ok=True)


def extract_frames(
    video_path: Path,
    interval_seconds: float = 0.5,
    blur_threshold: float = 60.0,
    max_frames: int = 200,
):
    if not video_path.is_file():
        raise FileNotFoundError(
            f"Không tìm thấy video: {video_path}"
        )

    if interval_seconds <= 0:
        raise ValueError(
            "interval_seconds phải lớn hơn 0"
        )

    if max_frames <= 0:
        raise ValueError(
            "max_frames phải lớn hơn 0"
        )

    scan_id = video_path.stem
    output_dir = FRAMES_DIR / scan_id
    output_dir.mkdir(parents=True, exist_ok=True)

    capture = cv2.VideoCapture(str(video_path))

    if not capture.isOpened():
        raise RuntimeError(
            "Không thể đọc video bằng OpenCV"
        )

    fps = capture.get(cv2.CAP_PROP_FPS)
    total_frames = int(
        capture.get(cv2.CAP_PROP_FRAME_COUNT)
    )

    if fps <= 0:
        capture.release()
        raise RuntimeError(
            "Không đọc được FPS của video"
        )

    duration = total_frames / fps

    print(f"Video: {video_path.name}")
    print(f"FPS: {fps:.2f}")
    print(f"Thời lượng: {duration:.2f} giây")
    print(f"Tổng khung hình: {total_frames}")

    saved_count = 0
    rejected_count = 0
    sampled_count = 0

    sample_step = max(
        1,
        round(fps * interval_seconds),
    )

    frame_index = 0

    try:
        while True:
            success, frame = capture.read()

            if not success:
                break

            if frame_index % sample_step != 0:
                frame_index += 1
                continue

            sampled_count += 1

            gray = cv2.cvtColor(
                frame,
                cv2.COLOR_BGR2GRAY,
            )

            sharpness = cv2.Laplacian(
                gray,
                cv2.CV_64F,
            ).var()

            if sharpness < blur_threshold:
                rejected_count += 1
                frame_index += 1
                continue

            saved_count += 1

            filename = (
                f"frame_{saved_count:04d}.jpg"
            )

            output_path = output_dir / filename

            success = cv2.imwrite(
                str(output_path),
                frame,
                [
                    cv2.IMWRITE_JPEG_QUALITY,
                    95,
                ],
            )

            if not success:
                saved_count -= 1
                raise RuntimeError(
                    f"Không thể lưu ảnh: {output_path}"
                )

            print(
                f"Đã lưu {filename} "
                f"| Độ nét: {sharpness:.1f}"
            )

            if saved_count >= max_frames:
                break

            frame_index += 1
    finally:
        capture.release()

    result = {
        "scan_id": scan_id,
        "video": video_path.name,
        "fps": round(fps, 2),
        "duration_seconds": round(duration, 2),
        "sampled_frames": sampled_count,
        "saved_frames": saved_count,
        "rejected_blurry_frames": rejected_count,
        "output_directory": str(output_dir),
    }

    report_path = output_dir / "report.json"

    report_path.write_text(
        json.dumps(
            result,
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )

    print("\n=== KẾT QUẢ ===")
    print(f"Ảnh đã lưu: {saved_count}")
    print(f"Ảnh bị loại: {rejected_count}")
    print(f"Thư mục: {output_dir}")

    return result


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Trích xuất ảnh từ video "
            "để chuẩn bị dựng mô hình 3D"
        )
    )

    parser.add_argument(
        "video",
        help="Đường dẫn video MP4",
    )

    parser.add_argument(
        "--interval",
        type=float,
        default=0.5,
        help="Khoảng cách lấy ảnh (giây)",
    )

    parser.add_argument(
        "--blur-threshold",
        type=float,
        default=60.0,
        help="Ngưỡng lọc ảnh mờ",
    )

    parser.add_argument(
        "--max-frames",
        type=int,
        default=200,
        help="Số ảnh tối đa",
    )

    args = parser.parse_args()

    video_path = Path(args.video)

    if not video_path.is_absolute():
        video_path = BASE_DIR / video_path

    extract_frames(
        video_path=video_path,
        interval_seconds=args.interval,
        blur_threshold=args.blur_threshold,
        max_frames=args.max_frames,
    )


if __name__ == "__main__":
    main()
