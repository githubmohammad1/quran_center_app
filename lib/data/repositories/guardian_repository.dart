import 'package:quran_center_app/services/api/guardian_api.dart';
import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/student_progress_model.dart';
// 🚀 تحديث الجودة: استيراد نموذج جلسات التسميع ونموذج الإشعارات الجديدين
import '../../data/models/memorization_session_model.dart'; 
import '../../data/models/notification_model.dart';

class GuardianRepository {
  final GuardianApi _api = GuardianApi();

  // 1. جلب قائمة الأبناء وتحويلها لكائنات برمجية منمطة
  Future<List<PersonModel>> getChildren() async {
    final data = await _api.getChildren(); // [cite: 2]
    return data.map((e) => PersonModel.fromJson(e)).toList(); // [cite: 2]
  }

  // 2. جلب الملف الشخصي الكامل للابن عبر معرفه الرقمي
  Future<PersonModel> getChildProfile(int childId) async {
    final data = await _api.getChildProfile(childId); // [cite: 3]
    return PersonModel.fromJson(data); // [cite: 3]
  }

  // 3. جلب سجل الاختبارات القرآنية (الأجزاء والسور) للابن
  Future<List<QuranTestModel>> getChildTests(int childId) async {
    final data = await _api.getChildTests(childId); // [cite: 4]
    return data.map((e) => QuranTestModel.fromJson(e)).toList(); // [cite: 4]
  }

  // 4. تصحيح جودة: جلب التقدم التراكمي ونظام النقاط بالاعتماد الصارم على الـ ID لمنع التضارب
// 🎯 تعديل نوع المعامل المستقبل ليكون int childId متوافقاً مع الـ API
Future<StudentProgressModel?> getChildProgress(int childId) async {
  try {
    final data = await _api.getChildProgress(childId);
    if (data != null) {
      return StudentProgressModel.fromJson(data);
    }
    return null;
  } catch (e) {
    // معالجة الخطأ وحالات الحافة (Edge Cases)
    rethrow;
  }
}
  // 5. تصحيح جودة: جلب سجل الحضور والغياب اليومي بالاعتماد على الـ ID الفريد للطالب
  Future<List<AttendanceModel>> getChildAttendance(int childId) async {
    final data = await _api.getChildAttendance(childId); 
    return data.map((e) => AttendanceModel.fromJson(e)).toList(); 
  }

  // 6. إضافة برمجية حتمية: جلب جلسات التسميع اليومية الحية للابن (مِن صفحة إلى صفحة والتقييم)
  Future<List<MemorizationSessionModel>> getChildMemorizationSessions(int childId) async {
    final data = await _api.getChildMemorizationSessions(childId);
    return data.map((e) => MemorizationSessionModel.fromJson(e)).toList();
  }

  // 7. إضافة برمجية حتمية: جلب الإشعارات التنبيهية الخاصة بأبناء ولي الأمر الحالي
  Future<List<NotificationModel>> getNotifications() async {
    final data = await _api.getNotifications();
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  // 8. إجراء جودة: تفعيل عملية التفاعل لتأكيد قراءة الإشعار وتحديث حالته بالسيرفر
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _api.markNotificationAsRead(notificationId);
      return response["is_read"] ?? true;
    } catch (e) {
      // إخفاق الشبكة هنا لا يعطل تجربة المستخدم، نكتفي بإرجاع false لمعالجتها في طبقة العرض
      return false;
    }
  }
}