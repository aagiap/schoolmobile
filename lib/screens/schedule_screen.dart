import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/app_data.dart';
import '../services/api_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String _className = '';

  // Do backend hiện tại chưa có API lấy danh sách tuần,
  // ta tạm định nghĩa các tuần có dữ liệu để chọn (Dựa theo DB SQL)
  final List<String> _weeks = ['Tuần 23', 'Tuần 24', 'Tuần 25'];
  String _selectedWeek = 'Tuần 23';

  List<ScheduleItem> _allSchedules = [];
  List<DateTime> _uniqueDates = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Lấy tự động lớp học (className) từ SharedPreferences khi user login
      final prefs = await SharedPreferences.getInstance();
      _className = prefs.getString(StorageKeys.className) ?? '';

      if (_className.isEmpty) {
        throw Exception("Không tìm thấy thông tin lớp học. Vui lòng đăng nhập lại.");
      }

      // 2. Gọi API Service đã định nghĩa của bạn
      final schedules = await _apiService.getSchedules(
        className: _className,
        week: _selectedWeek,
      );

      // 3. Gom nhóm các ngày có lịch học trong tuần để vẽ thanh trượt (T2, T3...)
      final Set<String> dateStrings = schedules.map((s) => s.studyDate).toSet();
      _uniqueDates = dateStrings.map((ds) => DateTime.parse(ds)).toList();
      _uniqueDates.sort(); // Sắp xếp tăng dần theo thời gian

      setState(() {
        _allSchedules = schedules;
        if (_uniqueDates.isNotEmpty) {
          _selectedDate = _uniqueDates.first; // Mặc định hiển thị ngày đầu tiên của tuần
        } else {
          _selectedDate = null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Lọc lấy danh sách các tiết học của ngày đang chọn trên thanh trượt
  List<ScheduleItem> _getSchedulesForSelectedDate() {
    if (_selectedDate == null) return [];
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    return _allSchedules.where((s) => s.studyDate == dateString).toList();
  }

  @override
  Widget build(BuildContext context) {
    final schedulesToday = _getSchedulesForSelectedDate();

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
          'Thời khóa biểu',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Nút chọn Tuần theo UI
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedWeek,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                onChanged: (String? newValue) {
                  if (newValue != null && newValue != _selectedWeek) {
                    setState(() => _selectedWeek = newValue);
                    _loadScheduleData(); // Lấy lại dữ liệu khi đổi tuần
                  }
                },
                items: _weeks.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekBanner(),
          if (_uniqueDates.isNotEmpty) _buildDateSelector(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              children: [
                Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 8),
                const Text('Buổi sáng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ],
            ),
          ),
          Expanded(
            child: schedulesToday.isEmpty
                ? const Center(child: Text("Không có lịch học", style: TextStyle(color: AppColors.textLight)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: schedulesToday.length,
              itemBuilder: (context, index) {
                return _buildScheduleCard(schedulesToday[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekBanner() {
    String startDate = _uniqueDates.isNotEmpty ? DateFormat('dd/MM/yyyy').format(_uniqueDates.first) : '--/--/----';
    String endDate = _uniqueDates.isNotEmpty ? DateFormat('dd/MM/yyyy').format(_uniqueDates.last) : '--/--/----';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedWeek: $startDate - $endDate',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Học kỳ II • Năm học 2025-2026',
                    style: TextStyle(color: AppColors.textLight, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _uniqueDates.length,
        itemBuilder: (context, index) {
          final date = _uniqueDates[index];
          final isSelected = _selectedDate == date;

          final dayName = date.weekday == 7 ? 'CN' : 'T${date.weekday + 1}';
          final dayStr = DateFormat('dd/MM').format(date);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                border: isSelected ? null : Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayStr,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '${item.period}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.timeRange.replaceAll(' - ', '\n'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight, fontSize: 12, height: 1.3),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.subject, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.textLight),
                    const SizedBox(width: 8),
                    Text(item.room, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.textLight),
                    const SizedBox(width: 8),
                    Text(item.teacherName, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(Icons.access_time_outlined, color: AppColors.primary.withOpacity(0.5), size: 28),
          ),
        ],
      ),
    );
  }
}