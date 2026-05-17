import 'package:quran_center_app/services/dio_client.dart';

class AdminApi {
  final DioClient _client = DioClient();

  // إدارة الأشخاص (طلاب/معلمين)
  Future<List<dynamic>> getPersons(String role) async {
    final response = await _client.get("persons/?role=$role");
    return response.data;
  }

  Future<void> createPerson(Map<String, dynamic> data) async => await _client.post("persons/", data: data);
  Future<void> updatePerson(int id, Map<String, dynamic> data) async => await _client.patch("persons/$id/", data: data);
  Future<void> deletePerson(int id) async => await _client.delete("persons/$id/");

  // إدارة الحلقات
  Future<List<dynamic>> getHalqas() async {
    final response = await _client.get("halqas/");
    return response.data;
  }

  Future<void> createHalqa(Map<String, dynamic> data) async => await _client.post("halqas/", data: data);
  Future<void> updateHalqa(int id, Map<String, dynamic> data) async => await _client.patch("halqas/$id/", data: data);
  Future<void> deleteHalqa(int id) async => await _client.delete("halqas/$id/");

  // الإعدادات الأكاديمية (السنوات والفصول)
  Future<List<dynamic>> getAcademicYears() async => (await _client.get("academic-years/")).data;
  Future<List<dynamic>> getSemesters() async => (await _client.get("semesters/")).data;

  // إرسال الإشعارات (تستهدف NotificationViewSet)
  Future<void> sendNotification(Map<String, dynamic> data) async => await _client.post("notifications/", data: data);
}