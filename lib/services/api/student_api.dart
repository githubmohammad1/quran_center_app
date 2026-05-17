import 'package:quran_center_app/services/dio_client.dart';

class StudentApi {
  final DioClient _client = DioClient();

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get("persons/my_profile/");
    return response.data;
  }

  Future<List<dynamic>> getAttendance(String studentName) async {
    final response = await _client.get("attendance/?search=$studentName");
    return response.data;
  }

  Future<List<dynamic>> getMemorizationSessions(String studentName) async {
    final response = await _client.get("memorization/?search=$studentName");
    return response.data;
  }

  Future<List<dynamic>> getTests(int studentId) async {
    final response = await _client.get("quran-tests/by_student/?student=$studentId");
    return response.data;
  }

  Future<Map<String, dynamic>> getProgress() async {
    final response = await _client.get("progress/my_progress/");
    return response.data;
  }

  // الإشعارات
  Future<List<dynamic>> getNotifications() async {
    final response = await _client.get("notifications/");
    return response.data;
  }

  Future<void> markNotificationRead(int notificationId) async {
    await _client.post("notifications/$notificationId/mark_read/");
  }
}
