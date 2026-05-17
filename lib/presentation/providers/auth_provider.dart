import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/person_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  PersonModel? user;
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => user != null;

  Future<bool> login(String phone, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      user = await _repo.login(phone, password);
// 🔥 الحصول على FCM Token
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      await _repo.sendFcmToken(fcmToken);
    }
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

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    try {
      await _repo.logout();
    } catch (_) {
    } finally {
      user = null;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final token = await _storage.read(key: "access_token");
      if (token == null) return false;

      final PersonModel? profile = await _repo.getProfile();
      if (profile == null) return false;

      user = profile;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  String _formatError(Object e) {
    return e.toString().replaceAll("Exception: ", "");
  }
}