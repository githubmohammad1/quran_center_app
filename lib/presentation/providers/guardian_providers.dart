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

Future<void> loadChildData(int childId, {String? childName}) async {
  try {
    loading = true;
    error = null;
    notifyListeners();

    // 1. جلب الملف الشخصي أولاً
    selectedChild = await _repo.getChildProfile(childId);
    
    // 2. 🚀 شحن كافة الطلبات المتوازية بأمان رقمي كامل يتوافق مع معايير Clean Architecture
    final results = await Future.wait([
      _repo.getChildAttendance(childId),           // 🎯 تم الإصلاح: تمرير الـ ID كـ int بدلاً من الاسم
      _repo.getChildTests(childId),                // تستقبل int
      _repo.getChildProgress(childId),             // تستقبل int
      _repo.getChildMemorizationSessions(childId), // 🚀 تم الدمج: جلب جلسات التسميع الحية المفقودة سابقاً للوحة المتابعة
    ]);

    // 3. توزيع البيانات المستلمة على المصفوفات المركزية لتغذية الواجهات
    attendance = results[0] as List<AttendanceModel>;
    tests = results[1] as List<QuranTestModel>;
    progress = results[2] as StudentProgressModel?;
    memorizationSessions = results[3] as List<MemorizationSessionModel>; // 🎯 تعيين البيانات بنجاح

    loading = false;
    notifyListeners();
  } catch (e) {
    loading = false;
    error = e.toString().replaceAll("Exception: ", "");
    notifyListeners();
  }
}
  // =========================================================================
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