import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/person_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  PersonModel? user;
  String? currentRole;
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => user != null;

  // =========================================================================
  // 🚀 تحديث جودة: دالة فحص الصلاحيات والأدوار المتعددة بشكل آمن (Null-Safe)
  // =========================================================================
  bool hasRole(String role) {
    // التحقق المشروط يمنع انهيار التطبيق إذا كان كائن المستخدم فارغاً
    return user?.roles.contains(role) ?? false;
  }

  // =========================================================================
  // 1. منطق تسجيل الدخول وحقن الأدوار والـ FCM Token
  // =========================================================================
  Future<bool> login(String phone, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      // 1. جلب البيانات وحقنها في الموديل الجديد المتعدد الأدوار
      user = await _repo.login(phone, password);

      if (user != null) {
        // 2. 🚀 ضبط الدور الافتراضي عند أول دخول للموقع
        if (user!.roles.contains('teacher')) {
          print("💡 تم رصد دور (teacher)، تهيئة الواجهة النشطة كمعلم كأولوية.");
          currentRole = 'teacher'; 
        } else {
          print("💡 مستخدم عادي، تهيئة الواجهة النشطة بناءً على الدور المفرد: ${user!.role}");
          currentRole = user!.role; 
        }
      } else {
        print("🚨 تنبيه جودة: كائن المستخدم عاد فارغاً (null) من مستودع البيانات.");
      }

      // 3. 🚀 الحصول على FCM Token وحمايته برمجياً
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          print("📲 رمز FCM المكتشف: $fcmToken");
          await _repo.sendFcmToken(fcmToken);
        }
      } catch (fcmError) {
        print("⚠️ تنبيه جودة: فشل تحديث رمز الإشعارات ولكن تم تجاوز الخطأ: $fcmError");
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      error = _formatError(e);
      print("❌ خطأ فادح أثناء تسجيل الدخول: $e");
      notifyListeners();
      return false;
    }
  }

  // =========================================================================
  // 2. التبديل الآمن واللحظي بين شاشات التطبيق (الأساتذة / الطلاب / الأولياء)
  // =========================================================================
  void switchRole(String newRole) {
    if (user != null && user!.roles.contains(newRole)) {
      print("🔄 جاري التبديل الآمن للدور النشط من [$currentRole] إلى -> [$newRole]");
      currentRole = newRole;
      notifyListeners(); // لتحديث واجهة فلاتر فوراً
    } else {
      print("🚫 رفض التبديل: المستخدم لا يملك الصلاحية [$newRole] ضمن مصفوفة أدوارة المتاحة.");
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
      currentRole = null; // تصفير الدور النشط للأمان
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // 3. الفحص التلقائي للجلسة النشطة عند فتح التطبيق (Auto Login)
  // =========================================================================
  Future<bool> tryAutoLogin() async {
    try {
      final token = await _storage.read(key: "access_token");
      if (token == null) return false;

      final PersonModel? profile = await _repo.getProfile();
      if (profile == null) return false;

      user = profile;

      // 4. 🚀 التحديث الهندسي: تهيئة الدور النشط فوراً عند الفتح التلقائي للتطبيق
      if (user!.roles.contains('teacher')) {
        currentRole = 'teacher';
      } else if (user!.roles.contains('supervisor')) {
        currentRole = 'supervisor';
      } else {
        currentRole = user!.role; 
      }

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