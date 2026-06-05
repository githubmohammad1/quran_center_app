// data/repositories/student_repository.dart

import 'package:quran_center_app/services/api/student_api.dart';
import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/memorization_session_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/student_progress_model.dart';

class StudentRepository {
  final StudentApi _api = StudentApi();

  // =========================================================================
  // 1) الملف الشخصي (Profile)
  // =========================================================================

  /// 👤 جلب ملف الطالب الشخصي وتحليله ككائن PersonModel
  Future<PersonModel> getProfile() async {
    final data = await _api.getProfile(); //
    return PersonModel.fromJson(data);
  }

  // =========================================================================
  // 2) سجلات الحضور والتسميع اليومي (تصفية ذاتية ومؤمنة)
  // =========================================================================

  /// 📝 جلب سجل الحضور والغياب الخاص بالطالب الموثق حالياً
  /// 🚀 تم الاستمثال: حذف بارامتر (studentName) بالتوافق مع معايير الأمان المحدثة في السيرفر
  Future<List<AttendanceModel>> getAttendance() async {
    final List<dynamic> data = await _api.getAttendance(); //
    return data.map((e) => AttendanceModel.fromJson(e)).toList();
  }

  /// 📖 جلب جلسات التسميع والحفظ والتقييم اليومي الخاصة بالطالب تلقائياً
  /// 🚀 تم الاستمثال: السيرفر يفلتر ذاتياً عبر التوكن؛ لذا تم عزل البارامتر النصي نهائياً لمنع التداخل
  Future<List<MemorizationSessionModel>> getMemorizationSessions() async {
    final List<dynamic> data = await _api.getMemorizationSessions(); //
    return data.map((e) => MemorizationSessionModel.fromJson(e)).toList();
  }

  // =========================================================================
  // 3) وحدة الاختبارات القرآنية (Quran Tests)
  // =========================================================================

  /// 📊 جلب درجات وفهارس الاختبارات الرسمية (أجزاء وسور) عبر معرف الطالب
  /// مستقر ومطابق حرفياً لعقود أكشن الباك إند المخصص
  Future<List<QuranTestModel>> getTests(int studentId) async {
    final List<dynamic> data = await _api.getTests(studentId); //
    return data.map((e) => QuranTestModel.fromJson(e)).toList();
  }

  // =========================================================================
  // 4) وحدة الإشعارات (Notifications Module)
  // =========================================================================

  /// 🔔 جلب قائمة إشعارات الطالب الشخصية الموجهة له أو لولي أمره
  Future<List<NotificationModel>> getNotifications() async {
    final List<dynamic> data = await _api.getNotifications(); //
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  /// ✔️ إرسال أمر السيرفر لتحديث حالة الإشعار إلى "مقروء"
  Future<void> markNotificationRead(int notificationId) async {
    await _api.markNotificationRead(notificationId); //
  }

  // =========================================================================
  // 5) لوحة المتابعة ونسب الإنجاز (Dashboard/Progress)
  // =========================================================================

  /// 📈 جلب لوحة المتابعة الإحصائية العامة ونسب الإنجاز التراكمية لطالب معين ذاتياً
  Future<StudentProgressModel> getProgress() async {
    final data = await _api.getProgress(); //
    return StudentProgressModel.fromJson(data);
  }
}