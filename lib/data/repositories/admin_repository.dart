import 'package:quran_center_app/services/api/admin_api.dart';


import '../../data/models/person_model.dart';
import '../../data/models/halqa_model.dart';

class AdminRepository {
  final AdminApi _api = AdminApi();

  Future<List<PersonModel>> getStudents() async {
    return await _api.getStudents();
  }

  Future<List<PersonModel>> getTeachers() async {
    return await _api.getTeachers();
  }

  Future<List<HalqaModel>> getHalqas() async {
    return await _api.getHalqas();
  }

  Future<void> createHalqa(Map<String, dynamic> data) async {
    await _api.createHalqa(data);
  }

  Future<void> addAttendance(Map<String, dynamic> data) async {
    await _api.addAttendance(data);
  }

  Future<void> addMemorization(Map<String, dynamic> data) async {
    await _api.addMemorization(data);
  }

  Future<void> addTest(Map<String, dynamic> data) async {
    await _api.addTest(data);
  }
}
