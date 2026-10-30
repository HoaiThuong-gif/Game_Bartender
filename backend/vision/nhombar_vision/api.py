import asyncio
from contextlib import asynccontextmanager
import logging
import threading
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from .settings import MAX_BYTES, UPLOAD_TIMEOUT
from .worker import ProcessDetector, VisionFailure

log = logging.getLogger(__name__)
ERRORS = {
    'busy': (429, 'Máy đang nhận diện ảnh khác. Hãy thử lại nhé.'),
    'not_ready': (503, 'Máy nhận diện chưa sẵn sàng. Hãy thử lại sau một chút.'),
    'inference_timeout': (504, 'Nhận diện mất quá lâu. Hãy thử lại.'),
    'inference_failed': (500, 'Chưa nhận diện được ảnh này. Hãy thử lại.'),
    'invalid_image': (422, 'Ảnh không đọc được. Hãy chọn ảnh khác.'),
    'unsupported_image': (415, 'Hãy dùng ảnh JPEG hoặc PNG.'),
    'too_many_pixels': (413, 'Ảnh quá lớn. Hãy chọn ảnh nhỏ hơn.'),
    'too_large': (413, 'Ảnh cần nhỏ hơn 8 MB.'),
    'upload_timeout': (408, 'Gửi ảnh mất quá lâu. Hãy thử lại.'),
}


def failure(code):
    status, message = ERRORS.get(code, ERRORS['inference_failed'])
    return JSONResponse({'error': {'code': code, 'message': message}}, status_code=status,
                        headers={'Cache-Control': 'no-store'})


def create_app(detector=None):
    detector = detector if detector is not None else ProcessDetector()
    gate = threading.BoundedSemaphore(1)

    @asynccontextmanager
    async def lifespan(app):
        try:
            await asyncio.to_thread(detector.start)
            yield
        finally:
            await asyncio.to_thread(detector.close)

    app = FastAPI(title='Nhombar YOLO26n MVP', lifespan=lifespan)

    @app.get('/health')
    async def health():
        return JSONResponse({'ready': detector.ready, 'model': 'yolo26n'},
                            status_code=200 if detector.ready else 503,
                            headers={'Cache-Control': 'no-store'})

    @app.post('/api/v1/detect')
    async def detect(request: Request):
        if request.headers.get('content-type', '').split(';')[0].lower() not in ('image/jpeg', 'image/png'):
            return failure('unsupported_image')
        if request.headers.get('content-encoding', 'identity').lower() != 'identity':
            return failure('unsupported_image')
        if not gate.acquire(blocking=False):
            return failure('busy')
        try:
            if not detector.ready:
                return failure('not_ready')
            length = request.headers.get('content-length')
            if length is not None:
                try:
                    if int(length) < 0 or int(length) > MAX_BYTES:
                        return failure('too_large')
                except ValueError:
                    return failure('invalid_image')
            payload = bytearray()
            try:
                async with asyncio.timeout(UPLOAD_TIMEOUT):
                    async for chunk in request.stream():
                        if len(payload) + len(chunk) > MAX_BYTES:
                            return failure('too_large')
                        payload.extend(chunk)
            except TimeoutError:
                return failure('upload_timeout')
            if not payload:
                return failure('invalid_image')
            result = await asyncio.to_thread(detector.detect, bytes(payload),
                request.headers['content-type'].split(';')[0].lower())
            return JSONResponse(result, headers={'Cache-Control': 'no-store'})
        except VisionFailure as error:
            return failure(error.code)
        except Exception:
            log.exception('Photo detection request failed')
            return failure('inference_failed')
        finally:
            gate.release()

    return app


app = create_app()
