import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/student.dart';

class SessionService {
  Future<void> saveStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.studentId, student.studentId);
    await prefs.setString(StorageKeys.className, student.className);
    await prefs.setString(StorageKeys.fullName, student.fullName);
    await prefs.setString(StorageKeys.phone, student.phone);
  }

  Future<String?> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.studentId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.studentId);
    await prefs.remove(StorageKeys.className);
    await prefs.remove(StorageKeys.fullName);
    await prefs.remove(StorageKeys.phone);
  }
}
