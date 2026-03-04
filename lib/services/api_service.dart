import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/app_data.dart';
import '../models/student.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Student> login({required String phone, required String password}) async {
    final json = await _post(
      '/auth/login',
      body: {'phone': phone, 'password': password},
    );
    return Student.fromJson(json);
  }

  Future<void> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    await _post(
      '/auth/reset-password',
      body: {'phone': phone, 'newPassword': newPassword},
    );
  }

  Future<List<GradeItem>> getGrades({
    required String studentId,
    required String semester,
  }) async {
    final data = await _get('/app/grades/$studentId?semester=$semester') as List<dynamic>;
    return data.map((e) => GradeItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ScheduleItem>> getSchedules({
    required String className,
    required String week,
  }) async {
    final data = await _get('/app/schedules?className=$className&week=$week') as List<dynamic>;
    return data.map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ExamItem>> getExams({
    required String studentId,
    required String semester,
  }) async {
    final data = await _get('/app/exams/$studentId?semester=$semester') as List<dynamic>;
    return data.map((e) => ExamItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AttendanceSummary> getAttendanceSummary({required String studentId}) async {
    final data = await _get('/app/attendances/$studentId') as Map<String, dynamic>;
    return AttendanceSummary.fromJson(data);
  }

  Future<List<NotificationItem>> getNotifications({required String studentId}) async {
    final data = await _get('/app/notifications/$studentId') as List<dynamic>;
    return data
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<dynamic> _get(String endpoint) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await _client
        .get(url, headers: {'Content-Type': 'application/json'})
        .timeout(AppConstants.networkTimeout);

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> _post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await _client
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(AppConstants.networkTimeout);

    final parsed = _parseResponse(response);
    return parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
  }

  dynamic _parseResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes).trim();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) {
        return <String, dynamic>{};
      }
      final decoded = jsonDecode(body);
      return decoded;
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
    throw Exception(message);
  }
}
