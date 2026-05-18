import 'package:dio/dio.dart';
import 'package:quran_center_app/services/dio_client.dart';

class TeacherApi {
  final DioClient _client = DioClient();

  // =========================================================================
  // 1. إدارة واستعراض الحلقات والإحصائيات (قراءة)
  // =========================================================================

  /// جلب الحلقات الخاصة بالمعلم المسجل دخوله حالياً
  Future<List<dynamic>> getMyHalqas() async {
    try {
      final response = await _client.get("halqas/my_halqas/");
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, "فشل في جلب الحلقات الخاصة بك");
    }
  }

  /// جلب إحصائيات المعلم المحصنة والمستندة إلى سجلات تقدم الطلاب
  Future<Map<String, dynamic>> getTeacherStats() async {
    try {
      // 🛠️ تصحيح الجودة: توجيه المسار إلى الكنترولر المحصن ضد قيم الـ None في الجانغو
      final response = await _client.get("progress/teacher_stats/");
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تحميل الإحصائيات التعليمية التراكمية");
    }
  }

  /// جلب طلاب حلقة محددة متضمنة سياق الـ QR المرجّع بالكامل
  Future<List<dynamic>> getHalqaStudents(int halqaId) async {
    try {
      final response = await _client.get("halqas/$halqaId/students/");
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, "فشل في جلب قائمة طلاب الحلقة رقم $halqaId");
    }
  }

  // =========================================================================
  // 2. منظومة الحضور والغياب (سجلات إدارية محصنة)
  // =========================================================================

  /// إضافة سجل حضور جديد أو تحديثه تلقائياً في حال التكرار (UPSERT) كما صممنا بالباك إند
  Future<Map<String, dynamic>> addAttendance(Map<String, dynamic> data) async {
    try {
      final response = await _client.post("attendance/", data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تسجيل حضور الطلاب");
    }
  }

  /// تحديث سجل حضور موجود مسبقاً يدوياً
  Future<void> updateAttendance(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("attendance/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تعديل سجل الحضور رقم $id");
    }
  }

  // =========================================================================
  // 3. منظومة التسميع اليومي (تعديل كامل لتفادي الأخطاء البشرية)
  // =========================================================================

  /// إضافة جلسة تسميع جديدة مع فحص أمان أولي يمنع الانهيار
  Future<void> addMemorization(Map<String, dynamic> data) async {
    try {
      // 🛠️ تصحيح الجودة: الفحص الآمن لمنع الـ FormatException في حال إدخال قيم خاطئة
      if (data['page_from'] != null && data['page_to'] != null) {
        final int? fromPage = int.tryParse(data['page_from'].toString());
        final int? toPage = int.tryParse(data['page_to'].toString());

        if (fromPage != null && toPage != null && fromPage > toPage) {
          throw Exception("خطأ منطقي: صفحة البداية لا يمكن أن تكون أكبر من صفحة النهاية.");
        }
      }
      await _client.post("memorization/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في حفظ جلسة التسميع");
    }
  }

  /// تحديث جلسة تسميع لمعالجة مدخلات الشيوخ الخاطئة يدوياً
  Future<void> updateMemorization(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("memorization/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تحديث جلسة التسميع رقم $id");
    }
  }

  /// حذف جلسة تسميع بالكامل
  Future<void> deleteMemorization(int id) async {
    try {
      await _client.delete("memorization/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "لا تملك الصلاحية لحذف هذه الجلسة أو السجل محمي");
    }
  }

  // =========================================================================
  // 4. منظومة الاختبارات القرآنية والأداء (CRUD كامل)
  // =========================================================================

  /// جلب سجل متابعة الطالب التراكمي الآمن (يعيد الخادم كائن Map مباشرة)
  Future<Map<String, dynamic>> getStudentProgress(int studentId) async {
    try {
      final response = await _client.get("progress/by-student/?student_id=$studentId");
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, "فشل في جلب سجل تقدم الطالب التراكمي أو غير مصرح لك برؤيته");
    }
  }

  /// إضافة اختبار قرآني جديد (أجزاء / سور)
  Future<void> addTest(Map<String, dynamic> data) async {
    try {
      await _client.post("quran-tests/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تسجيل نتيجة الاختبار الجديد");
    }
  }

  /// تعديل نتيجة اختبار قرآني قائم
  Future<void> updateTest(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("quran-tests/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تعديل بيانات الاختبار المختار");
    }
  }

  /// حذف نتيجة اختبار
  Future<void> deleteTest(int id) async {
    try {
      await _client.delete("quran-tests/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل في حذف الاختبار، السجل غير موجود أو غير مصرح لك");
    }
  }

  // =========================================================================
  // دالة مركزية مطورة لتفسير استجابات خطأ السيرفر بدقة وعرضها للمستخدم
  // =========================================================================
  Exception _handleError(DioException error, String clientMessage) {
    String detailedMessage = clientMessage;

    if (error.response != null && error.response?.data is Map) {
      final Map<String, dynamic> errorData = error.response?.data as Map<String, dynamic>;
      // التقاط الرسائل المخصصة من بيئة الجانغو سواء كانت detail أو خطأ مخصص بحقل معين
      final backendDetail = errorData['detail'] ?? errorData.values.first.toString();
      detailedMessage += " ($backendDetail)";
    } else if (error.type == DioExceptionType.connectionTimeout || 
               error.type == DioExceptionType.receiveTimeout) {
      detailedMessage += " : انتهت مهلة الاتصال بالسيرفر، تحقق من استقرار الشبكة.";
    } else if (error.type == DioExceptionType.badResponse) {
      detailedMessage += " : استجابة خاطئة من السيرفر كود [${error.response?.statusCode}].";
    } else {
      detailedMessage += " : حدث خطأ غير متوقع بالشبكة.";
    }

    return Exception(detailedMessage);
  }
}