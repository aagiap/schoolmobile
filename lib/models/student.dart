class Student {
  final String studentId;
  final String fullName;
  final String className;
  final String phone;

  Student({
    required this.studentId,
    required this.fullName,
    required this.className,
    required this.phone,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? '',
      fullName: json['fullName'] ?? '',
      className: json['className'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}