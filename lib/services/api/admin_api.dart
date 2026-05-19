import 'package:dio/dio.dart';
// تأكد من مسار الاستيراد الصحيح لملف DioClient في مشروعك
import 'package:quran_center_app/services/dio_client.dart';

class AdminApi {
  final DioClient _client = DioClient();

  // =========================================================================
  // 1. إدارة الأشخاص (Users & Persons) 
  // =========================================================================
  
  /// جلب الأشخاص مع دعم الفلترة (مثال: role=student أو search=أحمد)
  Future<List<dynamic>> getPersons({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _client.dio.get("persons/", queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب قائمة الحسابات");
    }
  }

  Future<Map<String, dynamic>> createPerson(Map<String, dynamic> data) async {
    try {
      final response = await _client.post("persons/", data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل إنشاء حساب جديد؛ تحقق من صحة البيانات المرسلة");
    }
  }

  Future<void> updatePerson(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("persons/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "حدث خطأ أثناء تحديث بيانات الحساب رقم $id");
    }
  }

  Future<void> deletePerson(int id) async {
    try {
      await _client.delete("persons/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل حذف الحساب؛ قد يكون مرتبطاً ببيانات نشطة أخرى");
    }
  }

  // =========================================================================
  // 2. إدارة الحلقات (Halqas)
  // =========================================================================

  Future<List<dynamic>> getHalqas({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _client.dio.get("halqas/", queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب قائمة الحلقات القرآنية");
    }
  }

  Future<void> createHalqa(Map<String, dynamic> data) async {
    try {
      await _client.post("halqas/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل إنشاء حلقة جديدة؛ تأكد من صحة بيانات الأستاذ والطلاب");
    }
  }

  Future<void> updateHalqa(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("halqas/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل تعديل بيانات الحلقة");
    }
  }

  Future<void> deleteHalqa(int id) async {
    try {
      await _client.delete("halqas/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "لا يمكن حذف الحلقة لوجود سجلات حضور أو طلاب مرتبطين بها");
    }
  }

  // =========================================================================
  // 3. الإعدادات الأكاديمية (Academic Years & Semesters)
  // =========================================================================

  Future<List<dynamic>> getAcademicYears() async {
    try {
      final response = await _client.get("academic-years/");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب السنوات الأكاديمية");
    }
  }

  Future<void> createAcademicYear(Map<String, dynamic> data) async {
    try {
      await _client.post("academic-years/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل تسجيل سنة أكاديمية جديدة");
    }
  }

  Future<void> updateAcademicYear(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("academic-years/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل تحديث بيانات السنة الأكاديمية");
    }
  }

  Future<void> deleteAcademicYear(int id) async {
    try {
      await _client.delete("academic-years/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "محمي: لا يمكن حذف سنة أكاديمية مرتبطة بفصول دراسية");
    }
  }

  Future<List<dynamic>> getSemesters({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _client.dio.get("semesters/", queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب الفصول الدراسية");
    }
  }

  Future<void> createSemester(Map<String, dynamic> data) async {
    try {
      await _client.post("semesters/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل إنشاء الفصل الدراسي");
    }
  }

  Future<void> updateSemester(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("semesters/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل تحديث الفصل الدراسي");
    }
  }

  Future<void> deleteSemester(int id) async {
    try {
      await _client.delete("semesters/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل حذف الفصل الدراسي لوجود بيانات مرتبطة به");
    }
  }

  // =========================================================================
  // 4. الحضور والغياب (Attendance)
  // =========================================================================

  Future<List<dynamic>> getAttendance({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _client.dio.get("attendance/", queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب سجلات الحضور والغياب");
    }
  }

  Future<void> recordAttendance(Map<String, dynamic> data) async {
    try {
      // ميزة الباك إند: الدالة post في AttendanceViewSet تقوم بالإنشاء أو التحديث تلقائياً
      await _client.post("attendance/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل تسجيل الحضور");
    }
  }

  Future<void> deleteAttendance(int id) async {
    try {
      await _client.delete("attendance/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل حذف سجل الحضور");
    }
  }

  // =========================================================================
  // 5. جلسات الحفظ والتسميع (Memorization Sessions)
  // =========================================================================

  Future<List<dynamic>> getMemorizationSessions({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _client.dio.get("memorization/", queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب جلسات التسميع");
    }
  }

  Future<void> createMemorizationSession(Map<String, dynamic> data) async {
    try {
      await _client.post("memorization/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل إضافة جلسة التسميع؛ تأكد من الصفحات والفصل الدراسي");
    }
  }

  Future<void> updateMemorizationSession(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("memorization/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل تعديل بيانات جلسة التسميع");
    }
  }

  Future<void> deleteMemorizationSession(int id) async {
    try {
      await _client.delete("memorization/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل حذف جلسة التسميع");
    }
  }

  // =========================================================================
  // 6. الاختبارات القرآنية (Quran Tests)
  // =========================================================================

  Future<List<dynamic>> getQuranTests({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _client.dio.get("quran-tests/", queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب الاختبارات القرآنية");
    }
  }

  Future<void> createQuranTest(Map<String, dynamic> data) async {
    try {
      await _client.post("quran-tests/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل إضافة الاختبار؛ تأكد من التناغم بين نوع الاختبار (SURAH/PART) والبيانات");
    }
  }

  Future<void> updateQuranTest(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("quran-tests/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل تعديل بيانات الاختبار");
    }
  }

  Future<void> deleteQuranTest(int id) async {
    try {
      await _client.delete("quran-tests/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل حذف الاختبار");
    }
  }

  // =========================================================================
  // 7. تقدم الطلاب (Student Progress) - القراءة فقط بناءً على الباك إند
  // =========================================================================

  Future<List<dynamic>> getAllProgress({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _client.dio.get("progress/", queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب إحصائيات تقدم الطلاب");
    }
  }

  Future<Map<String, dynamic>> getProgressByStudentId(int studentId) async {
    try {
      final response = await _client.get("progress/by-student/?student_id=$studentId");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "لم يتم العثور على سجل تقدم لهذا الطالب");
    }
  }

  // =========================================================================
  // 8. الإشعارات (Notifications)
  // =========================================================================

  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _client.get("notifications/");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب سجل الإشعارات");
    }
  }

  Future<void> sendNotification(Map<String, dynamic> data) async {
    try {
      await _client.post("notifications/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل إرسال الإشعار");
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _client.delete("notifications/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل حذف الإشعار");
    }
  }

  // =========================================================================
  // معالجة الأخطاء الذكية (Error Handling)
  // =========================================================================
  Exception _handleError(DioException error, String clientMessage) {
    String detailedMessage = clientMessage;
    if (error.response != null && error.response?.data is Map) {
      // جلب التفاصيل من الباك إند (مثل Validation Errors)
      final backendData = error.response?.data;
      if (backendData.containsKey('detail')) {
        detailedMessage += "\n(${backendData['detail']})";
      } else {
        // إذا كان خطأ تحقق من حقل معين مثلاً {"phone": ["هذا الهاتف موجود مسبقاً"]}
        detailedMessage += "\n(${backendData.values.first})";
      }
    } else if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
      detailedMessage = "انتهى وقت الاتصال بالخادم، يرجى التحقق من الإنترنت.";
    } else if (error.type == DioExceptionType.connectionError) {
      detailedMessage = "لا يوجد اتصال بالخادم.";
    } else {
      detailedMessage += "\n(كود الخطأ: ${error.response?.statusCode ?? 'غير معروف'})";
    }
    return Exception(detailedMessage);
  }
}