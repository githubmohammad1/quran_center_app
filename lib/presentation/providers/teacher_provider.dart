import 'package:flutter/material.dart';
import 'package:quran_center_app/data/models/student_progress_model.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/person_model.dart';
import '../../data/repositories/teacher_repository.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherRepository _repo = TeacherRepository();

  // --- الحالة (State) ---
  List<HalqaModel> myHalqas = [];
  List<PersonModel> currentHalqaStudents = [];
  StudentProgressModel? studentProgress;
  
  Map<String, dynamic> dashboardStats = {
    "total_pages_memorized": 0,
    "total_points": 0,
    "total_parts_tested": 0,
    "students_count": 0,
  };

  bool loading = false;
  bool loadingProgress = false;
  String? error;

  // دالة مساعدة لتنظيف نصوص الأخطاء وتوحيدها
  String _cleanError(dynamic e) {
    return e.toString().replaceAll("Exception: ", "");
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  // =========================================================================
  // 1. لوحة التحكم وتقدم الطلاب (قراءة)
  // =========================================================================

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
      error = _cleanError(e);
      print("❌ Dashboard Error: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentProgress(int studentId) async {
    try {
      loadingProgress = true;
      error = null;
      notifyListeners();

      studentProgress = await _repo.getStudentProgress(studentId);
    } catch (e) {
      error = _cleanError(e);
    } finally {
      loadingProgress = false;
      notifyListeners();
    }
  }

  Future<void> loadHalqaStudents(int halqaId) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      // تصحيح هندسي: إزالة ميتات الأكواد dead_code السابقة والاعتماد على ناتج مMapping صريح
      currentHalqaStudents = await _repo.getHalqaStudents(halqaId);
    } catch (e) {
      error = _cleanError(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // 2. منظومة الحضور والغياب (حفظ وتعديل)
  // =========================================================================

  Future<bool> saveAttendance(Map<String, dynamic> data) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repo.saveAttendance(data);
      return true;
    } catch (e) {
      final raw = e.toString();
      if (raw.contains("unique") || raw.contains("مجموعة فريدة")) {
        error = "تم تسجيل حضور هذا الطالب مسبقاً لهذا اليوم.";
      } else {
        error = _cleanError(e);
      }
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // إضافة: تعديل سجل الحضور
  Future<bool> updateAttendance(int id, Map<String, dynamic> data) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repo.updateAttendance(id, data);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // 3. منظومة التسميع اليومي - CRUD كامل
  // =========================================================================

  Future<bool> addMemorization(Map<String, dynamic> data) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repo.addMemorization(data);
      await loadDashboardData(); // تحديث فوري للإحصائيات التراكمية بالواجهة
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // إضافة: تعديل جلسة تسميع خاطئة
  Future<bool> updateMemorization(int id, Map<String, dynamic> data, int studentId) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repo.updateMemorization(id, data);
      await loadDashboardData(); 
      await loadStudentProgress(studentId); // تحديث فوري لصفحة الطالب الحالية
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // إضافة: حذف جلسة تسميع خاطئة تماماً
  Future<bool> deleteMemorization(int id, int studentId) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repo.deleteMemorization(id);
      await loadDashboardData();
      await loadStudentProgress(studentId);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // 4. منظومة اختبارات الأجز والسور - CRUD كامل
  // =========================================================================

  Future<bool> addQuranTest(Map<String, dynamic> data) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repo.addTest(data);
      await loadDashboardData();
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // إضافة: تعديل نتيجة اختبار قائمة
  Future<bool> updateQuranTest(int id, Map<String, dynamic> data, int studentId) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repo.updateTest(id, data);
      await loadDashboardData();
      await loadStudentProgress(studentId);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // إضافة: حذف سجل اختبار
  Future<bool> deleteQuranTest(int id, int studentId) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repo.deleteTest(id);
      await loadDashboardData();
      await loadStudentProgress(studentId);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}