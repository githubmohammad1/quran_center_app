
import 'package:quran_center_app/services/dio_client.dart';
import '../../data/models/person_model.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/academic_year_model.dart';
import '../../data/models/semester_model.dart';

class AdminRepository {
  final AdminApi _api = AdminApi();

  // ----- إدارة الأشخاص -----
  Future<List<PersonModel>> getStudents() async {
    final data = await _api.getPersons("student");
    return data.map((e) => PersonModel.fromJson(e)).toList();
  }

  Future<List<PersonModel>> getTeachers() async {
    final data = await _api.getPersons("teacher");
    return data.map((e) => PersonModel.fromJson(e)).toList();
  }

  Future<void> createPerson(Map<String, dynamic> data) async => await _api.createPerson(data);
  Future<void> updatePerson(int id, Map<String, dynamic> data) async => await _api.updatePerson(id, data);
  Future<void> deletePerson(int id) async => await _api.deletePerson(id);

  // ----- إدارة الحلقات -----
  Future<List<HalqaModel>> getHalqas() async {
    final data = await _api.getHalqas();
    return data.map((e) => HalqaModel.fromJson(e)).toList();
  }

  Future<void> createHalqa(Map<String, dynamic> data) async => await _api.createHalqa(data);
  Future<void> updateHalqa(int id, Map<String, dynamic> data) async => await _api.updateHalqa(id, data);
  Future<void> deleteHalqa(int id) async => await _api.deleteHalqa(id);

  // ----- الإعدادات الأكاديمية -----
  Future<List<AcademicYearModel>> getAcademicYears() async {
    final data = await _api.getAcademicYears();
    return data.map((e) => AcademicYearModel.fromJson(e)).toList();
  }

  Future<List<SemesterModel>> getSemesters() async {
    final data = await _api.getSemesters();
    return data.map((e) => SemesterModel.fromJson(e)).toList();
  }

  // ----- الإشعارات -----
  Future<void> sendNotification(Map<String, dynamic> data) async {
    await _api.sendNotification(data);
  }
}