
import '../dio_client.dart';
import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/memorization_session_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/student_progress_model.dart';

class StudentApi {
  final DioClient _client = DioClient();

  // بيانات الطالب (النقطة المخصصة)
  Future<PersonModel> getProfile() async {
    final response = await _client.get("persons/my_profile/");
    return PersonModel.fromJson(response.data);
  }

  // الحضور للطالب (نفترض أن التطبيق سيمرر اسم الطالب بعد جلبه من البروفايل)
  Future<List<AttendanceModel>> getAttendance(String studentName) async {
    final response = await _client.get("attendance/?search=$studentName");
    return (response.data as List).map((e) => AttendanceModel.fromJson(e)).toList();
  }

  // جلسات الحفظ
  Future<List<MemorizationSessionModel>> getMemorizationSessions(String studentName) async {
    final response = await _client.get("memorization/?search=$studentName");
    return (response.data as List).map((e) => MemorizationSessionModel.fromJson(e)).toList();
  }

  // الاختبارات (للطالب الحالي)
  Future<List<QuranTestModel>> getTests(int studentId) async {
    final response = await _client.get("quran-tests/by_student/?student=$studentId");
    return (response.data as List).map((e) => QuranTestModel.fromJson(e)).toList();
  }

  // الإشعارات (الجانغو تمت برمجته ليرجع إشعارات المستخدم الحالي فقط)
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client.get("notifications/");
    return (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  // التقدم (النقطة المخصصة)
  Future<StudentProgressModel> getProgress() async {
    final response = await _client.get("progress/my_progress/");
    return StudentProgressModel.fromJson(response.data);
  }
}