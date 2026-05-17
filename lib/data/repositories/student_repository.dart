
import 'package:quran_center_app/services/api/student_api.dart';
import 'package:quran_center_app/services/dio_client.dart';
import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/memorization_session_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/student_progress_model.dart';

class StudentRepository {
  final StudentApi _api = StudentApi();

  Future<PersonModel> getProfile() async {
    final data = await _api.getProfile();
    return PersonModel.fromJson(data);
  }

  Future<List<AttendanceModel>> getAttendance(String studentName) async {
    final data = await _api.getAttendance(studentName);
    return data.map((e) => AttendanceModel.fromJson(e)).toList();
  }

  Future<List<MemorizationSessionModel>> getMemorizationSessions(String studentName) async {
    final data = await _api.getMemorizationSessions(studentName);
    return data.map((e) => MemorizationSessionModel.fromJson(e)).toList();
  }

  Future<List<QuranTestModel>> getTests(int studentId) async {
    final data = await _api.getTests(studentId);
    return data.map((e) => QuranTestModel.fromJson(e)).toList();
  }

  Future<List<NotificationModel>> getNotifications() async {
    final data = await _api.getNotifications();
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markNotificationRead(int notificationId) async {
    await _api.markNotificationRead(notificationId);
  }

  Future<StudentProgressModel> getProgress() async {
    final data = await _api.getProgress();
    return StudentProgressModel.fromJson(data);
  }
}