
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PointCloudViewerScreen extends StatefulWidget {
  final String pointCloudUrl;

  const PointCloudViewerScreen({
    super.key,
    required this.pointCloudUrl,
  });

  @override
  State<PointCloudViewerScreen> createState() =>
      _PointCloudViewerScreenState();
}

class _PointCloudViewerScreenState
    extends State<PointCloudViewerScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;
  String _status = 'Đang tải dữ liệu COLMAP...';
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'ViewerStatus',
        onMessageReceived: (message) {
          if (!mounted) return;

          final value = message.message;

          if (value.startsWith('ERROR:')) {
            setState(() {
              _error = value.substring(6);
              _isLoading = false;
            });
          } else if (value.startsWith('READY:')) {
            setState(() {
              _status = value.substring(6);
              _error = null;
              _isLoading = false;
            });
          }
        },
      );

    _loadColmap();
  }

  Future<void> _loadColmap() async {
    try {
      final dio = Dio();

      final plyResponse = await dio.get<List<int>>(
        widget.pointCloudUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final plyBytes = Uint8List.fromList(plyResponse.data!);

      if (plyBytes.isEmpty) {
        throw Exception('File Point Cloud rỗng.');
      }

      final uri = Uri.parse(widget.pointCloudUrl);
      final segments = uri.pathSegments;

      if (segments.length < 3 ||
          segments[segments.length - 1] != 'pointcloud') {
        throw Exception('Đường dẫn Point Cloud không hợp lệ.');
      }

      final scanId = segments[segments.length - 2];

      final camerasUrl = uri.replace(
        path: '/scan/$scanId/cameras',
      ).toString();

      if (!mounted) return;

      setState(() {
        _status = 'Đang tải 72 camera COLMAP...';
      });

      final camerasResponse = await dio.get(
        camerasUrl,
      );

      final camerasData = camerasResponse.data is String
          ? jsonDecode(camerasResponse.data)
          : camerasResponse.data;

      final cameras = camerasData['cameras'];

      if (cameras is! List) {
        throw Exception(
          'Dữ liệu cameras.json không hợp lệ.',
        );
      }

      final base64Ply = base64Encode(plyBytes);
      final camerasJson = jsonEncode(cameras);

      if (!mounted) return;

      setState(() {
        _status = 'Đang dựng cảnh 3D...';
      });

      await _controller.loadHtmlString(
        _buildHtml(
          base64Ply: base64Ply,
          camerasJson: camerasJson,
        ),
        baseUrl: 'https://threejs.org/',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Không tải được dữ liệu COLMAP:\n$e';
        _isLoading = false;
      });
    }
  }

  String _buildHtml({
    required String base64Ply,
    required String camerasJson,
  }) {
    return '''
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">

  <meta name="viewport"
        content="width=device-width, initial-scale=1.0,
                 maximum-scale=1.0, user-scalable=no">

  <style>
    * { box-sizing: border-box; }

    html, body {
      margin: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: white;
      font-family: Arial, sans-serif;
    }

    canvas {
      display: block;
      touch-action: none;
    }

    #status {
      position: absolute;
      top: 12px;
      left: 10px;
      right: 10px;
      z-index: 2;
      text-align: center;
      font-size: 13px;
      color: #222;
      pointer-events: none;
    }
  </style>

  <script type="importmap">
  {
    "imports": {
      "three": "https://cdn.jsdelivr.net/npm/three@0.160.1/build/three.module.js",
      "three/addons/": "https://cdn.jsdelivr.net/npm/three@0.160.1/examples/jsm/"
    }
  }
  </script>
</head>

<body>
  <div id="status">Đang khởi tạo COLMAP Viewer...</div>

  <script>
    function notifyFlutter(message) {
      if (window.ViewerStatus) {
        window.ViewerStatus.postMessage(message);
      }
    }

    window.addEventListener('error', function(event) {
      notifyFlutter('ERROR:' + event.message);
    });

    window.addEventListener(
      'unhandledrejection',
      function(event) {
        notifyFlutter('ERROR:' + String(event.reason));
      }
    );
  </script>

  <script type="module">
    import * as THREE from 'three';

    import { PLYLoader } from
      'three/addons/loaders/PLYLoader.js';

    import { OrbitControls } from
      'three/addons/controls/OrbitControls.js';

    try {
      const status = document.getElementById('status');

      const binary = atob('$base64Ply');
      const bytes = new Uint8Array(binary.length);

      for (let i = 0; i < binary.length; i++) {
        bytes[i] = binary.charCodeAt(i);
      }

      const plyLoader = new PLYLoader();
      const geometry = plyLoader.parse(bytes.buffer);

      geometry.computeBoundingBox();

      const originalCenter = new THREE.Vector3();
      geometry.boundingBox.getCenter(originalCenter);

      geometry.computeBoundingSphere();

      const radius = Math.max(
        geometry.boundingSphere.radius,
        0.001
      );

      const scene = new THREE.Scene();
      scene.background = new THREE.Color(0xffffff);

      // COLMAP dùng hệ tọa độ với trục Y hướng xuống.
      // Chuyển sang cách nhìn Y hướng lên của Three.js.
      const colmapGroup = new THREE.Group();
      colmapGroup.scale.y = -1;
      scene.add(colmapGroup);

      // Căn giữa toàn bộ cảnh nhưng giữ nguyên tọa độ
      // tương đối giữa điểm 3D và camera.
      const contentGroup = new THREE.Group();
      contentGroup.position.copy(
        originalCenter.clone().multiplyScalar(-1)
      );
      colmapGroup.add(contentGroup);

      const hasColors =
        geometry.getAttribute('color') !== undefined;

      const pointsMaterial = new THREE.PointsMaterial({
        size: radius * 0.004,
        vertexColors: hasColors,
        color: hasColors ? 0xffffff : 0x333333,
        sizeAttenuation: true
      });

      const pointCloud = new THREE.Points(
        geometry,
        pointsMaterial
      );

      contentGroup.add(pointCloud);

      // Các camera COLMAP đã xuất từ cameras.json.
      const cameras = $camerasJson;

      // Kích thước hình chóp dựa trên kích thước cảnh.
      const cameraSize = radius * 0.035;

      const cameraMaterial = new THREE.LineBasicMaterial({
        color: 0xff2020,
        linewidth: 1
      });

      function addColmapCamera(data) {
        const position = new THREE.Vector3(
          data.position[0],
          data.position[1],
          data.position[2]
        );

        const right = new THREE.Vector3(
          ...data.right
        );

        const down = new THREE.Vector3(
          ...data.down
        );

        const forward = new THREE.Vector3(
          ...data.forward
        );

        // Tạo hình chóp camera:
        // Đỉnh là tâm camera, đáy là khung ảnh.
        const depth = cameraSize * 1.6;
        const halfWidth = cameraSize;
        const halfHeight = cameraSize * 0.65;

        function corner(x, y) {
          return position.clone()
            .addScaledVector(forward, depth)
            .addScaledVector(right, x * halfWidth)
            .addScaledVector(down, y * halfHeight);
        }

        const a = corner(-1, -1);
        const b = corner(1, -1);
        const c = corner(1, 1);
        const d = corner(-1, 1);

        const vertices = [
          position, a,
          position, b,
          position, c,
          position, d,

          a, b,
          b, c,
          c, d,
          d, a
        ];

        const coordinates = [];

        for (const vertex of vertices) {
          coordinates.push(
            vertex.x,
            vertex.y,
            vertex.z
          );
        }

        const linesGeometry = new THREE.BufferGeometry();

        linesGeometry.setAttribute(
          'position',
          new THREE.Float32BufferAttribute(
            coordinates,
            3
          )
        );

        const frustum = new THREE.LineSegments(
          linesGeometry,
          cameraMaterial
        );

        contentGroup.add(frustum);
      }

      for (const cameraData of cameras) {
        addColmapCamera(cameraData);
      }

      const camera = new THREE.PerspectiveCamera(
        60,
        window.innerWidth / window.innerHeight,
        0.001,
        10000
      );

      const renderer = new THREE.WebGLRenderer({
        antialias: true
      });

      renderer.setClearColor(0xffffff, 1);
      renderer.setSize(
        window.innerWidth,
        window.innerHeight
      );

      renderer.setPixelRatio(
        Math.min(window.devicePixelRatio, 2)
      );

      document.body.appendChild(renderer.domElement);

      const controls = new OrbitControls(
        camera,
        renderer.domElement
      );

      controls.enableDamping = true;
      controls.dampingFactor = 0.08;
      controls.enableZoom = true;
      controls.enablePan = true;

      // Cảnh mặc định nhìn nghiêng từ phía trên,
      // tương tự góc nhìn COLMAP.
      camera.position.set(
        radius * 1.6,
        radius * 1.2,
        radius * 2.2
      );

      camera.near = Math.max(radius / 1000, 0.0001);
      camera.far = radius * 100;
      camera.updateProjectionMatrix();

      controls.target.set(0, 0, 0);
      controls.update();

      status.textContent =
        'COLMAP | ' +
        geometry.attributes.position.count +
        ' điểm | ' +
        cameras.length +
        ' camera | Kéo để xoay, chụm để phóng to';

      notifyFlutter(
        'READY:' +
        geometry.attributes.position.count +
        ' điểm và ' +
        cameras.length +
        ' camera'
      );

      function animate() {
        requestAnimationFrame(animate);
        controls.update();
        renderer.render(scene, camera);
      }

      animate();

      window.addEventListener('resize', () => {
        camera.aspect =
          window.innerWidth / window.innerHeight;

        camera.updateProjectionMatrix();

        renderer.setSize(
          window.innerWidth,
          window.innerHeight
        );
      });

    } catch (error) {
      notifyFlutter('ERROR:' + error.message);
    }
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'COLMAP 3D Viewer',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          if (_isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

          if (_error != null)
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Không thể hiển thị COLMAP:\n\n$_error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
