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
    return user?.roles.contains(role) ?? false;
  }

  // =========================================================================
  // 🎯 ميكانيكية حوكمة الأولويات: تحديد الدور النشط الافتراضي بناءً على الهرم الإداري
  // =========================================================================
  String _determineDefaultRole(PersonModel person) {
    if (person.roles.contains('admin')) {
      print("👑 تم رصد صلاحية (admin)، تعيين واجهة المدير كأولوية قصوى.");
      return 'admin';
    } else if (person.roles.contains('supervisor')) {
      print("📋 تم رصد صلاحية (supervisor)، تعيين واجهة الموجه كأولوية ثانية.");
      return 'supervisor';
    } else if (person.roles.contains('teacher')) {
      print("💡 تم رصد صلاحية (teacher)، تعيين واجهة المعلم كأولوية ثالثة.");
      return 'teacher';
    } else {
      print("👤 مستخدم عادي، تعيين الواجهة بناءً على الدور المفرد الافتراضي: ${person.role}");
      return person.role;
    }
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
        print("🔍 الأدوار المستلمة من السيرفر: ${user!.roles}");
        
        // 2. 🚀 ضبط الدور الافتراضي النشط بناءً على مصفوفة الأولويات الموحدة
        currentRole = _determineDefaultRole(user!);
        
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
      notifyListeners(); // لتحديث واجهة فلاتر فوراً واحتساب الـ Multi-Views
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
    print("🔄 محاولة إرسال طلب تسجيل الخروج لسيرفر Django...");
    // إرسال الطلب للسيرفر
    await _repo.logout(); 
    print("✅ تم إبطال الجلسة من السيرفر بنجاح");
  } catch (e) {
    // 🎯 اقتناص الخطأ هنا يمنع تجميد واجهات فلاتر
    print("⚠️ تنبيه جودة: السيرفر رفض الطلب أو التوكن منتهي بالفعل ($e). سيتم التجاوز للتطهير المحلي حتماً.");
  } finally {
    // 🚀 التطهير المحلي الحتمي: ينفذ دائماً حتى لو انقطع الإنترنت أو فشل السيرفر
    user = null;
    currentRole = null;
    error = null;
    isLoading = false;
    
    // مسح الـ Secure Storage محلياً لضمان عدم بقاء أي أثر للتوكن التالف
    await _storage.deleteAll(); 
    
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

      // 4. 🚀 استهلاك الدالة الموحدة لضمان تطابق سلوك الـ Auto Login مع الـ Login العادي 100%
      currentRole = _determineDefaultRole(user!);

      notifyListeners();
      return true;
    } catch (e) {
      print("⚠️ فشل الدخول التلقائي أو التوكن منتهي الصلاحية.");
      return false;
    }
  }

  String _formatError(Object e) {
    return e.toString().replaceAll("Exception: ", "");
  }
}