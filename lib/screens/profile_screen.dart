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
  // 1. Quản lý index cho thanh điều hướng (Cá nhân là index 2)
  int _selectedIndex = 2;

  String _fullName = '';
  String _studentId = '';
  String _className = '';
  String _phone = '';

  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString(StorageKeys.fullName) ?? 'Học sinh';
      _studentId = prefs.getString(StorageKeys.studentId) ?? '---';
      _className = prefs.getString(StorageKeys.className) ?? '---';
      _phone = prefs.getString(StorageKeys.phone) ?? '---';
    });
  }

  // 2. Logic xử lý khi chạm vào thanh điều hướng
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Nếu nhấn vào chính trang hiện tại thì không làm gì

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Về Trang chủ: Sử dụng pushReplacementNamed để tránh chồng lấp các màn hình chính
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (index == 1) {
      // Sang Thông báo
      Navigator.pushReplacementNamed(context, AppRoutes.notifications);
    }
  }

  Future<void> _handleLogout() async {
    await _sessionService.clear();
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
        // Bỏ nút back nếu đây là 1 tab chính trong BottomNav
        automaticallyImplyLeading: false,
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
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
                  _buildInfoRow(icon: Icons.calendar_today_outlined, title: 'Ngày sinh', value: '15/08/2008'),
                  _buildInfoRow(icon: Icons.phone_outlined, title: 'Số điện thoại', value: _phone),
                  _buildInfoRow(icon: Icons.school_outlined, title: 'Niên khóa', value: '2025 - 2026', isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.resetPassword),
              icon: const Icon(Icons.lock_reset, color: AppColors.primary),
              label: const Text('Đổi mật khẩu'),
            ),
            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Đăng xuất', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
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