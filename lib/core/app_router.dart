import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/reset_password_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
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
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
