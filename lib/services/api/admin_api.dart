import 'package:dio/dio.dart';
import 'package:quran_center_app/services/dio_client.dart'; // تأكد من صحة المسار في مشروعك

class AdminApi {
  final DioClient _client = DioClient();

  // =========================================================================
  // 1. إدارة الأشخاص والحسابات (Users & Persons)
  // =========================================================================
  
  /// جلب الأشخاص مع دعم الفلترة (مثال: role=student أو search=أحمد)
Future<List<dynamic>> getPersons({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _client.dio.get("persons/", queryParameters: queryParameters);
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب قائمة الحسابات من السيرفر");
    }
  }

  /// 📥 إنشاء حساب جديد: إرجاع البيانات الناتجة لصبها مباشرة في الـ State
  Future<Map<String, dynamic>> createPerson(Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.post("persons/", data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, "فشل إنشاء حساب جديد؛ تحقق من صحة تبيان البيانات المرسلة");
    }
  }

  /// 🔄 تحديث الحساب (تطوير جودة العقد): تغيير الخرج ليعيد البيانات الجديدة والمحدثة من دجانغو
  Future<Map<String, dynamic>> updatePerson(int id, Map<String, dynamic> data) async {
    try {
      // نزع الحقول الثابتة أو الفارغة لحماية حزمة البيانات (Payload Cleanup)
      final cleanData = Map<String, dynamic>.from(data)..remove('id');
      
      final response = await _client.dio.patch("persons/$id/", data: cleanData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, "حدث خطأ غير متوقع أثناء تحديث بيانات الحساب الرقمي $id");
    }
  }

  /// ❌ حذف حساب
  Future<void> deletePerson(int id) async {
    try {
      await _client.dio.delete("persons/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل حذف الحساب؛ قد يكون الحساب مرتبطاً بحلقات قرآنية نشطة أو سجلات حضور");
    }
  }
  // =========================================================================
  // 2. إدارة الحلقات القرآنية (Halqas)
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
  // 7. تقدم الطلاب (Student Progress)
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
      // 🚀 إصلاح جودة قاتل للمشكلة: تعديل معامل الاستعلام من student_id إلى student ليتطابق مع السيرفر
      final response = await _client.dio.get("progress/by-student/", queryParameters: {"student": studentId});
      
      if (response.data is List && (response.data as List).isNotEmpty) {
        return response.data[0];
      }
      return response.data is Map ? response.data : {};
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
      throw _handleCentralError(e, "فشل جلب سجل الإشعارات العام");
    }
  }

  Future<void> sendNotification(Map<String, dynamic> data) async {
    try {
      await _client.post("notifications/", data: data);
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل إرسال الإشعار للطلاب");
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _client.delete("notifications/$id/");
    } on DioException catch (e) {
      throw _handleCentralError(e, "فشل حذف الإشعار من السيرفر");
    }
  }
}
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
  // =========================================================================
  // معالجة الأخطاء الذكية والمحسنة (Optimized Error Handling)
  // =========================================================================
  Exception _handleError(DioException error, String clientMessage) {
    String detailedMessage = clientMessage;
    
    if (error.response != null && error.response?.data is Map) {
      final backendData = error.response?.data as Map;
      
      if (backendData.containsKey('detail')) {
        detailedMessage += "\n(${backendData['detail']})";
      } else if (backendData.isNotEmpty) {
        // 🚀 استخلاص ذكي للنصوص النظيفة من مصفوفات الأخطاء الحقلية لضمان جمالية واجهة فلاتر
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
      detailedMessage = "لا يوجد اتصال بالخادم.";
    } else {
      detailedMessage += "\n(كود الخطأ: ${error.response?.statusCode ?? 'غير معروف'})";
    }
    return Exception(detailedMessage);
  }
