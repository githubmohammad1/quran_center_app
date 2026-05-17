import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/services/api/teacher_api.dart';

class TeacherRepository {
  final TeacherApi _api = TeacherApi();

  // --- (1) جلب البيانات الأساسية ---

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

  // --- (2) إدارة الحضور ---

  Future<void> saveOrUpdateAttendance(Map<String, dynamic> data) async {
    // ✔ تصحيح التاريخ
    if (data['date'] is DateTime) {
      data['date'] =
          (data['date'] as DateTime).toIso8601String().split('T').first;
    }

    // ✔ PATCH إذا كان هناك ID
    if (data.containsKey('id') && data['id'] != null) {
      await _api.updateAttendance(data['id'], {
        "status": data['status'],
        "student": data['student'],
        "date": data['date'],
      });
    } else {
      // ✔ POST لأول مرة
      await _api.addAttendance(data);
    }
  }

  // --- (3) إدارة التسميع ---

  Future<void> addMemorization(Map<String, dynamic> data) async {
    if (data['date'] is DateTime) {
      data['date'] =
          (data['date'] as DateTime).toIso8601String().split('T').first;
    }
    await _api.addMemorization(data);
  }

  // --- (4) إدارة الاختبارات ---

  Future<void> addTest(Map<String, dynamic> data) async {
    if (data['date'] is DateTime) {
      data['date'] =
          (data['date'] as DateTime).toIso8601String().split('T').first;
    }
    await _api.addTest(data);
  }
}
