import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/data/models/student_progress_model.dart';
import 'package:quran_center_app/services/api/teacher_api.dart';

class TeacherRepository {
  final TeacherApi _api = TeacherApi();

  // =========================================================================
  // 1. جلب البيانات الأساسية والإحصائيات
  // =========================================================================
  
  /// جلب سجل تقدم الطالب مع معالجة ذكية لحالة الطالب الجديد (404) دون انهيار
  Future<StudentProgressModel?> getStudentProgress(int studentId) async {
    try {
      final data = await _api.getStudentProgress(studentId);
      
      if (data.isEmpty || data.containsKey('detail')) {
        return null; 
      }
      
      return StudentProgressModel.fromJson(data);
    } catch (e) {
      final errorStr = e.toString();
      // 🛠️ تصحيح الجودة (Edge Case): إذا كان الخطأ يعبر عن عدم وجود السجل (404) في السيرفر، نعيد null بأمان
      if (errorStr.contains('404') || errorStr.contains('لم يتم إنشاء سجل تقدم')) {
        return null;
      }
      // إعادة رمي الاستثناء الأصيل القادم من الـ API لكي يظهر في الـ Bloc/UI بوضوح
      rethrow;
    }
  }

  /// جلب حلقات المعلم وتحويلها لنماذج مطابقة للهيكلية المعمارية
  Future<List<HalqaModel>> getMyHalqas() async {
    try {
      final data = await _api.getMyHalqas();
      return data.map((e) => HalqaModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// جلب الإحصائيات التراكمية للمعلم لعرضها في لوحة التحكم
  Future<Map<String, dynamic>> getTeacherStats() async {
    try {
      return await _api.getTeacherStats();
    } catch (e) {
      rethrow;
    }
  }

  /// جلب قائمة طلاب حلقة معينة متضمنة روابط الـ QR المعتمدة
  Future<List<PersonModel>> getHalqaStudents(int halqaId) async {
    try {
      final data = await _api.getHalqaStudents(halqaId);
      return data.map((e) => PersonModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================================
  // 2. منظومة الحضور والغياب (UPSERT)
  // =========================================================================

  /// حفظ أو تحديث سجل الحضور مع تهيئة التاريخ للصيغة القياسية للسيرفر
  Future<void> saveAttendance(Map<String, dynamic> data) async {
    try {
      _normalizeDate(data);
      await _api.addAttendance(data); 
    } catch (e) {
      rethrow;
    }
  }

  /// تعديل سجل حضور قائم يدوياً عند الضرورة
  Future<void> updateAttendance(int id, Map<String, dynamic> data) async {
    try {
      _normalizeDate(data);
      await _api.updateAttendance(id, data);
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================================
  // 3. منظومة التسميع اليومي (Full CRUD تحكم كامل)
  // =========================================================================

  /// إضافة جلسة تسميع جديدة
  Future<void> addMemorization(Map<String, dynamic> data) async {
    try {
      _normalizeDate(data);
      await _api.addMemorization(data);
    } catch (e) {
      rethrow;
    }
  }

  /// تعديل سجل تسميع يومي قائم لمعالجة الأخطاء البشرية
  Future<void> updateMemorization(int id, Map<String, dynamic> data) async {
    try {
      _normalizeDate(data);
      await _api.updateMemorization(id, data);
    } catch (e) {
      rethrow;
    }
  }

  /// حذف سجل تسميع نهائياً من قاعدة البيانات
  Future<void> deleteMemorization(int id) async {
    try {
      await _api.deleteMemorization(id);
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================================
  // 4. منظومة الاختبارات القرآنية (Full CRUD تحكم كامل)
  // =========================================================================

  /// تسجيل نتيجة اختبار أجزاء أو سور جديد
  Future<void> addTest(Map<String, dynamic> data) async {
    try {
      _normalizeDate(data);
      await _api.addTest(data);
    } catch (e) {
      rethrow;
    }
  }

  /// تعديل بيانات ودرجات اختبار قائم
  Future<void> updateTest(int id, Map<String, dynamic> data) async {
    try {
      _normalizeDate(data);
      await _api.updateTest(id, data);
    } catch (e) {
      rethrow;
    }
  }

  /// حذف سجل اختبار قرآني بشكل نهائي
  Future<void> deleteTest(int id) async {
    try {
      await _api.deleteTest(id);
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================================
  // 🛠️ دالت مساعدة خاصة (Private Helpers) للاستمثال ومنع تكرار الكود
  // =========================================================================
  
  /// لضمان تحويل كائنات الـ DateTime لـ String متوافق مع صيغة الجانغو القياسية YYYY-MM-DD
  void _normalizeDate(Map<String, dynamic> data) {
    if (data['date'] != null && data['date'] is DateTime) {
      data['date'] = (data['date'] as DateTime).toIso8601String().split('T').first;
    }
  }
}