import 'package:flutter/material.dart';

import '../core/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chào mừng đến ${AppConstants.appTitle}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Khung chung đã sẵn sàng: đăng nhập, đổi mật khẩu, gọi API và lưu phiên đăng nhập. '
              'Ở bước tiếp theo chúng ta sẽ dựng các màn hình đúng thiết kế bạn gửi.',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
