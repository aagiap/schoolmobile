import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/student.dart';

class ApiService {
  // Hàm đăng nhập
  static Future<Student?> login(String phone, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Đăng nhập thành công, parse dữ liệu
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        Student student = Student.fromJson(data);

        // Lưu ID học sinh vào bộ nhớ máy để dùng cho các màn hình sau
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('studentId', student.studentId);
        await prefs.setString('className', student.className);

        return student;
      } else {
        // Sai mật khẩu hoặc lỗi từ server
        final errorMsg = response.body.isNotEmpty ? response.body : 'Đăng nhập thất bại';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    }
  }
}