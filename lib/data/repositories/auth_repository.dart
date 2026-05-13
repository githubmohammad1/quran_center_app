// lib/data/repositories/auth_repository.dart

import 'package:quran_center_app/services/api/auth_api.dart';
import 'package:quran_center_app/services/api/student_api.dart';


import '../../data/models/person_model.dart';

class AuthRepository {
  final AuthApi _authApi = AuthApi();
  final StudentApi _studentApi = StudentApi();

  Future<PersonModel> login(String phone, String password) async {
    return await _authApi.login(phone, password);
  }

  Future<void> logout() async {
    await _authApi.logout();
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    await _authApi.changePassword(oldPass, newPass);
  }

  Future<void> updateFcmToken(String token) async {
    await _authApi.updateFcmToken(token);
  }

  /// جلب بروفايل المستخدم الحالي من السيرفر
  /// يفترض أن StudentApi.getProfile() يعيد PersonModel
  Future<PersonModel?> getProfile() async {
    try {
      final profile = await _studentApi.getProfile();
      return profile;
    } catch (e) {
      // إذا فشل الجلب (مثلاً توكن منتهي) نعيد null
      return null;
    }
  }
}
