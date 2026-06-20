
import 'package:quran_center_app/services/api/auth_api.dart';
import 'package:quran_center_app/services/api/student_api.dart';

import '../../data/models/person_model.dart';

class AuthRepository {
  final AuthApi _authApi = AuthApi();
  final StudentApi _studentApi = StudentApi();

  Future<PersonModel> login(String phone, String password) async {
    final data = await _authApi.login(phone, password);
    return PersonModel.fromJson(data);
  }

  Future<void> logout() async {
    await _authApi.logout();
  }

Future<void> changePassword(String oldPass, String newPass) async {
    await _authApi.changePassword(oldPass, newPass);
  }
Future<void> sendFcmToken(String token) async {
  await _authApi.updateFcmToken(token);
}

  Future<String?> refreshToken() async {
    return await _authApi.refreshToken();
  }

  /// جلب بروفايل المستخدم الحالي
  Future<PersonModel?> getProfile() async {
    try {
      final profileData = await _studentApi.getProfile();
      return PersonModel.fromJson(profileData);
    } catch (e) {
      return null;
    }
  }
}