import 'package:flutter/material.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'core/constants.dart';

void main() {
  runApp(const SchoolMobileApp());
}

class SchoolMobileApp extends StatelessWidget {
  const SchoolMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
