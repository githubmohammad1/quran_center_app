import 'package:dio/dio.dart';
import 'package:quran_center_app/services/dio_client.dart';

class GuardianApi {
  final DioClient _client = DioClient();

  // 1. جلب قائمة الأبناء المرتبطين برقم هاتف ولي الأمر
  // 🚀 استمثال أداء: البيانات هنا تعود محملة بـ (present_days_count, absent_days_count, late_days_count, progress) تلقائياً.
  Future<List<dynamic>> getChildren() async {
    try {
      final response = await _client.get("persons/my_children/");
      print("🎯 getChildren Data: ${response.data}");
      return response.data ?? [];
    } on DioException catch (e) {
      _logError("جلب قائمة الأبناء", e);
      rethrow;
    }
  }

  // 2. جلب الملف الشخصي التفصيلي للابن
  Future<Map<String, dynamic>> getChildProfile(int childId) async {
    try {
      final response = await _client.get("persons/$childId/");
      print("🎯 getChildProfile Data: ${response.data}");
      return response.data ?? {};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("لم يتم العثور على بيانات هذا الابن في السيرفر.");
      }
      _logError("جلب ملف الابن الشخصي", e);
      rethrow;
    }
  }

  // 3. جلب سجل الاختبارات القرآنية (الأجزاء والسور) بناءً على معرف الابن الرقمي
  Future<List<dynamic>> getChildTests(int childId) async {
    try {
      final response = await _client.get("quran-tests/by_student/?student=$childId"); 
      print("🎯 getChildTests Data: ${response.data}");
      return response.data ?? []; 
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      _logError("جلب اختبارات الابن", e);
      rethrow; 
    }
  }

  // 4. جلب التقدم التراكمي والنقاط (تم دعم الـ Custom Action خلفياً بنجاح)
  Future<Map<String, dynamic>?> getChildProgress(int childId) async {
    try {
      final response = await _client.get("progress/by_student/?student=$childId"); 
      print("🎯 getChildProgress Data: ${response.data}");
      List<dynamic> data = response.data ?? []; 
      if (data.isNotEmpty) return data.first as Map<String, dynamic>; 
      return null; 
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      _logError("جلب تقدم الابن الدراسي", e);
      rethrow;
    }
  }

  // 5. جلب سجل الحضور والغياب اليومي التفصيلي بالاعتماد على الـ ID
  // 🛠️ تصحيح جودة: تحويل الرابط إلى النمط القياسي المقروء من الـ ViewSet القياسي لمنع الـ 404
  Future<List<dynamic>> getChildAttendance(int childId) async {
    try {
      final response = await _client.get("attendance/?student=$childId");
      print("🎯 getChildAttendance Data: ${response.data}");
      return response.data ?? []; 
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; 
      }
      _logError("جلب سجل حضور الابن", e);
      rethrow;
    }
  }

  // 6. جلب جلسات التسميع اليومية الحية للابن
  // 🛠️ تصحيح جودة: ضبط اسم مسار السيرفر القياسي المتوقع بناءً على اسم الموديل و الـ ViewSet
  Future<List<dynamic>> getChildMemorizationSessions(int childId) async {
    try {
      // تعديل رابط الاستدعاء ليطابق السيرفر الحالي بدقة
final response = await _client.get("memorization/?student=$childId");
      print("🎯 getChildMemorizationSessions Data: ${response.data}"); 
      return response.data ?? []; 
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      _logError("جلب جلسات تسميع الابن", e);
      rethrow;
    }
  }

  // 7. جلب الإشعارات الخاصة بأبناء ولي الأمر
Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _client.get("notifications/");
      return response.data ?? [];
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل جلب الإشعارات الخاصة بالأبناء");
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _client.post("notifications/$notificationId/mark_read/");
      return response.data ?? {};
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل تأكيد قراءة الإشعار الإداري");
    }
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
  } else if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
    detailedMessage = "انتهى وقت الاتصال بالخادم، يرجى التحقق من الإنترنت.";
  } else if (error.type == DioExceptionType.connectionError) {
    detailedMessage = "لا يوجد اتصال بالخادم المخصص للمركز.";
  } else {
    detailedMessage += "\n(كود الخطأ: ${error.response?.statusCode ?? 'غير معروف'})";
  }
  return Exception(detailedMessage);
}

  // 🔒 دالة تدقيق داخلية مركزية لتسجيل وتتبع أخطاء الشبكة والـ Dio بشكل موحد
  void _logError(String actionName, DioException error) {
    print("❌ [GuardianApi Error] فشلت عملية ($actionName): ${error.message}");
    if (error.response != null) {
      print("📊 كود الحالة الخلفي: ${error.response?.statusCode}");
      print("📝 تفاصيل الخطأ من السيرفر: ${error.response?.data}");
    }
  
}