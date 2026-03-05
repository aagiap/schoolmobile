import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/app_data.dart';
import '../services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  AttendanceSummary? _summary;

  // Quản lý bộ lọc theo Tháng
  List<String> _availableMonths = [];
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString(StorageKeys.studentId) ?? '';

      if (studentId.isEmpty) {
        throw Exception('Không tìm thấy thông tin học sinh.');
      }

      final data = await _apiService.getAttendanceSummary(studentId: studentId);

      // Xử lý trích xuất danh sách "Tháng, Năm" từ dữ liệu chi tiết để tạo bộ lọc
      final Set<String> monthsSet = {};
      for (var item in data.details) {
        if (item['attendanceDate'] != null) {
          final date = DateTime.parse(item['attendanceDate']);
          monthsSet.add(DateFormat('MM/yyyy').format(date));
        }
      }

      final monthsList = monthsSet.toList()..sort((a, b) => b.compareTo(a)); // Sắp xếp mới nhất lên đầu

      setState(() {
        _summary = data;
        _availableMonths = monthsList;
        if (_availableMonths.isNotEmpty) {
          _selectedMonth = _availableMonths.first;
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

  // Lấy chi tiết điểm danh của tháng được chọn
  List<dynamic> _getFilteredDetails() {
    if (_summary == null || _selectedMonth == null) return [];
    return _summary!.details.where((item) {
      if (item['attendanceDate'] == null) return false;
      final date = DateTime.parse(item['attendanceDate']);
      final monthStr = DateFormat('MM/yyyy').format(date);
      return monthStr == _selectedMonth;
    }).toList();
  }

  // Chuyển "05/2026" thành "Tháng 5, 2026" cho UI
  String _formatMonthDisplay(String mmYYYY) {
    final parts = mmYYYY.split('/');
    if (parts.length == 2) {
      return 'Tháng ${int.parse(parts[0])}, ${parts[1]}';
    }
    return mmYYYY;
  }

  @override
  Widget build(BuildContext context) {
    final filteredDetails = _getFilteredDetails();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Báo cáo điểm danh',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _summary == null
          ? const Center(child: Text('Không có dữ liệu điểm danh'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Card Tổng quan ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildSummaryCard(),
          ),

          // --- Dropdown Chọn Tháng ---
          if (_availableMonths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thời gian', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedMonth,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
                        style: const TextStyle(color: AppColors.textDark, fontSize: 16),
                        onChanged: (String? newValue) {
                          if (newValue != null) setState(() => _selectedMonth = newValue);
                        },
                        items: _availableMonths.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(_formatMonthDisplay(month)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('CHI TIẾT THEO NGÀY', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 12),

          // --- Danh sách chi tiết ---
          Expanded(
            child: filteredDetails.isEmpty
                ? const Center(child: Text('Không có dữ liệu trong tháng này'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              itemCount: filteredDetails.length,
              itemBuilder: (context, index) {
                return _buildAttendanceRecord(filteredDetails[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Khối Card hiển thị Biểu đồ và Tổng số buổi
  Widget _buildSummaryCard() {
    final int total = _summary!.totalDays;
    final int present = _summary!.presentDays;
    final int absent = _summary!.absentDays;
    final double percentage = _summary!.percentage;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Biểu đồ tròn
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: AppColors.primaryLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                Center(
                  child: Text(
                    '${percentage.toInt()}%',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),

          // Thống kê Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng số buổi:', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                const SizedBox(height: 4),
                Text('$total buổi', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: AppColors.success),
                    const SizedBox(width: 6),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                        children: [
                          const TextSpan(text: 'Có mặt: '),
                          TextSpan(text: '$present', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: AppColors.error),
                    const SizedBox(width: 6),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                        children: [
                          const TextSpan(text: 'Vắng mặt: '),
                          TextSpan(text: '$absent', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Khối List Item hiển thị 1 ngày điểm danh
  Widget _buildAttendanceRecord(Map<String, dynamic> record) {
    // Phân tích ngày tháng
    DateTime date;
    try {
      date = DateTime.parse(record['attendanceDate']);
    } catch (_) {
      date = DateTime.now();
    }

    const weekdays = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    final weekdayStr = weekdays[date.weekday - 1];
    final dateStr = DateFormat('dd/MM/yyyy').format(date);

    final status = record['status'] ?? 'Có mặt';
    final note = record['note'] ?? '';

    // Xác định màu sắc Badge
    final isPresent = status == 'Có mặt';
    final badgeBgColor = isPresent ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15);
    final badgeTextColor = isPresent ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$weekdayStr, $dateStr', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(note, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}