import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/app_data.dart';
import '../services/api_service.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final ApiService _apiService = ApiService();
  List<GradeItem> _grades = [];
  bool _isLoading = true;
  String _selectedSemester = 'Học kì 1';
  double _semesterGPA = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString(StorageKeys.studentId) ?? '';

      // Gọi API lấy điểm từ ApiService của bạn
      final grades = await _apiService.getGrades(
        studentId: studentId,
        semester: _selectedSemester,
      );

      // Tính điểm trung bình học kỳ (GPA)
      double total = 0;
      if (grades.isNotEmpty) {
        for (var item in grades) {
          total += item.scoreAvg;
        }
        _semesterGPA = total / grades.length;
      }

      setState(() {
        _grades = grades;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bảng điểm',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // --- DROP DOWN CHỌN HỌC KỲ ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSemester,
                  isExpanded: true,
                  items: ['Học kì 1', 'Học kì 2']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedSemester = val);
                      _fetchGrades();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- CARD ĐIỂM TRUNG BÌNH (GPA) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _semesterGPA.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const Text(
                    'ĐIỂM TRUNG BÌNH HỌC KỲ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 20),
                  // Biểu đồ cột giả định (Mini Bar Chart)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMiniBar(40),
                      _buildMiniBar(55),
                      _buildMiniBar(70),
                      _buildMiniBar(90), // Cột cao nhất
                      _buildMiniBar(65),
                      _buildMiniBar(80),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- DANH SÁCH MÔN HỌC ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _grades.length,
              itemBuilder: (context, index) {
                return _buildSubjectTile(_grades[index]);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget vẽ cột biểu đồ mini
  Widget _buildMiniBar(double height) {
    return Container(
      width: 12,
      height: height / 2, // Scale lại cho vừa khung
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: height > 80 ? AppColors.primary : AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Widget vẽ từng môn học (Có thể mở rộng)
  Widget _buildSubjectTile(GradeItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getSubjectColor(item.subject).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getSubjectIcon(item.subject), color: _getSubjectColor(item.subject), size: 24),
          ),
          title: Text(item.subject, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
          subtitle: Text('Giáo viên: ${item.teacherName}', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.scoreAvg.toStringAsFixed(1),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScoreDetail('15 PHÚT', item.score15m),
                  _buildScoreDetail('1 TIẾT', item.score45m),
                  _buildScoreDetail('CUỐI KỲ', item.scoreFinal.toStringAsFixed(1)),
                  _buildScoreDetail('TB', item.scoreAvg.toStringAsFixed(1), isBold: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDetail(String label, String value, {bool isBold = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  // Logic lấy Icon theo tên môn học
  IconData _getSubjectIcon(String name) {
    if (name.contains('Toán')) return Icons.functions;
    if (name.contains('Ngữ văn')) return Icons.menu_book;
    if (name.contains('Tiếng Anh')) return Icons.language;
    if (name.contains('Vật lý')) return Icons.science_outlined;
    if (name.contains('Hóa học')) return Icons.biotech_outlined;
    return Icons.subject;
  }

  // Logic lấy Màu theo tên môn học
  Color _getSubjectColor(String name) {
    if (name.contains('Toán')) return Colors.orange;
    if (name.contains('Ngữ văn')) return Colors.deepOrangeAccent;
    if (name.contains('Tiếng Anh')) return Colors.blue;
    if (name.contains('Vật lý')) return Colors.purple;
    if (name.contains('Hóa học')) return Colors.teal;
    return AppColors.primary;
  }
}