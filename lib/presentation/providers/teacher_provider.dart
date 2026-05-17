import 'package:flutter/material.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/person_model.dart';
import '../../data/repositories/teacher_repository.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherRepository _repo = TeacherRepository();

  // --- الحالة ---
  List<HalqaModel> myHalqas = [];
  List<PersonModel> currentHalqaStudents = [];
  Map<String, dynamic> dashboardStats = {
    "total_pages_memorized": 0,
    "total_points": 0,
    "total_parts_tested": 0,
    "students_count": 0,
  };

  bool loading = false;
  String? error;

  void clearError() {
    error = null;
    notifyListeners();
  }

  // --- 1) لوحة التحكم ---
  Future<void> loadDashboardData() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final results = await Future.wait([
        _repo.getMyHalqas(),
        _repo.getTeacherStats(),
      ]);

      myHalqas = results[0] as List<HalqaModel>;

      final stats = results[1] as Map<String, dynamic>;

      dashboardStats = {
        "total_pages_memorized": stats["total_pages_memorized"] ?? 0,
        "total_points": stats["total_points"] ?? 0,
        "total_parts_tested": stats["total_parts_tested"] ?? 0,
        "students_count": stats["students_count"] ?? 0,
      };

    } catch (e) {
      error = e.toString();
      print("❌ Dashboard Error: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // --- 2) طلاب الحلقة ---
  Future<void> loadHalqaStudents(int halqaId) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      currentHalqaStudents =
          // ignore: dead_null_aware_expression, dead_code
          (await _repo.getHalqaStudents(halqaId)) ?? [];
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // --- 3) التسميع ---
  Future<bool> addMemorization(Map<String, dynamic> data) async {
    try {
      loading = true;
      notifyListeners();

      await _repo.addMemorization(data);
      await loadDashboardData();

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // --- 4) الحضور ---
  Future<bool> saveAttendance(Map<String, dynamic> data) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repo.saveOrUpdateAttendance(data);
      return true;

    } catch (e) {
      final raw = e.toString();

      if (raw.contains("unique") || raw.contains("مجموعة فريدة")) {
        error = "تم تسجيل حضور هذا الطالب مسبقاً لهذا اليوم.";
      } else {
        error = raw.replaceAll("Exception: ", "");
      }

      return false;

    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // --- 5) اختبار أجزاء ---
  Future<bool> addQuranTest(Map<String, dynamic> data) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repo.addTest(data);
      await loadDashboardData();

      return true;

    } catch (e) {
      error = e.toString();
      return false;

    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
