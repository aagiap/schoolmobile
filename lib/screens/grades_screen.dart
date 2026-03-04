import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/app_data.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final _apiService = ApiService();
  final _sessionService = SessionService();

  final List<String> _semesterOptions = const ['Học kỳ I -2025-2026', 'Học kỳ II -2025-2026'];
  String _selectedSemester = 'Học kỳ II -2025-2026';

  bool _loading = true;
  String? _error;
  List<GradeItem> _grades = const [];

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final studentId = await _sessionService.getStudentId();
      if (studentId == null || studentId.isEmpty) {
        throw Exception('Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.');
      }

      final semesterParam = _selectedSemester.startsWith('Học kỳ I') ? 'Học kỳ I' : 'Học kỳ II';
      final data = await _apiService.getGrades(studentId: studentId, semester: semesterParam);

      if (!mounted) return;
      setState(() => _grades = data);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  double get _semesterAverage {
    final values = _grades.map((e) => e.scoreAvg).whereType<double>().toList();
    if (values.isEmpty) return 0;
    final total = values.reduce((a, b) => a + b);
    return total / values.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bảng điểm', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadGrades,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSemesterDropdown(),
            const SizedBox(height: 14),
            _buildAverageCard(),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _buildErrorCard()
            else if (_grades.isEmpty)
              _buildEmptyCard()
            else
              ..._grades.asMap().entries.map((entry) {
                final index = entry.key;
                final grade = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SubjectGradeCard(
                    grade: grade,
                    initiallyExpanded: index == 0,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSemester,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: _semesterOptions
              .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedSemester = value);
            _loadGrades();
          },
        ),
      ),
    );
  }

  Widget _buildAverageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _semesterAverage.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 52,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ĐIỂM TRUNG BÌNH HỌC KỲ',
            style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final heights = [18.0, 24, 30, 42, 30, 36];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: heights[i],
                decoration: BoxDecoration(
                  color: i >= 3 ? AppColors.primary : AppColors.primary.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Chưa có dữ liệu bảng điểm cho học kỳ này.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textLight),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(_error ?? 'Đã có lỗi xảy ra', style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadGrades, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _SubjectGradeCard extends StatelessWidget {
  const _SubjectGradeCard({required this.grade, required this.initiallyExpanded});

  final GradeItem grade;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final avgText = (grade.scoreAvg ?? 0).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconForSubject(grade.subject), color: AppColors.primary, size: 20),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                grade.subject,
                style: const TextStyle(
                  fontSize: 28 / 2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Giáo viên: ${grade.teacherName}',
                style: const TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
            ],
          ),
          trailing: Text(
            avgText,
            style: TextStyle(
              color: initiallyExpanded ? AppColors.primary : AppColors.textDark,
              fontWeight: FontWeight.w800,
              fontSize: 28 / 2,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ScoreColumn(title: '15 PHÚT', value: grade.score15m),
                  _ScoreColumn(title: '1 TIẾT', value: grade.score45m),
                  _ScoreColumn(
                    title: 'CUỐI KỲ',
                    value: grade.scoreFinal?.toStringAsFixed(1) ?? '-',
                  ),
                  _ScoreColumn(
                    title: 'TB',
                    value: grade.scoreAvg?.toStringAsFixed(1) ?? '-',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForSubject(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('toán')) return Icons.functions_rounded;
    if (s.contains('anh')) return Icons.language_rounded;
    if (s.contains('vật lý')) return Icons.science_outlined;
    if (s.contains('hóa')) return Icons.biotech_outlined;
    if (s.contains('văn')) return Icons.menu_book_outlined;
    return Icons.school_outlined;
  }
}

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({required this.title, required this.value, this.isHighlight = false});

  final String title;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isHighlight ? AppColors.primary : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24 / 2,
            fontWeight: FontWeight.w800,
            color: isHighlight ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
