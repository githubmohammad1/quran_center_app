import 'package:flutter/material.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/data/models/student_progress_model.dart';
import 'package:quran_center_app/data/repositories/teacher_repository.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherRepository _repo = TeacherRepository();

  // =========================================================================
  // 1. إدارة الحالة المعزولة (Context-Driven State Variables)
  // =========================================================================
  List<HalqaModel> myHalqas = [];
  List<PersonModel> currentHalqaStudents = [];
  StudentProgressModel? studentProgress;
  
  Map<String, dynamic> dashboardStats = {
    "total_pages_memorized": 0,
    "total_points": 0,
    "total_parts_tested": 0,
    "students_count": 0,
  };

  // 🛠️ حل ثغرة حالة السباق (Race Condition): فصل مؤشرات التحميل بحسب سياق الشاشات
  bool isDashboardLoading = false;
  bool isStudentsLoading = false;
  bool isProgressLoading = false;
  bool isMutationLoading = false; // خاص بعمليات الإضافة والتعديل والحذف
  
  String? error;

  // دالة مساعدة مركزية لتنظيف وتوحيد نصوص الأخطاء القادمة من السيرفر
  String _cleanError(dynamic e) {
    return e.toString().replaceAll("Exception: ", "").trim();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  // =========================================================================
  // 2. لوحة التحكم وتقدم الطلاب (قراءة البيانات)
  // =========================================================================

  /// جلب بيانات لوحة التحكم العامة للحلقات والإحصائيات
  Future<void> loadDashboardData({bool isRefresh = false}) async {
    try {
      isDashboardLoading = true;
      error = null;
      if (!isRefresh) notifyListeners(); // تمنع الوميض العشوائي عند التحديث الخلفي

      // 🛠️ حل ثغرة الانهيار المتتالي: حماية الـ Futures داخلياً لضمان عدم سقوط دالة بسبب الأخرى
      final results = await Future.wait([
        _repo.getMyHalqas().catchError((e) {
          debugPrint("خطأ في جلب الحلقات: $e");
          return <HalqaModel>[];
        }),
        _repo.getTeacherStats().catchError((e) {
          debugPrint("خطأ في جلب الإحصائيات التراكمية: $e");
          return <String, dynamic>{
            "total_pages_memorized": 0,
            "total_points": 0,
            "total_parts_tested": 0,
            "students_count": 0,
          };
        }),
      ]);

      myHalqas = results[0] as List<HalqaModel>;
      dashboardStats = results[1] as Map<String, dynamic>;
    } catch (e) {
      error = _cleanError(e);
    } finally {
      isDashboardLoading = false;
      notifyListeners();
    }
  }

  /// جلب قائمة طلاب حلقة معينة مع عزل حالة التحميل الخاصة بها
  Future<void> loadHalqaStudents(int halqaId) async {
    try {
      isStudentsLoading = true;
      error = null;
      notifyListeners();

      currentHalqaStudents = await _repo.getHalqaStudents(halqaId);
    } catch (e) {
      error = _cleanError(e);
      currentHalqaStudents = [];
    } finally {
      isStudentsLoading = false;
      notifyListeners();
    }
  }

  /// جلب سجل تقدم الطالب مع معالجة حالة الطالب الجديد صامتاً
  Future<void> loadStudentProgress(int studentId, {bool silent = false}) async {
    try {
      if (!silent) {
        isProgressLoading = true;
        error = null;
        notifyListeners();
      }

      // المستودع يعيد null تلقائياً في حال كان الطالب جديداً (404) دون إلقاء خطأ
      studentProgress = await _repo.getStudentProgress(studentId);
    } catch (e) {
      if (!silent) error = _cleanError(e);
      studentProgress = null;
    } finally {
      if (!silent) {
        isProgressLoading = false;
        notifyListeners();
      }
    }
  }

  // =========================================================================
  // 3. منظومة التسميع والمراجعة اليومية (CRUD)
  // =========================================================================

  Future<bool> addMemorization(Map<String, dynamic> data, int studentId) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _repo.addMemorization(data);
      
      // تحديث البيانات المرتبطة صامتاً لتقليل استهلاك معالج الواجهة
      await loadDashboardData(isRefresh: true);
      await loadStudentProgress(studentId, silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMemorization(int id, Map<String, dynamic> data, int studentId) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _repo.updateMemorization(id, data);
      
      await loadDashboardData(isRefresh: true);
      await loadStudentProgress(studentId, silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMemorization(int id, int studentId) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _repo.deleteMemorization(id);
      
      await loadDashboardData(isRefresh: true);
      await loadStudentProgress(studentId, silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // 4. منظومة الحضور والغياب (تحديث فوري وآمن)
  // =========================================================================

  /// تسجيل أو تحديث سجل الحضور (تستخدم آلية UPSERT المعتمدة في السيرفر)
  Future<bool> saveAttendance(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _repo.saveAttendance(data);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // 5. منظومة اختبارات الأجزاء والسور (CRUD)
  // =========================================================================

  Future<bool> addQuranTest(Map<String, dynamic> data, int studentId) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _repo.addTest(data);
      
      await loadDashboardData(isRefresh: true);
      await loadStudentProgress(studentId, silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateQuranTest(int id, Map<String, dynamic> data, int studentId) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _repo.updateTest(id, data);
      
      await loadDashboardData(isRefresh: true);
      await loadStudentProgress(studentId, silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteQuranTest(int id, int studentId) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _repo.deleteTest(id);
      
      await loadDashboardData(isRefresh: true);
      await loadStudentProgress(studentId, silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // 6. عبقرية المسح الميداني الذكي (QR Code Local Engine)
  // =========================================================================

  /// 🛠️ حل ثغرة المطابقة النصية الوهمية الكبرى:
  /// تفكيك الصيغة المشركة للقادم من الكاميرا ومطابقتها برقم الهوية المعياري للطالب رقمياً 100%
/// دالة البحث المحلي السريع والمحصنة بعد التدقيق لمطابقة الرمز الممسوح ميدانياً
PersonModel? findStudentByQrCode(String scannedCode) {
  if (currentHalqaStudents.isEmpty) return null;

  final cleanCode = scannedCode.trim();

  // الحالة الأولى: إذا قام الشيخ بمسح المعرف الرقمي المباشر للطالب
  for (var student in currentHalqaStudents) {
    if (student.id.toString() == cleanCode) {
      return student;
    }
  }

  // الحالة الثانية (الأساسية): تفكيك النص المشفر القادم من كاميرا الـ QR (مثل: QRCENTER_ST_ID_4)
  if (cleanCode.startsWith("QRCENTER_ST_ID_")) {
    // استخراج الرقم فقط عن طريق حذف السابقة النصية
    final String extractedId = cleanCode.replaceFirst("QRCENTER_ST_ID_", "");
    
    for (var student in currentHalqaStudents) {
      if (student.id.toString() == extractedId) {
        return student; // تم العثور على الطالب بنجاح ميكانيكي سريع
      }
    }
  }

  return null; // لم يتم العثور على الطالب في هذه الحلقة
}

  /// تسجيل الحضور السريع والمباشر بمجرد مسح رمز الـ QR دون مغادرة شاشة الكاميرا
Future<bool> registerImmediateAttendance(int studentId, int halqaId, String status) async {
  final today = DateTime.now();
  final formattedDate = "${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";

  final Map<String, dynamic> attendanceData = {
    "student": studentId,
    "halqa": halqaId,
    "status": status,
    "date": formattedDate,
  };

  return saveAttendance(attendanceData);
}

}