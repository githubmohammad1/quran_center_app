import 'package:flutter/material.dart';
import '../../data/models/person_model.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/academic_year_model.dart';
import '../../data/models/semester_model.dart';
import '../../data/models/notification_model.dart'; // إضافة موديل الإشعارات إن وجد بالسجل
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/teacher_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepo = AdminRepository();
  final TeacherRepository _teacherRepo = TeacherRepository();

  List<PersonModel> students = [];
  List<PersonModel> teachers = [];
  List<HalqaModel> halqas = [];
  List<AcademicYearModel> years = [];
  List<SemesterModel> semesters = [];
  List<NotificationModel> notifications = []; // سجل الإشعارات
  List<PersonModel> currentHalqaStudents = [];

  bool loading = false;
  String? error;

  // دالة مساعدة لتوحيد منطق معالجة الأخطاء وتنظيف النص
  void _setError(dynamic e) {
    error = e.toString().replaceAll("Exception: ", "");
    loading = false;
    notifyListeners();
  }

  // جلب كافة البيانات الأساسية للوحة تحكم الآدمن
  Future<void> loadAll() async {
    try {
      loading = true; error = null; notifyListeners();

      // تم دمج جلب الإشعارات أيضاً في الـ Future.wait لسرعة الأداء
      final results = await Future.wait([
        _adminRepo.getStudents(),
        _adminRepo.getTeachers(),
        _adminRepo.getHalqas(),
        _adminRepo.getAcademicYears(),
        _adminRepo.getSemesters(),
        _adminRepo.getNotifications().catchError((_) => <NotificationModel>[]), // حماية في حال عدم وجود سجل
      ]);

      students = results[0] as List<PersonModel>;
      teachers = results[1] as List<PersonModel>;
      halqas = results[2] as List<HalqaModel>;
      years = results[3] as List<AcademicYearModel>;
      semesters = results[4] as List<SemesterModel>;
      notifications = results[5] as List<NotificationModel>;

      loading = false; notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  // =========================================================================
  // 1. إدارة الأشخاص (الطلاب / المعلمين) - CRUD كامل
  // =========================================================================
  
  Future<bool> createPerson(Map<String, dynamic> data) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.createPerson(data);
      await loadAll(); // تحديث القوائم تلقائياً بعد الإضافة
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  Future<bool> updatePerson(int id, Map<String, dynamic> data) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.updatePerson(id, data);
      await loadAll(); // تحديث القوائم تلقائياً بعد التعديل
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  Future<bool> deletePerson(int id) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.deletePerson(id);
      await loadAll(); // تحديث القوائم تلقائياً بعد الحذف
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  // =========================================================================
  // 2. إدارة الحلقات - CRUD كامل
  // =========================================================================
  
  Future<bool> createHalqa(Map<String, dynamic> data) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.createHalqa(data);
      await loadAll();
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  Future<bool> updateHalqa(int id, Map<String, dynamic> data) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.updateHalqa(id, data);
      await loadAll();
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  Future<bool> deleteHalqa(int id) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.deleteHalqa(id);
      await loadAll();
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  // =========================================================================
  // 3. الإعدادات الأكاديمية (السنوات والفصول الدراسية) - CRUD كامل
  // =========================================================================

  // --- السنوات الأكاديمية ---
  Future<bool> createAcademicYear(Map<String, dynamic> data) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.createAcademicYear(data);
      await loadAll();
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  Future<bool> updateAcademicYear(int id, Map<String, dynamic> data) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.updateAcademicYear(id, data);
      await loadAll();
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  Future<bool> deleteAcademicYear(int id) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.deleteAcademicYear(id);
      await loadAll();
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  // --- الفصول الدراسية ---
  Future<bool> createSemester(Map<String, dynamic> data) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.createSemester(data);
      await loadAll();
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  Future<bool> updateSemester(int id, Map<String, dynamic> data) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.updateSemester(id, data);
      await loadAll();
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  Future<bool> deleteSemester(int id) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.deleteSemester(id);
      await loadAll();
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  // =========================================================================
  // 4. إدارة نظام الإشعارات والتنبيهات العامة
  // =========================================================================

  Future<bool> sendNotification(Map<String, dynamic> data) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.sendNotification(data);
      await loadAll(); // لتحديث قائمة الإشعارات المرسلة في لوحة التحكم
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  Future<bool> deleteNotification(int id) async {
    try {
      loading = true; error = null; notifyListeners();
      await _adminRepo.deleteNotification(id);
      await loadAll();
      return true;
    } catch (e) {
      _setError(e); return false;
    }
  }

  // =========================================================================
  // 5. عمليات المعلم المتاحة للأدمن (الحفاظ التام عليها)
  // =========================================================================
  
  Future<void> loadHalqaStudents(int halqaId) async {
    try {
      loading = true; error = null; notifyListeners();
      currentHalqaStudents = await _teacherRepo.getHalqaStudents(halqaId);
      loading = false; notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  Future<bool> addAttendance(Map<String, dynamic> data) async {
    try { 
      error = null;
      await _teacherRepo.saveAttendance(data); 
      return true; 
    } catch (e) { 
      error = e.toString().replaceAll("Exception: ", ""); 
      notifyListeners(); 
      return false; 
    }
  }

  Future<bool> addMemorization(Map<String, dynamic> data) async {
    try { 
      error = null;
      await _teacherRepo.addMemorization(data); 
      return true; 
    } catch (e) { 
      error = e.toString().replaceAll("Exception: ", ""); 
      notifyListeners(); 
      return false; 
    }
  }

  Future<bool> addTest(Map<String, dynamic> data) async {
    try { 
      error = null;
      await _teacherRepo.addTest(data); 
      return true; 
    } catch (e) { 
      error = e.toString().replaceAll("Exception: ", ""); 
      notifyListeners(); 
      return false; 
    }
  }
}