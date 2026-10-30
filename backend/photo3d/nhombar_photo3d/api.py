import asyncio
from contextlib import asynccontextmanager
import logging
import time
import uuid

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, Response
from .inference import decode_image, InputError
from .settings import MAX_BYTES, JOB_TTL
from .worker import ProcessReconstructor, EngineError

log = logging.getLogger(__name__)
MESSAGES = {
    'busy': 'Máy đang tạo mô hình khác. Hãy thử lại sau nhé.',
    'not_ready': 'Máy tạo mô hình chưa sẵn sàng. Hãy kiểm tra máy tính.',
    'inference_timeout': 'Tạo mô hình mất quá lâu. Hãy thử ảnh khác.',
    'inference_failed': 'Chưa tạo được mô hình. Hãy thử ảnh rõ hơn.',
    'invalid_mesh': 'Chưa tạo được hình khối phù hợp. Hãy thử ảnh khác.',
    'no_foreground': 'Chưa tách được đồ vật. Hãy chụp một vật trên nền đơn giản.',
    'invalid_image': 'Ảnh không đọc được. Hãy chọn ảnh khác.',
    'unsupported_image': 'Hãy dùng ảnh JPEG hoặc PNG.',
    'too_many_pixels': 'Ảnh quá lớn. Hãy chọn ảnh nhỏ hơn 16 megapixel.',
    'too_large': 'Hãy chọn ảnh nhỏ hơn 8 MB.',
    'upload_timeout': 'Gửi ảnh mất quá lâu. Hãy thử lại.',
    'not_found': 'Phiên tạo mô hình đã hết hạn. Hãy gửi lại ảnh.',
    'not_done': 'Mô hình chưa tạo xong.',
}


def failure(code, status):
    return JSONResponse({'error': {'code': code, 'message': MESSAGES.get(code, MESSAGES['inference_failed'])}},
                        status_code=status, headers={'Cache-Control': 'no-store'})


def create_app(engine=None):
    engine = engine if engine is not None else ProcessReconstructor()
    jobs = {}
    tasks = set()
    occupied = False

    def cleanup():
        now = time.monotonic()
        for key, job in list(jobs.items()):
            if job['state'] in ('done', 'error') and now - job['created'] > JOB_TTL:
                del jobs[key]
        while len(jobs) >= 8:
            key = next((key for key, job in jobs.items() if job['state'] in ('done', 'error')), None)
            if key is None:
                break
            del jobs[key]

    async def run(job, payload, mime):
        nonlocal occupied
        try:
            def stage(value):
                if value in ('preprocessing', 'reconstructing', 'extracting', 'exporting'):
                    job['state'] = value
            job['mesh'] = await asyncio.to_thread(engine.generate, payload, mime, stage)
            job['state'] = 'done'
        except EngineError as error:
            job.update(state='error', error=str(error))
        except Exception:
            log.exception('Photo-to-3D job failed')
            job.update(state='error', error='inference_failed')
        finally:
            occupied = False

    @asynccontextmanager
    async def lifespan(app):
        await asyncio.to_thread(engine.start)
        try:
            yield
        finally:
            engine.close()
            if tasks:
                await asyncio.gather(*tasks, return_exceptions=True)
            jobs.clear()

    app = FastAPI(title='NhomBar Photo to 3D — TripoSR', lifespan=lifespan)

    @app.middleware('http')
    async def no_cache(request, call_next):
        response = await call_next(request)
        response.headers['Cache-Control'] = 'no-store'
        return response

    @app.get('/health')
    async def health():
        cleanup()
        return JSONResponse({'ready': engine.ready, 'model': 'TripoSR', 'busy': occupied,
                             'device': 'cpu'}, status_code=200 if engine.ready else 503)

    @app.post('/api/v1/photo-models')
    async def create(request: Request):
        nonlocal occupied
        mime = request.headers.get('content-type', '').split(';')[0].lower()
        if mime not in ('image/jpeg', 'image/png') or request.headers.get('content-encoding', 'identity') != 'identity':
            return failure('unsupported_image', 415)
        if occupied:
            return failure('busy', 429)
        if not engine.ready:
            return failure('not_ready', 503)
        occupied = True
        admitted = False
        try:
            try:
                length = int(request.headers.get('content-length', '0'))
            except ValueError:
                return failure('invalid_image', 422)
            if length < 0 or length > MAX_BYTES:
                return failure('too_large', 413)
            payload = bytearray()
            async with asyncio.timeout(10):
                async for chunk in request.stream():
                    payload.extend(chunk)
                    if len(payload) > MAX_BYTES:
                        return failure('too_large', 413)
            image = await asyncio.to_thread(decode_image, bytes(payload), mime)
            image.close()
            cleanup()
            key = str(uuid.uuid4())
            job = {'id': key, 'state': 'queued', 'created': time.monotonic()}
            jobs[key] = job
            task = asyncio.create_task(run(job, bytes(payload), mime))
            tasks.add(task)
            task.add_done_callback(tasks.discard)
            admitted = True
            return JSONResponse({'id': key, 'state': 'queued', 'model': 'TripoSR'}, status_code=202)
        except InputError as error:
            code = str(error)
            return failure(code, 413 if code == 'too_many_pixels' else 415 if code == 'unsupported_image' else 422)
        except TimeoutError:
            return failure('upload_timeout', 408)
        finally:
            if not admitted:
                occupied = False

    def find(key):
        cleanup()
        return jobs.get(key)

    @app.get('/api/v1/photo-models/{key}')
    async def status(key: str):
        job = find(key)
        if job is None:
            return failure('not_found', 404)
        response = {'id': key, 'state': job['state'], 'model': 'TripoSR'}
        if job['state'] == 'error':
            code = job.get('error', 'inference_failed')
            response['error'] = {'code': code, 'message': MESSAGES.get(code, MESSAGES['inference_failed'])}
        return response

    @app.get('/api/v1/photo-models/{key}/mesh')
    async def mesh(key: str):
        job = find(key)
        if job is None:
            return failure('not_found', 404)
        if job['state'] != 'done':
            return failure('not_done', 409)
        return Response(job['mesh'], media_type='application/octet-stream',
                        headers={'Content-Disposition': 'attachment; filename="model.mesh"'})

    return app


app = create_app()
