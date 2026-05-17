
import 'package:quran_center_app/services/dio_client.dart';
import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/student_progress_model.dart';

class GuardianRepository {
  final GuardianApi _api = GuardianApi();

  Future<List<PersonModel>> getChildren() async {
    final data = await _api.getChildren();
    return data.map((e) => PersonModel.fromJson(e)).toList();
  }

  Future<PersonModel> getChildProfile(int childId) async {
    final data = await _api.getChildProfile(childId);
    return PersonModel.fromJson(data);
  }

  Future<List<QuranTestModel>> getChildTests(int childId) async {
    final data = await _api.getChildTests(childId);
    return data.map((e) => QuranTestModel.fromJson(e)).toList();
  }

  Future<StudentProgressModel?> getChildProgress(String childName) async {
    final data = await _api.getChildProgress(childName);
    if (data != null) {
      return StudentProgressModel.fromJson(data);
    }
    return null;
  }

  Future<List<AttendanceModel>> getChildAttendance(String childName) async {
    final data = await _api.getChildAttendance(childName);
    return data.map((e) => AttendanceModel.fromJson(e)).toList();
  }
}