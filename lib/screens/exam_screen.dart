import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/app_data.dart';
import '../services/api_service.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<ExamItem> _exams = [];

  // Map cấu hình Học kỳ để hiển thị UI đẹp hơn (Khớp DB SQL: 'Học kì 1', 'Học kì 2')
  final Map<String, String> _semesters = {
    'Học kì 1': 'Học kỳ I - 2025-2026',
    'Học kì 2': 'Học kỳ II - 2025-2026',
  };
  String _selectedApiSemester = 'Học kì 2'; // Mặc định hiển thị HK2

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() => _isLoading = true);
    try {
      // 1. Lấy ID học sinh từ bộ nhớ
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString(StorageKeys.studentId) ?? '';

      if (studentId.isEmpty) {
        throw Exception('Không tìm thấy thông tin học sinh.');
      }

      // 2. Gọi API lấy lịch thi
      final data = await _apiService.getExams(
        studentId: studentId,
        semester: _selectedApiSemester,
      );

      setState(() => _exams = data);
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

  @override
  Widget build(BuildContext context) {
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
          'Lịch thi học kỳ',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Phần chọn học kỳ ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHỌN HỌC KỲ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedApiSemester,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                      onChanged: (String? newValue) {
                        if (newValue != null && newValue != _selectedApiSemester) {
                          setState(() => _selectedApiSemester = newValue);
                          _fetchExams(); // Tải lại dữ liệu
                        }
                      },
                      items: _semesters.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Danh sách môn thi ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _exams.isEmpty
                ? const Center(child: Text("Không có lịch thi cho học kỳ này", style: TextStyle(color: AppColors.textLight)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              itemCount: _exams.length,
              itemBuilder: (context, index) {
                return _buildExamCard(_exams[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Khối Card hiển thị lịch thi của 1 môn
  Widget _buildExamCard(ExamItem exam) {
    // 1. Phân tích chuỗi thời gian (Ví dụ: "2026-03-20 07:30:00" -> DateTime)
    DateTime examDate;
    try {
      // Đảm bảo parse được cả định dạng có khoảng trắng của SQL
      examDate = DateTime.parse(exam.examDateTime.replaceFirst(' ', 'T'));
    } catch (e) {
      examDate = DateTime.now(); // Fallback nếu dữ liệu lỗi
    }

    // 2. Format dữ liệu theo đúng UI
    final monthStr = 'THÁNG ${examDate.month}';

    // Đổi thứ sang tiếng Việt
    const weekdays = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    final weekdayStr = weekdays[examDate.weekday - 1];
    final dateStr = DateFormat('dd/MM/yyyy').format(examDate);
    final fullDateText = '$weekdayStr, $dateStr';

    final timeStr = DateFormat('HH:mm').format(examDate);
    final amPm = examDate.hour < 12 ? 'sáng' : 'chiều';
    final fullTimeText = '$timeStr $amPm';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột trái: Khối màu cam nhạt hiển thị Tháng
          Container(
            width: 70,
            height: 75,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month, color: AppColors.primary, size: 28),
                const SizedBox(height: 4),
                Text(
                  monthStr,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Cột phải: Thông tin chi tiết
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên môn thi & Badge số phút
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exam.subject,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${exam.durationMinutes} phút',
                        style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Các hàng thông tin (Ngày, Giờ, Phòng)
                _buildDetailRow(Icons.calendar_today_outlined, fullDateText),
                const SizedBox(height: 6),
                _buildDetailRow(Icons.access_time_outlined, fullTimeText),
                const SizedBox(height: 6),
                _buildDetailRow(Icons.meeting_room_outlined, 'Phòng thi: ${exam.room}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper tạo một hàng thông tin nhỏ (icon + text)
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.textLight),
        ),
      ],
    );
  }
}