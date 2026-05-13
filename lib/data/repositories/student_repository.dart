import 'package:quran_center_app/services/api/student_api.dart';

import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/memorization_session_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/student_progress_model.dart';

class StudentRepository {
  final StudentApi _api = StudentApi();

  Future<PersonModel> getProfile() async {
    return await _api.getProfile();
  }

  Future<List<AttendanceModel>> getAttendance(String studentName) async {
    return await _api.getAttendance(studentName);
  }

  Future<List<MemorizationSessionModel>> getMemorizationSessions(String studentName) async {
    return await _api.getMemorizationSessions(studentName);
  }

  Future<List<QuranTestModel>> getTests(int studentId) async {
    return await _api.getTests(studentId);
  }

  Future<List<NotificationModel>> getNotifications() async {
    return await _api.getNotifications();
  }

  Future<StudentProgressModel> getProgress() async {
    return await _api.getProgress();
  }
}
