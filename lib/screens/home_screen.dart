import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_router.dart';
import '../core/constants.dart';
import '../services/session_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _fullName = '';
  String _className = '';

  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString(StorageKeys.fullName) ?? 'Học sinh';
      _className = prefs.getString(StorageKeys.className) ?? 'Lớp...';
    });
  }

  // Hàm xử lý khi nhấn vào Bottom Navigation Bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Chuyển sang màn hình Thông báo
      Navigator.pushNamed(context, AppRoutes.notifications);
    } else if (index == 2) {
      // Chuyển sang màn hình Hồ sơ cá nhân
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // --- HEADER MÀU CAM ---
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24,
              right: 24,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào, $_fullName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _className,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // Nhấn vào Avatar cũng có thể mở Profile
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Dat+Nguyen&background=0D8ABC&color=fff'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- GRID CHỨC NĂNG ---
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(24.0),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildMenuCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Thời khóa biểu',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.schedule),
                ),
                _buildMenuCard(
                  icon: Icons.star_border_outlined,
                  title: 'Kết quả học tập',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.grades),
                ),
                _buildMenuCard(
                  icon: Icons.event_note_outlined,
                  title: 'Lịch thi',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.exams),
                ),
                _buildMenuCard(
                  icon: Icons.notifications_none_outlined,
                  title: 'Thông báo',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                ),
                _buildMenuCard(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Điểm danh',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.attendance),
                ),
              ],
            ),
          )
        ],
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
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}