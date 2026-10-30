"""Explicit desktop-only smoke test using an official public example image."""
import urllib.request
import json
from fastapi.testclient import TestClient
from nhombar_vision.api import create_app


if __name__ == '__main__':
    url = 'https://github.com/ultralytics/assets/releases/download/v0.0.0/bus.jpg'
    with urllib.request.urlopen(url, timeout=30) as response:
        image = response.read()
    with TestClient(create_app()) as client:
        assert client.get('/health').json()['ready'] is True
        result = client.post('/api/v1/detect', content=image, headers={'content-type': 'image/jpeg'})
        assert result.status_code == 200, result.text
        data = result.json()
        assert data['model'] == 'yolo26n'
        assert any(item['name_en'] == 'bus' for item in data['detections']), data
        # Reuse the loaded model after clearing its previous image references.
        again = client.post('/api/v1/detect', content=image, headers={'content-type': 'image/jpeg'})
        assert again.status_code == 200, again.text
        assert any(item['class_id'] == 5 and item['name_vi'] == 'Xe buýt' for item in again.json()['detections'])
        print(json.dumps({'model': data['model'], 'image': data['image'],
               'objects': [(item['name_en'], item['name_vi'], round(item['confidence'], 3)) for item in data['detections']]}, ensure_ascii=True))
