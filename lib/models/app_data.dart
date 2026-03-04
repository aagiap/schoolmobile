class GradeItem {
  const GradeItem({
    required this.subject,
    required this.teacherName,
    required this.score15m,
    required this.score45m,
    required this.scoreFinal,
    required this.scoreAvg,
  });

  final String subject;
  final String teacherName;
  final String score15m;
  final String score45m;
  final double? scoreFinal;
  final double? scoreAvg;

  factory GradeItem.fromJson(Map<String, dynamic> json) => GradeItem(
    subject: (json['subject'] ?? '') as String,
    teacherName: (json['teacherName'] ?? '') as String,
    score15m: (json['score15m'] ?? '') as String,
    score45m: (json['score45m'] ?? '') as String,
    scoreFinal: (json['scoreFinal'] as num?)?.toDouble(),
    scoreAvg: (json['scoreAvg'] as num?)?.toDouble(),
  );
}

class ScheduleItem {
  const ScheduleItem({
    required this.studyDate,
    required this.period,
    required this.subject,
    required this.teacherName,
    required this.room,
    required this.timeRange,
  });

  final DateTime? studyDate;
  final int? period;
  final String subject;
  final String teacherName;
  final String room;
  final String timeRange;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
    studyDate: json['studyDate'] != null
        ? DateTime.tryParse(json['studyDate'] as String)
        : null,
    period: json['period'] as int?,
    subject: (json['subject'] ?? '') as String,
    teacherName: (json['teacherName'] ?? '') as String,
    room: (json['room'] ?? '') as String,
    timeRange: (json['timeRange'] ?? '') as String,
  );
}

class ExamItem {
  const ExamItem({
    required this.subject,
    required this.examDateTime,
    required this.room,
    required this.durationMinutes,
  });

  final String subject;
  final DateTime? examDateTime;
  final String room;
  final int? durationMinutes;

  factory ExamItem.fromJson(Map<String, dynamic> json) => ExamItem(
    subject: (json['subject'] ?? '') as String,
    examDateTime: json['examDateTime'] != null
        ? DateTime.tryParse(json['examDateTime'] as String)
        : null,
    room: (json['room'] ?? '') as String,
    durationMinutes: json['durationMinutes'] as int?,
  );
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.attendanceDate,
    required this.status,
    required this.note,
  });

  final DateTime? attendanceDate;
  final String status;
  final String note;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
    attendanceDate: json['attendanceDate'] != null
        ? DateTime.tryParse(json['attendanceDate'] as String)
        : null,
    status: (json['status'] ?? '') as String,
    note: (json['note'] ?? '') as String,
  );
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.percentage,
    required this.details,
  });

  final int totalDays;
  final int presentDays;
  final int absentDays;
  final double percentage;
  final List<AttendanceRecord> details;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      AttendanceSummary(
        totalDays: (json['totalDays'] ?? 0) as int,
        presentDays: (json['presentDays'] ?? 0) as int,
        absentDays: (json['absentDays'] ?? 0) as int,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
        details: ((json['details'] as List<dynamic>?) ?? [])
            .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class NotificationItem {
  const NotificationItem({
    required this.type,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  final String type;
  final String title;
  final String content;
  final DateTime? createdAt;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        type: (json['type'] ?? '') as String,
        title: (json['title'] ?? '') as String,
        content: (json['content'] ?? '') as String,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}
