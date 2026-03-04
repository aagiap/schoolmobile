import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_router.dart';
import '../core/constants.dart';
import '../services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Khởi tạo các biến để hứng dữ liệu từ Session
  String _fullName = '';
  String _studentId = '';
  String _className = '';
  String _phone = '';

  // Sử dụng SessionService đã có trong project của bạn
  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Hàm lấy dữ liệu thực tế từ bộ nhớ máy (SharedPreferences) thông qua StorageKeys
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString(StorageKeys.fullName) ?? 'Học sinh';
      _studentId = prefs.getString(StorageKeys.studentId) ?? '---';
      _className = prefs.getString(StorageKeys.className) ?? '---';
      _phone = prefs.getString(StorageKeys.phone) ?? '---';
    });
  }

  // Logic Đăng xuất: Xóa session và quay về màn hình Login
  Future<void> _handleLogout() async {
    await _sessionService.clear(); // Xóa sạch studentId, fullName, phone...
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Avatar động dựa theo tên học sinh
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=${_fullName.replaceAll(' ', '+')}&background=F57C00&color=fff&size=256',
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text('Lớp $_className', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
            const SizedBox(height: 24),

            // Card Thông tin hiển thị dữ liệu từ Session
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('THÔNG TIN HỌC SINH', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                  const SizedBox(height: 16),
                  _buildInfoRow(icon: Icons.badge_outlined, title: 'Mã số học sinh', value: _studentId),
                  _buildInfoRow(icon: Icons.calendar_today_outlined, title: 'Ngày sinh', value: '15/08/2008'), // Dữ liệu cố định từ DB
                  _buildInfoRow(icon: Icons.phone_outlined, title: 'Số điện thoại', value: _phone),
                  _buildInfoRow(icon: Icons.school_outlined, title: 'Niên khóa', value: '2025 - 2026', isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nút Đổi mật khẩu
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.resetPassword),
              icon: const Icon(Icons.lock_reset, color: AppColors.primary),
              label: const Text('Đổi mật khẩu'),
            ),
            const SizedBox(height: 16),

            // Nút Đăng xuất thực tế
            TextButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Đăng xuất', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String value, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}