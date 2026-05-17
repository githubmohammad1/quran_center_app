import 'package:quran_center_app/services/dio_client.dart';

class GuardianApi {
  final DioClient _client = DioClient();

  Future<List<dynamic>> getChildren() async {
    final response = await _client.get("persons/my_children/");
    return response.data;
  }

  Future<Map<String, dynamic>> getChildProfile(int childId) async {
    final response = await _client.get("persons/$childId/");
    return response.data;
  }

  Future<List<dynamic>> getChildTests(int childId) async {
    final response = await _client.get("quran-tests/by_student/?student=$childId");
    return response.data;
  }

  Future<Map<String, dynamic>?> getChildProgress(String childName) async {
    final response = await _client.get("progress/?search=$childName");
    List data = response.data;
    if (data.isNotEmpty) return data.first;
    return null;
  }

  Future<List<dynamic>> getChildAttendance(String childName) async {
    final response = await _client.get("attendance/?search=$childName");
    return response.data;
  }
}