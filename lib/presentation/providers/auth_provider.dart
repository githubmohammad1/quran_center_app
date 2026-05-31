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

  Future<bool> login(String phone, String password) async {
  try {
    isLoading = true;
    error = null;
    notifyListeners();

    // 1. جلب البيانات وحقنها في الموديل الجديد المتعدد الأدوار
    user = await _repo.login(phone, password);

    if (user != null) {


      // 2. 🚀 ضبط الدور الافتراضي عند أول دخول للموقع
      // إذا كان المستخدم طالباً ومدرساً بنفس الوقت، نجعله يدخل كمعلم كأولوية لإدارة الحلقة
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
    // 🚨 طباعة تفصيلية للخطأ في حال انهيار عملية تسجيل الدخول
    print("❌ خطأ فادح أثناء تسجيل الدخول: $e");
    notifyListeners();
    return false;
  }
}

// 🚀 دالة ذكية جديدة تتيح للطالب الكبير تبديل شاشته داخل المسجد بضغطة زر
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
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      // 1. التحقق من وجود التوكن محلياً بشكل آمن
      final token = await _storage.read(key: "access_token");
      if (token == null) return false;

      // 2. جلب الملف الشخصي المحدث من السيرفر (والذي يحتوي على مصفوفة roles الآن)
      final PersonModel? profile = await _repo.getProfile();
      if (profile == null) return false;

      // 3. تخزين ملف المستخدم في الحالة (State)
      user = profile;

      // 4. 🚀 التحديث الهندسي: تهيئة الدور النشط فوراً عند الفتح التلقائي للتطبيق
      // إذا كان الطالب الكبير يملك صلاحية أستاذ، نمنحه واجهة الأستاذ كأولوية لإدارة حلقته
      if (user!.roles.contains('teacher')) {
        currentRole = 'teacher';
      } else if (user!.roles.contains('supervisor')) {
        currentRole = 'supervisor';
      } else {
        currentRole =
            user!.role; // الدور الافتراضي المتاح (student أو guardian)
      }

      notifyListeners();
      return true;
    } catch (e) {
      // تنبيه جودة: في حال حدوث خطأ شبكة (Network Timeout) والسيرفر لم يستجب،
      // يمكنك مستقبلاً تطوير هذا الجزء ليقرأ البيانات الكاش المخزنة محلياً بدلاً من إرجاع false مباشرة.
      return false;
    }
  }

  String _formatError(Object e) {
    return e.toString().replaceAll("Exception: ", "");
  }
}
