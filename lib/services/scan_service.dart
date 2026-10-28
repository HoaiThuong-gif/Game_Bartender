
import 'package:dio/dio.dart';

class ScanService {
  // IP Wi-Fi của laptop chạy FastAPI.
  static const String baseUrl = 'http://192.168.100.116:8000';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 2),
      sendTimeout: const Duration(minutes: 5),
    ),
  );

  Future<bool> checkServer() async {
    try {
      final response = await _dio.get('/health');

      return response.statusCode == 200 &&
          response.data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> uploadVideo({
    required String videoPath,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(
          videoPath,
          filename: 'scan_video.mp4',
        ),
      });

      final response = await _dio.post(
        '/scan/upload',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }

      throw Exception('Không thể tải video lên server');
    } on DioException catch (e) {
      throw Exception(
        'Lỗi upload video: ${_errorMessage(e)}',
      );
    }
  }

  Future<Map<String, dynamic>> getScanStatus(
      String scanId,
      ) async {
    try {
      final response = await _dio.get('/scan/$scanId');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Không thể kiểm tra trạng thái: ${_errorMessage(e)}',
      );
    }
  }

  String getModelUrl(String relativePath) {
    return Uri.parse(baseUrl).resolve(relativePath).toString();
  }

  String getPointCloudUrl(String relativePath) {
    return Uri.parse(baseUrl).resolve(relativePath).toString();
  }

  String getCamerasUrl(String relativePath) {
    return Uri.parse(baseUrl).resolve(relativePath).toString();
  }

  String _errorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }

    return error.message ?? 'Lỗi kết nối không xác định';
  }
}
