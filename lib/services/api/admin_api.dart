import 'package:dio/dio.dart';
import 'package:quran_center_app/services/dio_client.dart';

class AdminApi {
  final DioClient _client = DioClient();

  // =========================================================================
  // 1. إدارة الأشخاص (طلاب/معلمين) - الحفاظ التام على الأسماء القديمة
  // =========================================================================
  
  Future<List<dynamic>> getPersons(String role) async {
    try {
      final response = await _client.get("persons/?role=$role");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب قائمة الحسابات بالصلاحية المطلوبة");
    }
  }

  Future<void> createPerson(Map<String, dynamic> data) async {
    try {
      await _client.post("persons/", data: data);
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
      throw _handleError(e, "فشل حذف الحساب؛ قد يكون مرتبكاً ببيانات نشطة أخرى");
    }
  }

  // =========================================================================
  // 2. إدارة الحلقات - الحفاظ التام على الأسماء القديمة
  // =========================================================================

  Future<List<dynamic>> getHalqas() async {
    try {
      final response = await _client.get("halqas/");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب قائمة الحلقات القرآنية");
    }
  }

  Future<void> createHalqa(Map<String, dynamic> data) async {
    try {
      await _client.post("halqas/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل إنشاء حلقة جديدة؛ تأكد من عدم تكرار الاسم");
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
      throw _handleError(e, "لا يمكن حذف الحلقة لوجود طلاب مرتبطين بها حالياً");
    }
  }

  // =========================================================================
  // 3. الإعدادات الأكاديمية (السنوات والفصول) - التوسيع لـ CRUD كامل
  // =========================================================================

  // --- السنوات الأكاديمية ---
  Future<List<dynamic>> getAcademicYears() async {
    try {
      final response = await _client.get("academic-years/");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب السنوات الأكاديمية");
    }
  }

  // إضافة: إنشاء سنة أكاديمية
  Future<void> createAcademicYear(Map<String, dynamic> data) async {
    try {
      await _client.post("academic-years/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل تسجيل سنة أكاديمية جديدة");
    }
  }

  // إضافة: تعديل سنة أكاديمية
  Future<void> updateAcademicYear(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("academic-years/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل تحديث بيانات السنة الأكاديمية");
    }
  }

  // إضافة: حذف سنة أكاديمية
  Future<void> deleteAcademicYear(int id) async {
    try {
      await _client.delete("academic-years/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "محمي: لا يمكن حذف سنة أكاديمية مرتبطة ببيانات طلاب وفصول");
    }
  }

  // --- الفصول الدراسية ---
  Future<List<dynamic>> getSemesters() async {
    try {
      final response = await _client.get("semesters/");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, "فشل جلب الفصول الدراسية");
    }
  }

  // إضافة: إنشاء فصل دراسي
  Future<void> createSemester(Map<String, dynamic> data) async {
    try {
      await _client.post("semesters/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل إنشاء الفصل الدراسي");
    }
  }

  // إضافة: تعديل فصل دراسي
  Future<void> updateSemester(int id, Map<String, dynamic> data) async {
    try {
      await _client.patch("semesters/$id/", data: data);
    } on DioException catch (e) {
      throw _handleError(e, "فشل تحديث الفصل الدراسي");
    }
  }

  // إضافة: حذف فصل دراسي
  Future<void> deleteSemester(int id) async {
    try {
      await _client.delete("semesters/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل حذف الفصل الدراسي؛ قد يحتوي على جلسات تسميع نشطة");
    }
  }

  // =========================================================================
  // 4. إدارة وإرسال الإشعارات - التوسيع لـ CRUD كامل
  // =========================================================================

  // إضافة: جلب سجل الإشعارات المرسلة سابقاً لرؤيتها في لوحة الآدمن
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
      throw _handleError(e, "فشل إرسال الإشعار أو حفظه بالسيرفر");
    }
  }

  // إضافة: حذف إشعار قديم من السجل
  Future<void> deleteNotification(int id) async {
    try {
      await _client.delete("notifications/$id/");
    } on DioException catch (e) {
      throw _handleError(e, "فشل حذف الإشعار من السجل");
    }
  }

  // =========================================================================
  // دالة موحدة لمعالجة أخطاء الشبكة والـ API (Edge Cases Exception Handling)
  // =========================================================================
  Exception _handleError(DioException error, String clientMessage) {
    String detailedMessage = clientMessage;
    if (error.response != null && error.response?.data is Map) {
      // استخراج تفاصيل الخطأ القادمة من الجانغو مباشرة إن وجدت (مثل أخطاء التحقق من الحقول)
      final backendDetail = error.response?.data['detail'] ?? error.response?.data.toString();
      detailedMessage += " ($backendDetail)";
    } else {
      detailedMessage += " : ${error.message}";
    }
    return Exception(detailedMessage);
  }
}