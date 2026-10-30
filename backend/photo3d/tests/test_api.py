import io
import struct
import threading
import time
import unittest

from fastapi.testclient import TestClient
from PIL import Image
from nhombar_photo3d.api import create_app
from nhombar_photo3d.worker import EngineError


def jpeg():
    output = io.BytesIO()
    Image.new('RGB', (32, 32), 'white').save(output, format='JPEG')
    return output.getvalue()


class ContractEngine:
    """HTTP contract fixture, not evidence that AI inference works."""
    ready = True

    def __init__(self):
        self.release = threading.Event()
        self.failure = None

    def start(self):
        pass

    def generate(self, payload, mime, progress):
        progress('reconstructing')
        self.release.wait(3)
        if self.failure:
            raise EngineError(self.failure)
        return struct.pack('>II', 0x53434e31, 900) + bytes(7200)

    def close(self):
        self.release.set()


class ApiTests(unittest.TestCase):
    def setUp(self):
        self.engine = ContractEngine()
        self.client = TestClient(create_app(self.engine))
        self.client.__enter__()

    def tearDown(self):
        self.engine.release.set()
        self.client.__exit__(None, None, None)

    def post(self, payload=None, mime='image/jpeg'):
        return self.client.post('/api/v1/photo-models', content=jpeg() if payload is None else payload,
                                headers={'Content-Type': mime})

    def wait(self, key):
        for _ in range(100):
            response = self.client.get('/api/v1/photo-models/' + key)
            if response.json()['state'] in ('done', 'error'):
                return response
            time.sleep(.01)
        self.fail('Contract worker did not finish')

    def test_real_decode_rejects_corrupt_and_wrong_mime(self):
        self.assertEqual(self.post(b'not an image').status_code, 422)
        self.assertEqual(self.post(mime='application/pdf').status_code, 415)
        self.assertEqual(self.post(b'').status_code, 422)
        self.assertEqual(self.post(jpeg(), 'image/png').status_code, 415)

    def test_byte_and_pixel_limits(self):
        response = self.client.post('/api/v1/photo-models', content=b'x',
            headers={'Content-Type': 'image/jpeg', 'Content-Length': str(8*1024*1024+1)})
        self.assertEqual(response.status_code, 413)
        output = io.BytesIO()
        Image.new('RGB', (5000, 4000)).save(output, format='JPEG')
        self.assertEqual(self.post(output.getvalue()).status_code, 413)

    def test_serial_jobs_progress_mesh_and_no_image_leak(self):
        created = self.post()
        self.assertEqual(created.status_code, 202)
        key = created.json()['id']
        self.assertEqual(self.post().status_code, 429)
        self.assertEqual(self.client.get(f'/api/v1/photo-models/{key}/mesh').status_code, 409)
        self.engine.release.set()
        result = self.wait(key)
        self.assertEqual(result.json()['state'], 'done')
        self.assertNotIn('image', result.json())
        mesh = self.client.get(f'/api/v1/photo-models/{key}/mesh')
        self.assertEqual(struct.unpack('>II', mesh.content[:8]), (0x53434e31, 900))
        self.assertEqual(mesh.headers['cache-control'], 'no-store')
        self.assertEqual(self.post().status_code, 202)

    def test_worker_timeout_is_an_error_not_fake_mesh(self):
        self.engine.failure = 'inference_timeout'
        self.engine.release.set()
        key = self.post().json()['id']
        result = self.wait(key).json()
        self.assertEqual(result['state'], 'error')
        self.assertEqual(result['error']['code'], 'inference_timeout')
        self.assertEqual(self.client.get(f'/api/v1/photo-models/{key}/mesh').status_code, 409)

    def test_not_ready_unknown_job_and_removed_endpoint(self):
        self.engine.ready = False
        self.assertEqual(self.post().status_code, 503)
        self.assertEqual(self.client.get('/health').status_code, 503)
        self.assertEqual(self.client.get('/api/v1/photo-models/unknown').status_code, 404)
        self.assertEqual(self.client.post('/api/v1/detect').status_code, 404)


if __name__ == '__main__':
    unittest.main()
