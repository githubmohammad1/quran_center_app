import 'package:quran_center_app/services/api/guardian_api.dart';

import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/student_progress_model.dart';

class GuardianRepository {
  final GuardianApi _api = GuardianApi();

  Future<List<PersonModel>> getChildren() async {
    return await _api.getChildren();
  }

  Future<PersonModel> getChildProfile(int childId) async {
    return await _api.getChildProfile(childId);
  }

  Future<List<QuranTestModel>> getChildTests(int childId) async {
    return await _api.getChildTests(childId);
  }

  Future<StudentProgressModel?> getChildProgress(String childName) async {
    return await _api.getChildProgress(childName);
  }

  Future<List<AttendanceModel>> getChildAttendance(String childName) async {
    return await _api.getChildAttendance(childName);
  }
}
