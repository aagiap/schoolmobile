import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFF57C00); // Màu cam giống ảnh
  static const Color background = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
}

class AppConstants {
  // Nếu chạy máy ảo Android, dùng 10.0.2.2 thay vì localhost
  static const String baseUrl = 'http://10.0.2.2:8080/api';
}