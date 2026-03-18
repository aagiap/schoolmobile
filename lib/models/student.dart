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
    String phoneVal = '';
    if (json['phone'] != null) {
      phoneVal = json['phone'].toString();
    } else if (json['user'] != null && json['user']['phone'] != null) {
      phoneVal = json['user']['phone'].toString();
    }

    return Student(
      studentId: (json['studentId'] ?? '') as String,
      fullName: (json['fullName'] ?? '') as String,
      className: (json['className'] ?? '') as String,
      phone: phoneVal,
      email: json['email'] as String?,
      academicYear: json['academicYear'] as String?,
      dob: json['dob'] != null ? DateTime.tryParse(json['dob'] as String) : null,
    );
  }
}

class AuthResponse {
  final String token;
  final String role;
  final Student? studentProfile;

  AuthResponse({
    required this.token,
    required this.role,
    this.studentProfile,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      role: json['role'] ?? '',
      studentProfile: json['profile'] != null ? Student.fromJson(json['profile']) : null,
    );
  }
}