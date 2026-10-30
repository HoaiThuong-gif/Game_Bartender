import asyncio
from concurrent.futures import ThreadPoolExecutor
import io
import threading
import unittest
from unittest.mock import MagicMock, patch
import httpx
from fastapi.testclient import TestClient
from PIL import Image
from nhombar_vision import api
from nhombar_vision.inference import decode_image, ImageInputError
from nhombar_vision.labels import LABELS
from nhombar_vision.settings import MAX_BYTES
from nhombar_vision.worker import ProcessDetector, VisionFailure


def picture(format='JPEG'):
    output = io.BytesIO()
    Image.new('RGB', (24, 16), 'red').save(output, format=format)
    return output.getvalue()


class TestDetector:
    """HTTP tests only. Production always constructs ProcessDetector."""
    ready = True
    error = None
    def start(self): pass
    def close(self): pass
    def detect(self, payload, mime):
        if self.error:
            raise VisionFailure(self.error)
        try:
            image = decode_image(payload, mime)
        except ImageInputError as error:
            raise VisionFailure(error.code) from None
        width, height = image.size
        image.close()
        return {'model': 'yolo26n', 'image': {'width': width, 'height': height},
                'bbox_format': 'xyxy', 'detections': []}


class ApiTests(unittest.TestCase):
    def setUp(self):
        self.detector = TestDetector()
        self.client = TestClient(api.create_app(self.detector))
        self.client.__enter__()
    def tearDown(self):
        self.client.__exit__(None, None, None)

    def post(self, payload=None, mime='image/jpeg', headers=None):
        return self.client.post('/api/v1/detect', content=picture() if payload is None else payload,
                                headers={'content-type': mime, **(headers or {})})

    def test_valid_image_returns_contract_without_saved_photo(self):
        response = self.post()
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['image'], {'width': 24, 'height': 16})
        self.assertEqual(response.json()['detections'], [])
        self.assertEqual(response.headers['cache-control'], 'no-store')

    def test_rejects_bad_content_type_empty_file_and_corrupt_file(self):
        self.assertEqual(self.post(mime='text/plain').status_code, 415)
        self.assertEqual(self.post(b'').status_code, 422)
        self.assertEqual(self.post(b'not an image').status_code, 422)
        self.assertEqual(self.post(picture('PNG')).status_code, 415)
        self.assertEqual(self.post(picture('PNG'), mime='image/png').status_code, 200)

    def test_limits_bytes_even_if_content_length_is_absent(self):
        self.assertEqual(self.post(headers={'content-length': str(MAX_BYTES + 1)}).status_code, 413)
        response = self.client.post('/api/v1/detect', content=iter([b'x' * (MAX_BYTES + 1)]),
                                    headers={'content-type': 'image/jpeg'})
        self.assertEqual(response.status_code, 413)

    def test_timeout_and_inference_error_are_not_successful_results(self):
        for code, status in [('inference_timeout', 504), ('inference_failed', 500)]:
            self.detector.error = code
            response = self.post()
            self.assertEqual(response.status_code, status)
            self.assertNotIn('detections', response.json())
        self.detector.ready = False
        self.assertEqual(self.client.get('/health').status_code, 503)
        self.assertEqual(self.post().status_code, 503)

    def test_busy_request_is_rejected_without_unbounded_inference_queue(self):
        started, release = threading.Event(), threading.Event()
        original = self.detector.detect
        def slow(payload, mime):
            started.set()
            if not release.wait(5): raise RuntimeError('Test did not release worker')
            return original(payload, mime)
        self.detector.detect = slow
        with ThreadPoolExecutor(max_workers=1) as pool:
            first = pool.submit(self.post)
            try:
                self.assertTrue(started.wait(5))
                self.assertEqual(self.post().status_code, 429)
            finally:
                release.set()
            self.assertEqual(first.result(timeout=5).status_code, 200)

    def test_oversized_pixel_count_is_rejected_before_decode(self):
        with patch('nhombar_vision.inference.MAX_PIXELS', 100):
            self.assertEqual(self.post().status_code, 413)

    def test_exif_orientation_matches_returned_coordinates(self):
        image = Image.new('RGB', (24, 16))
        exif = image.getexif(); exif[274] = 6
        output = io.BytesIO(); image.save(output, 'JPEG', exif=exif)
        self.assertEqual(self.post(output.getvalue()).json()['image'], {'width': 16, 'height': 24})

    def test_priority_labels_use_correct_coco_ids(self):
        self.assertEqual(len(LABELS), 80)
        for index, expected in {39: ('bottle', 'Chai'), 41: ('cup', 'Cốc'), 46: ('banana', 'Chuối'),
                                47: ('apple', 'Táo'), 56: ('chair', 'Ghế'), 73: ('book', 'Sách')}.items():
            self.assertEqual(LABELS[index], expected)

    def test_hung_inference_process_is_stopped_and_marked_not_ready(self):
        detector = ProcessDetector(timeout=0)
        process = MagicMock(); process.is_alive.return_value = True
        pipe = MagicMock(); pipe.poll.return_value = False
        detector._process = process; detector._pipe = pipe; detector._ready = True
        with patch('nhombar_vision.worker.threading.Thread') as restart:
            with self.assertRaises(VisionFailure) as caught:
                detector.detect(b'jpeg', 'image/jpeg')
            self.assertEqual(caught.exception.code, 'inference_timeout')
            process.terminate.assert_called_once()
            self.assertFalse(detector.ready)
            restart.return_value.start.assert_called_once()
        detector.close()


class UploadTimeoutTest(unittest.IsolatedAsyncioTestCase):
    async def test_slow_upload_is_bounded(self):
        async def slow_image():
            await asyncio.sleep(.1)
            yield picture()
        app = api.create_app(TestDetector())
        with patch('nhombar_vision.api.UPLOAD_TIMEOUT', .01):
            async with httpx.AsyncClient(transport=httpx.ASGITransport(app=app), base_url='http://test') as client:
                response = await client.post('/api/v1/detect', content=slow_image(), headers={'content-type': 'image/jpeg'})
                self.assertEqual(response.status_code, 408)


if __name__ == '__main__':
    unittest.main()
