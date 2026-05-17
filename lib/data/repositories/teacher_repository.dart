
import 'package:quran_center_app/services/dio_client.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/person_model.dart';

class TeacherRepository {
  final TeacherApi _api = TeacherApi();

  Future<List<HalqaModel>> getMyHalqas() async {
    final data = await _api.getMyHalqas();
    return data.map((e) => HalqaModel.fromJson(e)).toList();
  }
Future<Map<String, dynamic>> getTeacherStats() async {
    return await _api.getTeacherStats();
  }
  Future<List<PersonModel>> getHalqaStudents(int halqaId) async {
    final data = await _api.getHalqaStudents(halqaId);
    return data.map((e) => PersonModel.fromJson(e)).toList();
  }

  Future<void> addAttendance(Map<String, dynamic> data) async => await _api.addAttendance(data);
  Future<void> addMemorization(Map<String, dynamic> data) async => await _api.addMemorization(data);
  Future<void> addTest(Map<String, dynamic> data) async => await _api.addTest(data);
}