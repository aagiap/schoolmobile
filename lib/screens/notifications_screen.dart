import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_router.dart';
import '../core/constants.dart';
import '../models/app_data.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();

  // 1. Quản lý index cho thanh điều hướng (Thông báo là index 1)
  int _selectedIndex = 1;

  bool _isLoading = true;
  List<NotificationItem> _allNotifications = [];

  final List<String> _tabs = ['Tất cả', 'Chưa đọc', 'Hệ thống'];
  String _selectedTab = 'Tất cả';
  final Set<int> _expandedIndices = {};

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // 2. Logic điều hướng tab
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, AppRoutes.profile);
    }
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString(StorageKeys.studentId) ?? '';

      if (studentId.isEmpty) {
        throw Exception('Không tìm thấy thông tin học sinh.');
      }

      final data = await _apiService.getNotifications(studentId: studentId);

      setState(() {
        _allNotifications = data;
        if (_allNotifications.isNotEmpty) {
          _expandedIndices.add(0);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<NotificationItem> _getFilteredNotifications() {
    if (_selectedTab == 'Hệ thống') {
      return _allNotifications.where((n) => n.type == 'HỆ THỐNG').toList();
    }
    return _allNotifications;
  }

  String _formatRelativeTime(String dateTimeStr) {
    try {
      final date = DateTime.parse(dateTimeStr.replaceFirst(' ', 'T'));
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays == 1) return 'Hôm qua';
      return '${diff.inDays} ngày trước';
    } catch (e) {
      return dateTimeStr.split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _getFilteredNotifications();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // Ẩn nút back vì đây là tab chính
        automaticallyImplyLeading: false,
        title: const Text(
          'Thông báo',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_rtl, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đánh dấu đọc tất cả!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: _tabs.map((tab) => _buildTabItem(tab)).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : displayList.isEmpty
                ? const Center(child: Text('Không có thông báo nào', style: TextStyle(color: AppColors.textLight)))
                : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(displayList[index], index);
              },
            ),
          ),
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
            activeIcon: Icon(Icons.notifications),
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

  Widget _buildTabItem(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedTab = title;
        _expandedIndices.clear();
        if (_getFilteredNotifications().isNotEmpty) _expandedIndices.add(0);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textLight,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item, int index) {
    final isExpanded = _expandedIndices.contains(index);
    final timeStr = _formatRelativeTime(item.createdAt);

    Color typeColor = AppColors.textLight;
    if (item.type == 'HỌC TẬP') typeColor = AppColors.primary;
    if (item.type == 'HỆ THỐNG') typeColor = Colors.blueGrey;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedIndices.remove(index);
          } else {
            _expandedIndices.add(index);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpanded ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isExpanded ? AppColors.primary.withOpacity(0.3) : AppColors.border.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (item.type == 'HỌC TẬP') ...[
                      const Icon(Icons.circle, size: 8, color: AppColors.primary),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      item.type,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: typeColor, letterSpacing: 0.5),
                    ),
                  ],
                ),
                Text(
                  timeStr,
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              item.content,
              maxLines: isExpanded ? null : 2,
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: isExpanded ? AppColors.textDark : AppColors.textLight,
                height: 1.4,
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Xem chi tiết', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _expandedIndices.remove(index));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size.zero,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Thu gọn', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}