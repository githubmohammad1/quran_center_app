// services/api/student_api.dart

import 'package:dio/dio.dart';
import 'package:quran_center_app/services/dio_client.dart';

class StudentApi {
  final DioClient _client = DioClient();

  // =========================================================================
  // 1) إدارة الملف الشخصي (Profile)
  // =========================================================================
  
  /// 👤 جلب ملف الطالب الشخصي
  /// يتوافق مع `@action(detail=False, methods=["get"]) def my_profile` في الـ PersonViewSet
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _client.get("persons/my_profile/"); // [cite: 133]
      return response.data;
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل جلب ملفك الشخصي؛ يرجى التحقق من الجلسة");
    }
  }

  // =========================================================================
  // 2) سجلات الحضور والغياب والتسميع اليومي (تصفية ذاتية آمنة)
  // =========================================================================

  /// 📝 جلب سجل الحضور والغياب المخصص للطالب المسجل دخوله حالياً
  /// تم حذف حقل الـ `studentName` لأن السيرفر يعتمد على التوكن لتحديد الهوية ومنع التكرار 
  /// يستخدم القراءة عبر `OptimizedAttendanceSerializer` لضمان Nested Objects مستقرة [cite: 95]
  Future<List<dynamic>> getAttendance() async {
    try {
      final response = await _client.get("attendance/");
      return response.data;
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل جلب سجلات الحضور والغياب الخاصة بك");
    }
  }

  /// 📖 جلب جلسات التسميع والحفظ والتقييم اليومي الخاصة بالطالب تلقائياً
  /// السيرفر يقوم بفلترة السجلات ذاتياً لحساب الطالب النشط لحماية خصوصية البيانات
  Future<List<dynamic>> getMemorizationSessions() async {
    try {
      final response = await _client.get("memorization/");
      return response.data;
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل جلب سجلات تسميع الأجزاء والسور اليومية");
    }
  }

  // =========================================================================
  // 3) وحدة الاختبارات القرآنية (Quran Tests)
  // =========================================================================

  /// 📊 جلب درجات الاختبارات الرسمية (أجزاء وسور) عبر معرف الطالب
  /// مستقر ومتوافق مع أكشن `@action(detail=False, url_path="by_student")` في الباك إند
  Future<List<dynamic>> getTests(int studentId) async {
    try {
      final response = await _client.get("quran-tests/by_student/?student=$studentId");
      return response.data;
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل جلب درجات الاختبارات؛ تأكد من صلاحيات الحساب");
    }
  }

  // =========================================================================
  // 4) لوحة المتابعة الإحصائية العامة ونسب الإنجاز (Dashboard/Progress)
  // =========================================================================

  /// 📈 جلب لوحة التطور الإحصائي التراكمي ونسب الإنجاز
  /// يعتمد على `StudentProgressSerializer` للربط الذري النظيف [cite: 108]
  Future<Map<String, dynamic>> getProgress() async {
    try {
      final response = await _client.get("progress/my-progress/");
      return response.data;
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل جلب لوحة التطور والإحصائيات التراكمية");
    }
  }

  // =========================================================================
  // 5) وحدة الإشعارات (Notifications Module)
  // =========================================================================

  /// 🔔 جلب قائمة الإشعارات والتحذيرات المرسلة للطالب بناءً على هويته ودوره
  /// يتوافق مع نظام التصفية المدمج لمنع تكرار السجلات `distinct()` في السيرفر
  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _client.get("notifications/");
      return response.data ?? [];
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل جلب إشعارات الطالب الشخصية");
    }
  }

  /// ✔️ تحديث إشعار معين وتغيير حالته إلى "تم القراءة" في السيرفر
  /// يتوافق مع الـ Custom Action المكتوب بالسيرفر: `@action(detail=True, methods=["post"], url_path="mark_read")`
  Future<void> markNotificationRead(int notificationId) async {
    try {
      await _client.post("notifications/$notificationId/mark_read/");
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل تحديث حالة قراءة الإشعار في السيرفر");
    }
  }

  // =========================================================================
  // 🛡️ معالج الأخطاء المركزي والدفاعي (Centralized Error Handler)
  // =========================================================================
  Exception _handleCentralError(DioException error, String clientMessage) {
    String detailedMessage = clientMessage;
    
    if (error.response != null && error.response?.data is Map) {
      final backendData = error.response?.data as Map;
      
      // اقتناص رسالة الخطأ المخصصة الراجعة من الـ Validation أو الـ Detail في دجانغو 
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
      detailedMessage = "انتهى وقت الاتصال بالخادم، يرجى التحقق من شبكة الإنترنت.";
    } else if (error.type == DioExceptionType.connectionError) {
      detailedMessage = "لا يوجد اتصال بالخادم المخصص للمركز.";
    } else {
      detailedMessage += "\n(كود الخطأ: ${error.response?.statusCode ?? 'غير معروف'})";
    }
    return Exception(detailedMessage);
  }
}