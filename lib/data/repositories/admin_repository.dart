import 'package:quran_center_app/services/api/admin_api.dart';

import '../../data/models/person_model.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/academic_year_model.dart';
import '../../data/models/semester_model.dart';
import '../../data/models/notification_model.dart'; // إضافة موديول الموديل لتوثيق السجل

class AdminRepository {
  final AdminApi _api = AdminApi();

  // =========================================================================
  // 1. إدارة الأشخاص (الطلاب والمعلمين) - الحفاظ التام على البنية القديمة
  // =========================================================================
  
  Future<List<PersonModel>> getStudents() async {
    try {
      final data = await _api.getPersons("student");
      return data.map((e) => PersonModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("خطأ في معالجة بيانات الطلاب: ${e.toString()}");
    }
  }

  Future<List<PersonModel>> getTeachers() async {
    try {
      final data = await _api.getPersons("teacher");
      return data.map((e) => PersonModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("خطأ في معالجة بيانات المعلمين: ${e.toString()}");
    }
  }

  Future<void> createPerson(Map<String, dynamic> data) async => await _api.createPerson(data);
  Future<void> updatePerson(int id, Map<String, dynamic> data) async => await _api.updatePerson(id, data);
  Future<void> deletePerson(int id) async => await _api.deletePerson(id);

  // =========================================================================
  // 2. إدارة الحلقات القرآنية - الحفاظ التام على البنية القديمة
  // =========================================================================
  
  Future<List<HalqaModel>> getHalqas() async {
    try {
      final data = await _api.getHalqas();
      return data.map((e) => HalqaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("خطأ في تحويل بيانات الحلقات: ${e.toString()}");
    }
  }

  Future<void> createHalqa(Map<String, dynamic> data) async => await _api.createHalqa(data);
  Future<void> updateHalqa(int id, Map<String, dynamic> data) async => await _api.updateHalqa(id, data);
  Future<void> deleteHalqa(int id) async => await _api.deleteHalqa(id);

  // =========================================================================
  // 3. الإعدادات الأكاديمية (تحديث شامل لمنظومة الـ CRUD للسنوات والفصول)
  // =========================================================================

  // --- السنوات الأكاديمية ---
  Future<List<AcademicYearModel>> getAcademicYears() async {
    try {
      final data = await _api.getAcademicYears();
      return data.map((e) => AcademicYearModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("خطأ في قراءة بيانات السنوات الدراسية: ${e.toString()}");
    }
  }

  // إضافة: إنشاء سنة أكاديمية جديدة
  Future<void> createAcademicYear(Map<String, dynamic> data) async {
    // Edge Case: التحقق من صحة صياغة التواريخ من جهة العميل قبل الإرسال
    if (data['start_date'] == null || data['end_date'] == null) {
      throw Exception("يجب تحديد تاريخ البداية والنهاية للسنة الدراسية");
    }
    await _api.createAcademicYear(data);
  }

  // إضافة: تعديل سنة أكاديمية
  Future<void> updateAcademicYear(int id, Map<String, dynamic> data) async => 
      await _api.updateAcademicYear(id, data);

  // إضافة: حذف سنة أكاديمية
  Future<void> deleteAcademicYear(int id) async => await _api.deleteAcademicYear(id);


  // --- الفصول الدراسية ---
  Future<List<SemesterModel>> getSemesters() async {
    try {
      final data = await _api.getSemesters();
      return data.map((e) => SemesterModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("خطأ في قراءة بيانات الفصول الدراسية: ${e.toString()}");
    }
  }

  // إضافة: إنشاء فصل دراسي جديد
  Future<void> createSemester(Map<String, dynamic> data) async => await _api.createSemester(data);

  // إضافة: تعديل فصل دراسي
  Future<void> updateSemester(int id, Map<String, dynamic> data) async => 
      await _api.updateSemester(id, data);

  // إضافة: حذف فصل دراسي
  Future<void> deleteSemester(int id) async => await _api.deleteSemester(id);

  // =========================================================================
  // 4. إدارة نظام الإشعارات والتنبيهات العامة
  // =========================================================================
  
  // إضافة: جلب سجل الإشعارات المرسلة سابقاً (لعرضها للآدمن في لوحة التحكم)
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final data = await _api.getNotifications();
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("خطأ في قراءة سجل الإشعارات: ${e.toString()}");
    }
  }

  Future<void> sendNotification(Map<String, dynamic> data) async {
    // Edge Case Validation: منع إرسال إشعارات فارغة العناوين أو المحتوى
    if ((data['title']?.toString().trim().isEmpty ?? true) || 
        (data['content']?.toString().trim().isEmpty ?? true)) {
      throw Exception("خطأ: لا يمكن إرسال إشعار بدون عنوان أو محتوى نصي.");
    }
    await _api.sendNotification(data);
  }

  // إضافة: حذف إشعار قديم من الأرشيف السحابي
  Future<void> deleteNotification(int id) async => await _api.deleteNotification(id);
}