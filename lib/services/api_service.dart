import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/app_data.dart';
import '../models/student.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // --- Logic Tự động đính kèm Token ---
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (requireAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.token);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Trả về AuthResponse thay vì Student thuần túy
  Future<AuthResponse> login({required String phone, required String password}) async {
    final json = await _post(
      '/auth/login',
      body: {'phone': phone, 'password': password},
      requireAuth: false, // Login thì chưa có token
    );
    return AuthResponse.fromJson(json);
  }

  Future<AuthResponse> loginWithFirebase({required String idToken}) async {
    final json = await _post(
      '/auth/login-firebase',
      body: {'idToken': idToken},
      requireAuth: false,
    );
    return AuthResponse.fromJson(json);
  }

  Future<void> resetPassword({required String phone, required String newPassword}) async {
    await _post(
      '/auth/reset-password',
      body: {'phone': phone, 'newPassword': newPassword},
      requireAuth: false,
    );
  }

  Future<List<GradeItem>> getGrades({required String studentId, required String semester}) async {
    final data = await _get('/app/grades/$studentId?semester=$semester') as List<dynamic>;
    return data.map((e) => GradeItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ScheduleItem>> getSchedules({required String className, required String week}) async {
    final data = await _get('/app/schedules?className=$className&week=$week') as List<dynamic>;
    return data.map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ExamItem>> getExams({required String studentId, required String semester}) async {
    final data = await _get('/app/exams/$studentId?semester=$semester') as List<dynamic>;
    return data.map((e) => ExamItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AttendanceSummary> getAttendanceSummary({required String studentId}) async {
    final data = await _get('/app/attendances/$studentId') as Map<String, dynamic>;
    return AttendanceSummary.fromJson(data);
  }

  Future<List<NotificationItem>> getNotifications({required String studentId}) async {
    final data = await _get('/app/notifications/$studentId') as List<dynamic>;
    return data.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Cập nhật phương thức GET
  Future<dynamic> _get(String endpoint, {bool requireAuth = true}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final response = await _client.get(url, headers: headers).timeout(AppConstants.networkTimeout);
    return _parseResponse(response);
  }

  // Cập nhật phương thức POST
  Future<Map<String, dynamic>> _post(
      String endpoint, {
        required Map<String, dynamic> body,
        bool requireAuth = true,
      }) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final response = await _client
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(AppConstants.networkTimeout);

    final parsed = _parseResponse(response);
    return parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
  }

  dynamic _parseResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes).trim();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return <String, dynamic>{};
      return jsonDecode(body);
    }

    String message = 'Đã xảy ra lỗi kết nối máy chủ (${response.statusCode}).';
    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        } else {
          message = body;
        }
      } catch (_) {
        message = body;
      }
    }
    // Bắt lỗi Unauthorized
    if (response.statusCode == 401 || response.statusCode == 403) {
      message = 'Phiên đăng nhập hết hạn hoặc bạn không có quyền truy cập.';
    }
    throw Exception(message);
  }
}