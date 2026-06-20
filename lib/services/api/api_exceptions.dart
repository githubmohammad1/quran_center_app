// utils/api_exceptions.dart
import 'package:dio/dio.dart';

class ApiException {
  static Exception handle(DioException error, String defaultMessage) {
    String detailedMessage = defaultMessage;

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
      detailedMessage = "انتهى وقت الاتصال، يرجى التحقق من الإنترنت.";
    } else if (error.type == DioExceptionType.connectionError) {
      detailedMessage = "لا يوجد اتصال بالخادم المخصص للمركز.";
    } else {
      detailedMessage += "\n(كود الخطأ: ${error.response?.statusCode ?? 'غير معروف'})";
    }
    return Exception(detailedMessage);
  }
}