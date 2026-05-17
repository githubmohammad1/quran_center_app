import 'package:flutter/material.dart';
import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/student_progress_model.dart';
import '../../data/repositories/guardian_repository.dart';

class GuardianProvider extends ChangeNotifier {
  final GuardianRepository _repo = GuardianRepository();

  List<PersonModel> children = [];
  PersonModel? selectedChild;

  List<AttendanceModel> attendance = [];
  List<QuranTestModel> tests = [];
  StudentProgressModel? progress;

  bool loading = false;
  String? error;

  Future<void> loadChildren() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      children = await _repo.getChildren();

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }

  Future<void> loadChildData(int childId, {String? childName}) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      selectedChild = await _repo.getChildProfile(childId);
      final nameToSearch = childName ?? selectedChild?.fullName ?? "";

      final results = await Future.wait([
        _repo.getChildAttendance(nameToSearch),
        _repo.getChildTests(childId),
        _repo.getChildProgress(nameToSearch),
      ]);

      attendance = results[0] as List<AttendanceModel>;
      tests = results[1] as List<QuranTestModel>;
      progress = results[2] as StudentProgressModel?;

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }
}