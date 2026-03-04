class GradeItem {
  final String subject;
  final String teacherName;
  final String score15m;
  final String score45m;
  final double scoreFinal;
  final double scoreAvg;

  GradeItem.fromJson(Map<String, dynamic> json)
      : subject = json['subject'] ?? '',
        teacherName = json['teacherName'] ?? '',
        score15m = json['score15m'] ?? '-',
        score45m = json['score45m'] ?? '-',
        scoreFinal = (json['scoreFinal'] != null) ? (json['scoreFinal'] as num).toDouble() : 0.0,
        scoreAvg = (json['scoreAvg'] != null) ? (json['scoreAvg'] as num).toDouble() : 0.0;
}

class ScheduleItem {
  final String studyDate;
  final int period;
  final String subject;
  final String teacherName;
  final String room;
  final String timeRange;

  ScheduleItem.fromJson(Map<String, dynamic> json)
      : studyDate = json['studyDate'] ?? '',
        period = json['period'] ?? 0,
        subject = json['subject'] ?? '',
        teacherName = json['teacherName'] ?? '',
        room = json['room'] ?? '',
        timeRange = json['timeRange'] ?? '';
}

class ExamItem {
  final String subject;
  final String examDateTime;
  final String room;
  final int durationMinutes;

  ExamItem.fromJson(Map<String, dynamic> json)
      : subject = json['subject'] ?? '',
        examDateTime = json['examDateTime'] ?? '',
        room = json['room'] ?? '',
        durationMinutes = json['durationMinutes'] ?? 0;
}

class AttendanceSummary {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final double percentage;
  final List<dynamic> details;

  AttendanceSummary.fromJson(Map<String, dynamic> json)
      : totalDays = json['totalDays'] ?? 0,
        presentDays = json['presentDays'] ?? 0,
        absentDays = json['absentDays'] ?? 0,
        percentage = (json['percentage'] ?? 0).toDouble(),
        details = json['details'] ?? [];
}

class NotificationItem {
  final String type;
  final String title;
  final String content;
  final String createdAt;

  NotificationItem.fromJson(Map<String, dynamic> json)
      : type = json['type'] ?? '',
        title = json['title'] ?? '',
        content = json['content'] ?? '',
        createdAt = json['createdAt'] ?? '';
}