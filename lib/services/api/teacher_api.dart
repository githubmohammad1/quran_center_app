import 'package:dio/dio.dart';
import 'package:quran_center_app/services/dio_client.dart';

class TeacherApi {
  final DioClient _client = DioClient();

  // =========================================================================
  // 1. إدارة واستعراض الحلقات والإحصائيات (قراءة)
  // =========================================================================

  // ✔ جلب الحلقات الخاصة بالمعلم (أو الحلقات المسندة للموجه بصفتة معلماً)
  Future<List<dynamic>> getMyHalqas() async {
    try {
      final response = await _client.get("halqas/my_halqas/");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل في جلب الحلقات الخاصة بك");
    }
  }

  // ✔ جلب إحصائيات المعلم (من PersonViewSet)
  Future<Map<String, dynamic>> getTeacherStats() async {
    try {
      final response = await _client.get("persons/teacher_stats/");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تحميل الإحصائيات التعليمية");
    }
  }

  // ✔ جلب طلاب حلقة محددة (من HalqaViewSet)
  Future<List<dynamic>> getHalqaStudents(int halqaId) async {
    try {
      final response = await _client.get("halqas/$halqaId/students/");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل في جلب قائمة طلاب الحلقة رقم $halqaId");
    }
  }

  // =========================================================================
  // 2. منظومة الحضور والغياب (CRUD عدا الحذف لضمان رصانة السجلات الإدارية)
  // =========================================================================

  // ✔ إضافة سجل حضور جديد
  Future<void> addAttendance(Map<String, dynamic> data) async {
    try {
      await _client.post("attendance/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تسجيل حضور الطلاب");
    }
  }

  // ✔ تحديث سجل حضور موجود
  Future<void> updateAttendance(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("attendance/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تعديل سجل الحضور رقم $id");
    }
  }

  // =========================================================================
  // 3. منظومة التسميع اليومي (توسيع للـ CRUD الكامل لمعالجة الخطأ البشري)
  // =========================================================================

  // ✔ إضافة جلسة تسميع جديدة
  Future<void> addMemorization(Map<String, dynamic> data) async {
    try {
      // تدقيق أولي سريع قبل إرسال البيانات للباك إند
      if (data['page_from'] != null && data['page_to'] != null) {
        if (int.parse(data['page_from'].toString()) > int.parse(data['page_to'].toString())) {
          throw Exception("خطأ منطقي: صفحة البداية أكبر من صفحة النهاية.");
        }
      }
      await _client.post("memorization/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في حفظ جلسة التسميع");
    }
  }

  // إضافة: تحديث جلسة تسميع (في حال أخطأ الشيخ في تحديد السورة أو التقويم)
  Future<void> updateMemorization(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("memorization/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تحديث جلسة التسميع رقم $id");
    }
  }

  // إضافة: حذف جلسة تسميع (تمنح الأستاذ/الموجه تحكماً كاملاً لحذف المدخلات الخاطئة تماماً)
  Future<void> deleteMemorization(int id) async {
    try {
      await _client.delete("memorization/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "لا تملك الصلاحية لحذف هذه الجلسة أو السجل محمي");
    }
  }

  // =========================================================================
  // 4. منظومة الاختبارات القرآنية والأداء (توسيع للـ CRUD الكامل)
  // =========================================================================

  // ✔ جلب سجل متابعة الطالب التراكمي ومستواه الحالي
// التحديث الذكي: جلب سجل متابعة الطالب التراكمي ومستواه الحالي عبر المسار المخصص الجديد
  Future<Map<String, dynamic>> getStudentProgress(int studentId) async {
    try {
      // استهداف الـ Custom Action المباشر الذي صممناه في الجانغو لسد الثغرة
      final response = await _client.get("progress/by-student/?student_id=$studentId");
      
      // الباك إند يعيد الآن Map مباشرة وليس قائمة List، مما يمنع خطأ الـ Index Out of Bounds تماماً
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل في جلب سجل تقدم الطالب التراكمي");
    }
  }

  // ✔ إضافة اختبار قرآني جديد (أجزاء / سور)
  Future<void> addTest(Map<String, dynamic> data) async {
    try {
      await _client.post("quran-tests/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تسجيل نتيجة الاختبار الجديد");
    }
  }

  // إضافة: تعديل نتيجة اختبار قرآني
  Future<void> updateTest(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("quran-tests/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل في تعديل بيانات الاختبار المختار");
    }
  }

  // إضافة: حذف نتيجة اختبار
  Future<void> deleteTest(int id) async {
    try {
      await _client.delete("quran-tests/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل في حذف الاختبار، السجل غير موجود أو غير مصرح لك");
    }
  }

  // =========================================================================
  // دالة مركزية لمعالجة وتفسير استجابات الخطأ من Django REST Framework
  // =========================================================================
  Exception _handleError(DioException error, String clientMessage) {
    String detailedMessage = clientMessage;
    
    if (error.response != null && error.response?.data is Map) {
      final backendDetail = error.response?.data['detail'] ?? error.response?.data.toString();
      detailedMessage += " ($backendDetail)";
    } else if (error.type == DioExceptionType.connectionTimeout) {
      detailedMessage += " : انتهت مهلة الاتصال بالسيرفر، تحقق من الشبكة.";
    } else {
      detailedMessage += " : ${error.message}";
    }
    
    return Exception(detailedMessage);
  }
}