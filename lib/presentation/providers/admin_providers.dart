import 'package:flutter/material.dart';

// استيراد كافة الموديلات والمستودعات المعتمدة
import '../../data/models/person_model.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/academic_year_model.dart';
import '../../data/models/semester_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/student_progress_model.dart'; // 🚀 إضافة موديل التقدم المفقود
import '../../data/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepo = AdminRepository();

  // =========================================================================
  // 1. القوائم وحالات الحالة المركزية (State Variables)
  // =========================================================================
  List<PersonModel> students = [];
  List<PersonModel> teachers = [];
  List<PersonModel> supervisors = [];
  List<HalqaModel> halqas = [];
  List<AcademicYearModel> years = [];
  List<SemesterModel> semesters = [];
  List<NotificationModel> notifications = [];

  // 🚀 سد الفجوة الوظيفية: حالة خاصة بعرض تقدم الطالب المحدد في لوحة التحكم
  StudentProgressModel? selectedStudentProgress;

  // =========================================================================
  // 2. إدارة الحالة المعزولة ومؤشرات التحميل
  // =========================================================================
  bool isDashboardLoading = false;
  bool isPersonsLoading = false;
  bool isHalqasLoading = false;
  bool isAcademicLoading = false;
  bool isNotificationsLoading = false;
  bool isProgressLoading = false; // مؤشر تحميل سجل التقدم
  bool isMutationLoading = false; // خاص بحفظ/تعديل/حذف البيانات
  

final _apiClient = AdminRepository();
bool isLoading = false;
List<dynamic> studentTests = [];





  String? error;
/// 📥 جلب اختبارات طالب معين عبر المعرّف
  Future<void> fetchTestsByStudent(int studentId, {bool silent = false}) async {
    try {
      error = null;
      if (!silent) {
        isLoading = true;
        notifyListeners();
      }

      // استدعاء السيرفر عبر البارامتر المخصص المكتوب في الباك إند: ?student=id [cite: 30]
      final List<dynamic> rawData = await _apiClient.getQuranTests(
        queryParameters: {"student": studentId.toString()},
      );

      studentTests = rawData;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 📤 إنشاء اختبار قرآني جديد (جزء أو سورة)
  Future<bool> createQuranTest(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      // استدعاء دالة الـ post المجهزة 
      await _apiClient.createQuranTest(data);
      
      // تحديث القائمة محلياً صامتاً إذا كان معرّف الطالب متوفراً
      if (data["student"] != null) {
        await fetchTestsByStudent(data["student"], silent: true);
      }
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 تعديل بيانات اختبار سابق
  Future<bool> updateQuranTest(int id, Map<String, dynamic> data, int studentId) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _apiClient.updateQuranTest(id, data); // [cite: 26]
      await fetchTestsByStudent(studentId, silent: true);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  /// ❌ حذف اختبار من السجلات
  Future<bool> deleteQuranTest(int id, int studentId) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _apiClient.deleteQuranTest(id); // [cite: 28]
      await fetchTestsByStudent(studentId, silent: true);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  
  String _cleanError(dynamic e) {
    return e.toString().replaceAll("Exception: ", "").trim();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  // =========================================================================
  // 3. التحديث الميداني والصامت (Refreshers & Fetchers)
  // =========================================================================

  Future<void> loadDashboardData() async {
    try {
      isDashboardLoading = true;
      error = null;
      notifyListeners();

      final results = await Future.wait([
        _adminRepo.getStudents().catchError((_) => <PersonModel>[]),
        _adminRepo.getTeachers().catchError((_) => <PersonModel>[]),
        _adminRepo.getSupervisors().catchError((_) => <PersonModel>[]),
        _adminRepo.getHalqas().catchError((_) => <HalqaModel>[]),
        _adminRepo.getAcademicYears().catchError((_) => <AcademicYearModel>[]),
        _adminRepo.getSemesters().catchError((_) => <SemesterModel>[]),
        _adminRepo.getNotifications().catchError((_) => <NotificationModel>[]),
      ]);

      students = results[0] as List<PersonModel>;
      teachers = results[1] as List<PersonModel>;
      supervisors = results[2] as List<PersonModel>;
      halqas = results[3] as List<HalqaModel>;
      years = results[4] as List<AcademicYearModel>;
      semesters = results[5] as List<SemesterModel>;
      notifications = results[6] as List<NotificationModel>;
    } catch (e) {
      error = _cleanError(e);
    } finally {
      isDashboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPersons({bool silent = false}) async {
    try {
      if (!silent) { isPersonsLoading = true; notifyListeners(); }
      
      final results = await Future.wait([
        _adminRepo.getStudents(),
        _adminRepo.getTeachers(),
        _adminRepo.getSupervisors(),
      ]);

      // 🛠️ تصحيح الجودة الحرج: فرض الـ Casting الصريح لتجنب الـ Runtime TypeError
      students = results[0] as List<PersonModel>;
      teachers = results[1] as List<PersonModel>;
      supervisors = results[2] as List<PersonModel>;
    } catch (e) {
      error = _cleanError(e);
    } finally {
      if (!silent) { isPersonsLoading = false; notifyListeners(); }
    }
  }

  Future<void> refreshHalqas({bool silent = false}) async {
    try {
      if (!silent) { isHalqasLoading = true; notifyListeners(); }
      halqas = await _adminRepo.getHalqas();
    } catch (e) {
      error = _cleanError(e);
    } finally {
      if (!silent) { isHalqasLoading = false; notifyListeners(); }
    }
  }

  Future<void> refreshAcademicData({bool silent = false}) async {
    try {
      if (!silent) { isAcademicLoading = true; notifyListeners(); }
      final results = await Future.wait([
        _adminRepo.getAcademicYears(),
        _adminRepo.getSemesters(),
      ]);
      years = results[0] as List<AcademicYearModel>;
      semesters = results[1] as List<SemesterModel>;
    } catch (e) {
      error = _cleanError(e);
    } finally {
      if (!silent) { isAcademicLoading = false; notifyListeners(); }
    }
  }

  Future<void> refreshNotifications({bool silent = false}) async {
    try {
      if (!silent) { isNotificationsLoading = true; notifyListeners(); }
      notifications = await _adminRepo.getNotifications();
    } catch (e) {
      error = _cleanError(e);
    } finally {
      if (!silent) { isNotificationsLoading = false; notifyListeners(); }
    }
  }

  // 🚀 سد الفجوة الوظيفية: جلب سجل تقدم طالب محدد وإدارته في الذاكرة للـ UI
  Future<void> loadStudentProgress(int studentId) async {
    try {
      isProgressLoading = true;
      error = null;
      selectedStudentProgress = null; // تصفير البيانات السابقة منعاً لخلط البيانات في الواجهة
      notifyListeners();

      selectedStudentProgress = await _adminRepo.getProgressByStudentId(studentId);
    } catch (e) {
      error = _cleanError(e);
    } finally {
      isProgressLoading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // 4. عمليات الأشخاص (Person CRUD)
  // =========================================================================
  
  Future<bool> createPerson(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.createPerson(data);
      await refreshPersons(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  Future<bool> updatePerson(int id, Map<String, dynamic> data) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.updatePerson(id, data);
      await refreshPersons(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  Future<bool> deletePerson(int id) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.deletePerson(id);
      await refreshPersons(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  // =========================================================================
  // 5. عمليات الحلقات (Halqa CRUD)
  // =========================================================================
  
  Future<bool> createHalqa(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.createHalqa(data);
      await refreshHalqas(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  Future<bool> updateHalqa(int id, Map<String, dynamic> data) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.updateHalqa(id, data);
      await refreshHalqas(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  Future<bool> deleteHalqa(int id) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.deleteHalqa(id);
      await refreshHalqas(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  // =========================================================================
  // 6. الإعدادات الأكاديمية (Academic Year & Semester CRUD)
  // =========================================================================
  
  // -- السنوات --
  Future<bool> createAcademicYear(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.createAcademicYear(data);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  Future<bool> updateAcademicYear(int id, Map<String, dynamic> data) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.updateAcademicYear(id, data);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  Future<bool> deleteAcademicYear(int id) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.deleteAcademicYear(id);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  // -- الفصول --
  Future<bool> createSemester(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.createSemester(data);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  Future<bool> updateSemester(int id, Map<String, dynamic> data) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.updateSemester(id, data);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  Future<bool> deleteSemester(int id) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.deleteSemester(id);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  // =========================================================================
  // 7. إدارة الإشعارات (Notifications CRUD)
  // =========================================================================

  Future<bool> sendNotification(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.sendNotification(data);
      await refreshNotifications(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }

  Future<bool> deleteNotification(int id) async {
    try {
      isMutationLoading = true; error = null; notifyListeners();
      await _adminRepo.deleteNotification(id);
      await refreshNotifications(silent: true);
      return true;
    } catch (e) { error = _cleanError(e); return false;
    } finally { isMutationLoading = false; notifyListeners(); }
  }
}