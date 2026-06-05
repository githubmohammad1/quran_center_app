// presentation/providers/student_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/memorization_session_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/student_progress_model.dart';
import '../../data/repositories/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository _repo = StudentRepository();

  PersonModel? profile;
  List<AttendanceModel> attendance = [];
  List<MemorizationSessionModel> memorization = [];
  List<QuranTestModel> tests = [];
  List<NotificationModel> notifications = [];
  StudentProgressModel? progress;

  bool loading = false;
  String? error;

  /// 🧹 تصفير البيانات عند تسجيل الخروج لمنع تسريب البيانات بين الحسابات
  void clearData() {
    progress = null;
    profile = null;
    loading = false;
    error = null;
    attendance.clear();
    memorization.clear();
    tests.clear();
    notifications.clear();
    notifyListeners();
  }

  /// 📥 جلب وتحديث كافة بيانات لوحة الطالب بشكل متوازٍ ومستحم
  Future<void> loadAll({bool isRefresh = false}) async {
    try {
      error = null;
      loading = true;
      // منع الوميض البصري (Visual Flicker) إذا كان التحديث يتم سحباً للخلف (Pull to Refresh)
      if (!isRefresh) notifyListeners();

      // 1. جلب الملف الشخصي أولاً لتحديد الـ ID والهوية الأمنية
      profile = await _repo.getProfile(); //

      if (profile == null) {
        loading = false;
        error = "لم يتم العثور على ملف المستخدم الشخصي.";
        notifyListeners();
        return;
      }

      final studentId = profile!.id;

      // 2. 🛠️ حماية الـ Futures داخلياً عبر هندسة التزامن الدفاعي لضمان عدم سقوط المنظومة كلياً
      final results = await Future.wait([
        _repo.getAttendance().catchError((e) { //
          debugPrint("⚠️ تنبيه جودة: فشل جلب سجل الحضور: $e");
          return <AttendanceModel>[]; // عودة بمصفوفة فارغة لحماية الشاشة
        }),
        _repo.getMemorizationSessions().catchError((e) { //
          debugPrint("⚠️ تنبيه جودة: فشل جلب جلسات التسميع: $e");
          return <MemorizationSessionModel>[];
        }),
        _repo.getTests(studentId).catchError((e) { //
          debugPrint("⚠️ تنبيه جودة: فشل جلب اختبارات الأجزاء والسور: $e");
          return <QuranTestModel>[];
        }),
        _repo.getNotifications().catchError((e) { //
          debugPrint("⚠️ تنبيه جودة: فشل جلب إشعارات الطالب: $e");
          return <NotificationModel>[];
        }),
       // داخل دالة loadAll() في كلاس StudentProvider

_repo.getProgress().catchError((e) {
  debugPrint("⚠️ تنبيه جودة: فشل جلب الإحصائيات التراكمية ولوحة التقدم: $e");
  
  // 🔥 الحل الصحيح: بناء كائن افتراضي مصفّر يطابق الـ Constructor الخاص بـ StudentProgressModel تماماً
  return StudentProgressModel(
    id: 0,
    student: null,
    totalPagesMemorized: 0,
    lastPage: 0,
    points: 0,
    totalPartsTested: 0,
    totalSurahsTested: 0,
    lastPartTested: 0,
    lastTestDate: null,
    updatedAt: null,
  );
}),
      ]);

      // 3. صب البيانات المستقرة بنجاح في مجاريها الخاصة
      attendance = results[0] as List<AttendanceModel>;
      memorization = results[1] as List<MemorizationSessionModel>;
      tests = results[2] as List<QuranTestModel>;
      notifications = results[3] as List<NotificationModel>;
      progress = results[4] as StudentProgressModel?;

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }

  /// ✨ تحديث حالة الإشعار إلى "مقروء" وتعديل الواجهة فورياً وبثبات بامتياز
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      // إرسال الطلب للسيرفر فوراً
      await _repo.markNotificationRead(notificationId); //

      // تحديث الحالة محلياً لتوفير استجابة بصرية فائقة السرعة دون الحاجة لإعادة جلب كل البيانات
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // بما أن الحقول داخل الـ Model مضبوطة كـ final، نتبع نمط النسخ الهيكلي (Immutability Pattern)
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          student: notifications[index].student,
          title: notifications[index].title,
          message: notifications[index].message,
          category: notifications[index].category,
          sourceObjectId: notifications[index].sourceObjectId,
          semester: notifications[index].semester,
          createdAt: notifications[index].createdAt,
          isRead: true, // تفعيل شارة المقروء بسلام
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ فشل تحديث حالة قراءة الإشعار محلياً: $e");
    }
  }
}