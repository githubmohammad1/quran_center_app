import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quran_center_app/services/dio_client.dart';

class AuthApi {
  final DioClient _client = DioClient();
  final _storage = const FlutterSecureStorage();
Future<void> updateFcmToken(String token) async {
  await _client.post(
    "auth/update-fcm/",
    data: {"fcm_token": token},
  );
}

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _client.post(
        "auth/login/",
        data: {"phone": phone, "password": password},
      );
      final data = response.data;

      if (data["user"] == null) {
        throw Exception("الحساب ليس له ملف شخصي.");
      }

      await _storage.write(key: "access_token", value: data["access"]);
      await _storage.write(key: "refresh_token", value: data["refresh"]);

      return data["user"]; // إرجاع ماب ليتم تحويله في الـ Repository
    } on DioException catch (e) {
      throw Exception(e.response?.data["detail"] ?? "بيانات الدخول غير صحيحة.");
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: "refresh_token");
      if (refreshToken != null) {
        await _client.post("auth/logout/", data: {"refresh": refreshToken});
      }
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _client.post(
        "auth/change-password/",
        data: {"old_password": oldPassword, "new_password": newPassword},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data["detail"] ?? "فشل تغيير كلمة المرور.");
    }
  }

  // استخدام TokenRefreshView
  Future<String?> refreshToken() async {
    try {
      final refresh = await _storage.read(key: "refresh_token");
      if (refresh == null) return null;

      final response = await _client.post("auth/refresh/", data: {"refresh": refresh});
      final newAccess = response.data["access"];
      await _storage.write(key: "access_token", value: newAccess);
      return newAccess;
    } catch (e) {
      await _storage.deleteAll();
      return null;
    }
  }
}