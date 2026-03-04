class Student {
  const Student({
    required this.studentId,
    required this.fullName,
    required this.className,
    required this.phone,
    this.email,
    this.academicYear,
    this.dob,
  });

  final String studentId;
  final String fullName;
  final String className;
  final String phone;
  final String? email;
  final String? academicYear;
  final DateTime? dob;

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: (json['studentId'] ?? '') as String,
      fullName: (json['fullName'] ?? '') as String,
      className: (json['className'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      email: json['email'] as String?,
      academicYear: json['academicYear'] as String?,
      dob: json['dob'] != null ? DateTime.tryParse(json['dob'] as String) : null,
    );
  }
}
