import 'package:quran_center_app/services/dio_client.dart';

class TeacherApi {
  final DioClient _client = DioClient();

  // ✔ جلب الحلقات الخاصة بالمعلم
  Future<List<dynamic>> getMyHalqas() async {
    final response = await _client.get("halqas/my_halqas/");
    return response.data;
  }

  // ✔ جلب إحصائيات المعلم (من PersonViewSet)
  Future<Map<String, dynamic>> getTeacherStats() async {
    final response = await _client.get("persons/teacher_stats/");
    return response.data;
  }

  // ✔ جلب طلاب حلقة محددة (من HalqaViewSet)
  Future<List<dynamic>> getHalqaStudents(int halqaId) async {
    final response = await _client.get("halqas/$halqaId/students/");
    return response.data;
  }

  // --- دوال الحضور ---

  // ✔ إضافة سجل حضور جديد
  Future<void> addAttendance(Map<String, dynamic> data) async {
    await _client.post("attendance/", data: data);
  }

  // ✔ تحديث سجل حضور موجود
  Future<void> updateAttendance(int id, Map<String, dynamic> data) async {
    await _client.patch("attendance/$id/", data: data);
  }

  // --- دوال الحفظ والاختبارات ---

  Future<void> addMemorization(Map<String, dynamic> data) async {
    await _client.post("memorization/", data: data);
  }

  Future<void> addTest(Map<String, dynamic> data) async {
    await _client.post("quran-tests/", data: data);
  }
}
