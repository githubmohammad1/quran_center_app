import 'package:flutter/material.dart';
import '../../data/models/person_model.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/academic_year_model.dart';
import '../../data/models/semester_model.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/teacher_repository.dart'; // استدعاء ريبو المعلم

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepo = AdminRepository();
  final TeacherRepository _teacherRepo = TeacherRepository(); // استخدام ريبو المعلم للعمليات اليومية

  List<PersonModel> students = [];
  List<PersonModel> teachers = [];
  List<HalqaModel> halqas = [];
  List<AcademicYearModel> years = [];
  List<SemesterModel> semesters = [];
  List<PersonModel> currentHalqaStudents = []; // لجلب طلاب حلقة معينة للأدمن

  bool loading = false;
  String? error;

  Future<void> loadAll() async {
    try {
      loading = true; error = null; notifyListeners();

      final results = await Future.wait([
        _adminRepo.getStudents(),
        _adminRepo.getTeachers(),
        _adminRepo.getHalqas(),
        _adminRepo.getAcademicYears(),
        _adminRepo.getSemesters(),
      ]);

      students = results[0] as List<PersonModel>;
      teachers = results[1] as List<PersonModel>;
      halqas = results[2] as List<HalqaModel>;
      years = results[3] as List<AcademicYearModel>;
      semesters = results[4] as List<SemesterModel>;

      loading = false; notifyListeners();
    } catch (e) {
      loading = false; error = e.toString().replaceAll("Exception: ", ""); notifyListeners();
    }
  }

  // ---- إدارة الحلقات ----
  Future<bool> createHalqa(Map<String, dynamic> data) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.createHalqa(data);
      await loadAll();
      return true;
    } catch (e) {
      loading = false; error = e.toString().replaceAll("Exception: ", ""); notifyListeners(); return false;
    }
  }

  // ---- عمليات المعلم المتاحة للأدمن ----
  Future<void> loadHalqaStudents(int halqaId) async {
    try {
      loading = true; error = null; notifyListeners();
      currentHalqaStudents = await _teacherRepo.getHalqaStudents(halqaId);
      loading = false; notifyListeners();
    } catch (e) {
      loading = false; error = e.toString().replaceAll("Exception: ", ""); notifyListeners();
    }
  }

  Future<bool> addAttendance(Map<String, dynamic> data) async {
    try { await _teacherRepo.addAttendance(data); return true; } 
    catch (e) { error = e.toString().replaceAll("Exception: ", ""); notifyListeners(); return false; }
  }

  Future<bool> addMemorization(Map<String, dynamic> data) async {
    try { await _teacherRepo.addMemorization(data); return true; } 
    catch (e) { error = e.toString().replaceAll("Exception: ", ""); notifyListeners(); return false; }
  }

  // الاختبار متاح للأدمن فقط
  Future<bool> addTest(Map<String, dynamic> data) async {
    try { await _teacherRepo.addTest(data); return true; } 
    catch (e) { error = e.toString().replaceAll("Exception: ", ""); notifyListeners(); return false; }
  }
}