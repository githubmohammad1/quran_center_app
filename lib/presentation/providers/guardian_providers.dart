import 'package:flutter/material.dart';
import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/student_progress_model.dart';
import '../../data/models/memorization_session_model.dart'; // 🚀 تحديث الجودة: استيراد النماذج الجديدة
import '../../data/models/notification_model.dart';
import '../../data/repositories/guardian_repository.dart';

class GuardianProvider extends ChangeNotifier {
  final GuardianRepository _repo = GuardianRepository();

  // مصفوفات الحالة المركزية
  List<PersonModel> children = [];
  PersonModel? selectedChild;
  List<AttendanceModel> attendance = [];
  List<QuranTestModel> tests = [];
  StudentProgressModel? progress;
  List<MemorizationSessionModel> memorizationSessions = []; // 🚀 إضافة حالة التسميع الحية
  List<NotificationModel> notifications = [];               // 🚀 إضافة حالة مركز الإشعارات

  // مؤشرات التحكم بالواجهات
  bool loading = false;
  String? error;

  // =========================================================================
  // 1. جلب قائمة الأبناء التابعين للمستخدم الحالي
  // =========================================================================
  Future<void> loadChildren() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      children = await _repo.getChildren();

      // التمكين التلقائي: إذا كان لولي الأمر أبناء، نحدد الابن الأول بشكل افتراضي ونشحن بياناته
      if (children.isNotEmpty && selectedChild == null) {
        await selectChild(children.first);
      } else {
        loading = false;
        notifyListeners();
      }
    } catch (e) {
      loading = false;
      error = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }

  // =========================================================================
  // 2. التحكم بدورة حياة التبديل بين الأبناء (Active Child Lifecycle)
  // =========================================================================
  Future<void> selectChild(PersonModel child) async {
    selectedChild = child;
    // تصفير آمن للسجلات السابقة لمنع ظهور بيانات الابن القديم أثناء تحميل بيانات الابن الجديد
    attendance = [];
    tests = [];
    progress = null;
    memorizationSessions = [];
    notifyListeners();

    // استدعاء الشحن المتوازي عبر المعرّف الرقمي الحصري للابن
    await loadChildData(child.id);
  }

  // =========================================================================
  // 3. جلب بيانات الابن المحدّد بشكل متوازٍ ومحصّن رقمياً (Parallel Future Execution)
  // =========================================================================
 // 📁 الملف: guardian_provider.dart

// 📁 الملف: guardian_provider.dart

// =========================================================================
  // 3. جلب بيانات الابن المحدّد بشكل متوازٍ ومحصّن ضد أخطاء الحافة (Fault-Tolerant)
  // =========================================================================
  Future<void> loadChildData(int childId, {String? childName}) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      // 1. جلب الملف الشخصي أولاً (خطوة حرجية تعطل الصفحة لو فشلت بالكامل)
      try {
        selectedChild = await _repo.getChildProfile(childId);
      } catch (e) {
        print("❌ خطأ حرج في جلب ملف الطالب الشخصي: $e");
        throw Exception("profile_failed");
      }

      // 2. 🚀 شحن الطلبات المتوازية مع تحصين فردي لكل طلب (No More All-or-Nothing)
      // إذا أرجع السيرفر 404 لأي قسم، يعود بمصفوفة فارغة ويستمر التطبيق بالعمل بأمان
      final results = await Future.wait([
        _repo.getChildAttendance(childId).catchError((e) {
          print("⚠️ خطأ غير حرج في الحضور (تم التجاوز بأمان): $e");
          return <AttendanceModel>[]; // البديل الآمن
        }),
        _repo.getChildTests(childId).catchError((e) {
          print("⚠️ خطأ غير حرج في الاختبارات (تم التجاوز بأمان): $e");
          return <QuranTestModel>[]; // البديل الآمن
        }),
        _repo.getChildProgress(childId).catchError((e) {
          print("⚠️ خطأ غير حرج في التقدم الدراسي (تم التجاوز بأمان): $e");
          return null; // البديل الآمن لولي أمر طالب جديد
        }),
        _repo.getChildMemorizationSessions(childId).catchError((e) {
          print("⚠️ خطأ غير حرج في جلسات التسميع (تم التجاوز بأمان): $e");
          return <MemorizationSessionModel>[]; // البديل الآمن
        }),
      ]);

      // 3. توزيع البيانات المستلمة بنجاح وأمان كامل على المصفوفات المركزية
      attendance = results[0] as List<AttendanceModel>;
      tests = results[1] as List<QuranTestModel>;
      progress = results[2] as StudentProgressModel?;
      memorizationSessions = results[3] as List<MemorizationSessionModel>;

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      // 🚀 استبدال الرسائل التقنية الجافة برسالة هادئة ومفهومة للمستخدم النهائي
      error = _mapErrorToUserFriendlyMessage(e);
      notifyListeners();
    }
  }

  // 🔒 دالة عزل وتوطين الأخطاء لضمان رصانة العرض الإنساني
  String _mapErrorToUserFriendlyMessage(Object e) {
    final errorStr = e.toString();
    if (errorStr.contains("profile_failed")) {
      return "تعذر تحميل ملف الطالب الشخصي، يرجى التحقق من اتصالك بالشبكة.";
    } else if (errorStr.contains("404")) {
      return "بعض البيانات المطلوبة غير متوفرة حالياً على الخادم.";
    } else if (errorStr.contains("timeout") || errorStr.contains("NetworkImage")) {
      return "اتصال الإنترنت ضعيف أو مقطوع، يرجى إعادة المحاولة لاحقاً.";
    }
    return "حدث خطأ غير متوقع أثناء تحديث لوحة المتابعة، نعمل على إصلاحه.";
  }  // =========================================================================
  // 4. مركز التحكم بالإشعارات (Notification Center Management)
  // =========================================================================
  Future<void> loadNotifications() async {
    try {
      error = null;
      notifications = await _repo.getNotifications();
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }

  // التفاعل الحي: تأكيد قراءة الإشعار محلياً وتحديث السيرفر تزامنياً
  Future<void> markNotificationAsRead(int notificationId) async {
    // تحديث تفاؤلي سريع في الواجهة (Optimistic Update) لتعزيز انسيابية تجربة المستخدم
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      // بما أن النماذج غير قابلة للتعديل المباشر (Immutable)، نقوم بإعادة البناء باستخدام التعديل المحلي
      final currentNotif = notifications[index];
      notifications[index] = NotificationModel(
        id: currentNotif.id,
        student: currentNotif.student,
        title: currentNotif.title,
        message: currentNotif.message,
        category: currentNotif.category,
        sourceObjectId: currentNotif.sourceObjectId,
        semester: currentNotif.semester,
        createdAt: currentNotif.createdAt,
        isRead: true, // وسمها كمقروءة فوراً
      );
      notifyListeners();
    }

    // إعلام الخلفية (Backend API) في الخلفية دون تعطيل واجهة المستخدم
    await _repo.markNotificationAsRead(notificationId);
  }
}