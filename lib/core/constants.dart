import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFF57C00);
  static const Color primaryLight = Color(0xFFFFF3E0);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
}

class AppConstants {
  const AppConstants._();

  /// Android emulator: 10.0.2.2, iOS simulator/device: localhost/LAN IP.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  static const Duration networkTimeout = Duration(seconds: 20);
  static const String appTitle = 'Sổ liên lạc điện tử';
  static const String schoolName = 'THPT Hữu Lũng';
}

class StorageKeys {
  const StorageKeys._();

  static const String studentId = 'studentId';
  static const String className = 'className';
  static const String fullName = 'fullName';
  static const String phone = 'phone';
}
