import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/data/models/student_progress_model.dart';
import 'package:quran_center_app/services/api/teacher_api.dart';

class TeacherRepository {
  final TeacherApi _api = TeacherApi();

  // =========================================================================
  // 1. جلب البيانات الأساسية والإحصائيات (مع معالجة القيمة الفارغة)
  // =========================================================================
  
  Future<StudentProgressModel?> getStudentProgress(int studentId) async {
    try {
      final data = await _api.getStudentProgress(studentId);
      
      // Edge Case: إذا كان الطالب جديداً ولا يملك بيانات تقدم بعد في السيرفر
      if (data.containsKey('detail') || data.isEmpty) {
        return null; 
      }
      
      return StudentProgressModel.fromJson(data);
    } catch (e) {
      throw Exception("خطأ في قراءة ملف تقدم الطالب: ${e.toString()}");
    }
  }

  Future<List<HalqaModel>> getMyHalqas() async {
    try {
      final data = await _api.getMyHalqas();
      return data.map((e) => HalqaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("خطأ في معالجة قائمة الحلقات: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> getTeacherStats() async {
    try {
      return await _api.getTeacherStats();
    } catch (e) {
      throw Exception("خطأ في جلب إحصائيات المعلم: ${e.toString()}");
    }
  }

  Future<List<PersonModel>> getHalqaStudents(int halqaId) async {
    try {
      final data = await _api.getHalqaStudents(halqaId);
      return data.map((e) => PersonModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("خطأ في معالجة طلاب الحلقة رقم $halqaId: ${e.toString()}");
    }
  }

  // =========================================================================
  // 2. إدارة الحضور والغياب
  // =========================================================================

  Future<void> saveAttendance(Map<String, dynamic> data) async {
    try {
      // تحويل التاريخ بصيغة آمنة للسيرفر YYYY-MM-DD في حال تم تمريره كـ DateTime
      if (data['date'] is DateTime) {
        data['date'] = (data['date'] as DateTime).toIso8601String().split('T').first;
      }
      await _api.addAttendance(data); // دائماً POST بناءً على تصميمك الحالي
    } catch (e) {
      throw Exception("فشل في حفظ سجل الحضور: ${e.toString()}");
    }
  }

  // ميزة مضافة: لتعديل سجل الحضور القائم (PUT/PATCH) عبر الـ Repository
  Future<void> updateAttendance(int id, Map<String, dynamic> data) async {
    try {
      if (data['date'] is DateTime) {
        data['date'] = (data['date'] as DateTime).toIso8601String().split('T').first;
      }
      await _api.updateAttendance(id, data);
    } catch (e) {
      throw Exception("فشل في تحديث سجل الحضور: ${e.toString()}");
    }
  }

  // =========================================================================
  // 3. منظومة التسميع اليومي (تحديث شامل للـ CRUD الكامل)
  // =========================================================================

  // ✔ إضافة جلسة تسميع جديدة (حفظ الاسم القديم)
  Future<void> addMemorization(Map<String, dynamic> data) async {
    try {
      if (data['date'] is DateTime) {
        data['date'] = (data['date'] as DateTime).toIso8601String().split('T').first;
      }
      await _api.addMemorization(data);
    } catch (e) {
      throw Exception("فشل في إضافة سجل التسميع: ${e.toString()}");
    }
  }

  // إضافة: تعديل جلسة تسميع سابقة
  Future<void> updateMemorization(int id, Map<String, dynamic> data) async {
    try {
      if (data['date'] is DateTime) {
        data['date'] = (data['date'] as DateTime).toIso8601String().split('T').first;
      }
      await _api.updateMemorization(id, data);
    } catch (e) {
      throw Exception("فشل في تعديل سجل التسميع: ${e.toString()}");
    }
  }

  // إضافة: حذف جلسة تسميع نهائياً
  Future<void> deleteMemorization(int id) async {
    try {
      await _api.deleteMemorization(id);
    } catch (e) {
      throw Exception("فشل في حذف سجل التسميع: ${e.toString()}");
    }
  }

  // =========================================================================
  // 4. منظومة الاختبارات والأجزاء (تحديث شامل للـ CRUD الكامل)
  // =========================================================================

  // ✔ إضافة اختبار جديد (حفظ الاسم القديم)
  Future<void> addTest(Map<String, dynamic> data) async {
    try {
      if (data['date'] is DateTime) {
        data['date'] = (data['date'] as DateTime).toIso8601String().split('T').first;
      }
      await _api.addTest(data);
    } catch (e) {
      throw Exception("فشل في تسجيل نتيجة الاختبار: ${e.toString()}");
    }
  }

  // إضافة: تعديل نتيجة اختبار قائمة
  Future<void> updateTest(int id, Map<String, dynamic> data) async {
    try {
      if (data['date'] is DateTime) {
        data['date'] = (data['date'] as DateTime).toIso8601String().split('T').first;
      }
      await _api.updateTest(id, data);
    } catch (e) {
      throw Exception("فشل في تحديث نتيجة الاختبار: ${e.toString()}");
    }
  }

  // إضافة: حذف نتيجة اختبار نهائياً
  Future<void> deleteTest(int id) async {
    try {
      await _api.deleteTest(id);
    } catch (e) {
      throw Exception("فشل في حذف سجل الاختبار: ${e.toString()}");
    }
  }
}