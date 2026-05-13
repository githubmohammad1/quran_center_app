// lib/presentation/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/person_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  PersonModel? user;
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => user != null;

  // تسجيل الدخول
  Future<bool> login(String phone, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      user = await _repo.login(phone, password);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      error = _formatError(e);
      notifyListeners();
      return false;
    }
  }

  // تغيير كلمة المرور
  Future<bool> changePassword(String oldPass, String newPass) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _repo.changePassword(oldPass, newPass);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      error = _formatError(e);
      notifyListeners();
      return false;
    }
  }

  // تحديث FCM Token
  Future<void> updateFcmToken(String token) async {
    try {
      await _repo.updateFcmToken(token);
    } catch (_) {}
  }

  // تسجيل الخروج
  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await _repo.logout();
    } catch (_) {
      // تجاهل أخطاء الخروج من السيرفر
    } finally {
      user = null;
      isLoading = false;
      notifyListeners();
    }
  }

  String _formatError(Object e) {
    final msg = e.toString();
    return msg.replaceAll("Exception: ", "");
  }

  // -------------------------
  // التخزين الآمن و Try Auto Login
  // -------------------------
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// تحاول استرجاع التوكن ثم جلب بروفايل المستخدم من السيرفر.
  /// تعيد true إذا نجحت واسترجعت PersonModel صالح.
  Future<bool> tryAutoLogin() async {
    try {
      final token = await _storage.read(key: "access_token");
      if (token == null) return false;

      // جلب البروفايل من الريبو (الريبو يتعامل مع StudentApi)
      final PersonModel? profile = await _repo.getProfile();

      if (profile == null) {
        // التوكن قد يكون منتهي أو غير صالح
        return false;
      }

      // الآن النوع صحيح، نعيّن إلى user
      user = profile;
      notifyListeners();
      return true;
    } catch (e) {
      // لا نرمي الخطأ للأعلى هنا، نعيد false ليتعامل SplashScreen
      return false;
    }
  }
}
