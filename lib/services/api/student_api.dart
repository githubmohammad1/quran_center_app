import 'package:dio/dio.dart';
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
    final response = await _client.get(
      "quran-tests/by_student/?student=$studentId",
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getProgress() async {
    final response = await _client.get("progress/my-progress/");
    return response.data;
  }

  // الإشعارات
  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _client.get("notifications/");
      return response.data ?? [];
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل جلب إشعارات الطالب الشخصية");
    }
  }

  Future<void> markNotificationRead(int notificationId) async {
    try {
      await _client.post("notifications/$notificationId/mark_read/");
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل تحديث حالة قراءة الإشعار");
    }
  }

  // =========================================================================
  Exception _handleCentralError(DioException error, String clientMessage) {
    String detailedMessage = clientMessage;
    if (error.response != null && error.response?.data is Map) {
      final backendData = error.response?.data as Map;
      if (backendData.containsKey('detail')) {
        detailedMessage += "\n(${backendData['detail']})";
      } else if (backendData.isNotEmpty) {
        final firstValue = backendData.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          detailedMessage += "\n(${firstValue.first})";
        } else {
          detailedMessage += "\n($firstValue)";
        }
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      detailedMessage = "انتهى وقت الاتصال بالخادم، يرجى التحقق من الإنترنت.";
    } else if (error.type == DioExceptionType.connectionError) {
      detailedMessage = "لا يوجد اتصال بالخادم المخصص للمركز.";
    } else {
      detailedMessage +=
          "\n(كود الخطأ: ${error.response?.statusCode ?? 'غير معروف'})";
    }
    return Exception(detailedMessage);
  }
}
