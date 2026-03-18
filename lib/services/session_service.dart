import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/student.dart';

class SessionService {

  Future<void> saveAuthSession(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, auth.token);
    await prefs.setString(StorageKeys.role, auth.role);

    if (auth.studentProfile != null) {
      await prefs.setString(StorageKeys.studentId, auth.studentProfile!.studentId);
      await prefs.setString(StorageKeys.className, auth.studentProfile!.className);
      await prefs.setString(StorageKeys.fullName, auth.studentProfile!.fullName);
      await prefs.setString(StorageKeys.phone, auth.studentProfile!.phone);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.token);
  }

  Future<String?> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.studentId);
  }

  // Xóa sạch cả token khi đăng xuất
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.role);
    await prefs.remove(StorageKeys.studentId);
    await prefs.remove(StorageKeys.className);
    await prefs.remove(StorageKeys.fullName);
    await prefs.remove(StorageKeys.phone);
  }
}