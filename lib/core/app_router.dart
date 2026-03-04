import 'package:flutter/material.dart';

import '../screens/grades_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/profile_screen.dart';
// Lưu ý: Bạn cần tạo các file trống này trong thư mục screens để không bị lỗi import
// import '../screens/schedule_screen.dart';
// import '../screens/exam_screen.dart';
// import '../screens/notifications_screen.dart';
// import '../screens/attendance_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String grades = '/grades'; // Kết quả học tập
  static const String profile = '/profile'; // Cá nhân
  static const String schedule = '/schedule'; // Thời khóa biểu
  static const String exams = '/exams'; // Lịch thi
  static const String notifications = '/notifications'; // Thông báo
  static const String attendance = '/attendance'; // Điểm danh
}

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.grades:
        return MaterialPageRoute(builder: (_) => const GradesScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

    // Các route bổ sung dựa trên menu ở Home Screen
      case AppRoutes.schedule:
      // return MaterialPageRoute(builder: (_) => const ScheduleScreen());
        return _errorRoute(); // Tạm thời để error cho đến khi bạn tạo file
      case AppRoutes.exams:
      // return MaterialPageRoute(builder: (_) => const ExamScreen());
        return _errorRoute();
      case AppRoutes.notifications:
      // return MaterialPageRoute(builder: (_) => const NotificationsScreen());
        return _errorRoute();
      case AppRoutes.attendance:
      // return MaterialPageRoute(builder: (_) => const AttendanceScreen());
        return _errorRoute();

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }

  // Hàm bổ trợ hiển thị lỗi khi chưa có màn hình
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Đang phát triển')),
        body: const Center(child: Text('Chức năng này đang được xây dựng')),
      ),
    );
  }
}