import 'package:dio/dio.dart';
import 'package:quran_center_app/services/api/admin_api.dart';

// استيراد كافة الموديلات المطلوبة
import '../../data/models/person_model.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/academic_year_model.dart';
import '../../data/models/semester_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/memorization_session_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/student_progress_model.dart';
import '../../data/models/notification_model.dart';

class AdminRepository {
  final AdminApi _api = AdminApi();

  Future<List<PersonModel>> searchStudents(String query) async {
    final data = await _api.searchStudents(query);
    return data.map((e) => PersonModel.fromJson(e)).toList();
  }


  // =========================================================================
  // 1. إدارة الأشخاص (Users & Persons)
  // =========================================================================
  
  Future<List<PersonModel>> getPersons({Map<String, dynamic>? queryParameters}) async {
    final data = await _api.getPersons(queryParameters: queryParameters);
    try {
      return data.map((e) => PersonModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception("خطأ في معالجة بيانات الأشخاص: ${e.toString()}");
    }
  }

  // دوال مساعدة لجلب فئات محددة بسهولة في واجهات المستخدم
  Future<List<PersonModel>> getStudents() async => await getPersons(queryParameters: {"role": "student"});
  Future<List<PersonModel>> getTeachers() async => await getPersons(queryParameters: {"role": "teacher"});
  Future<List<PersonModel>> getSupervisors() async => await getPersons(queryParameters: {"role": "supervisor"});

  Future<PersonModel> createPerson(Map<String, dynamic> data) async {
    final responseData = await _api.createPerson(data);
    try {
      return PersonModel.fromJson(responseData);
    } catch (e) {
      throw Exception("تم الإنشاء لكن حدث خطأ في قراءة بيانات الحساب الجديد.");
    }
  }

  Future<void> updatePerson(int id, Map<String, dynamic> data) async => await _api.updatePerson(id, data);
  Future<void> deletePerson(int id) async => await _api.deletePerson(id);

  // =========================================================================
  // 2. إدارة الحلقات القرآنية (Halqas)
  // =========================================================================
  
  Future<List<HalqaModel>> getHalqas({Map<String, dynamic>? queryParameters}) async {
    final data = await _api.getHalqas(queryParameters: queryParameters);
    try {
      return data.map((e) => HalqaModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception("خطأ في تحويل بيانات الحلقات: ${e.toString()}");
    }
  }

  Future<void> createHalqa(Map<String, dynamic> data) async => await _api.createHalqa(data);
  Future<void> updateHalqa(int id, Map<String, dynamic> data) async => await _api.updateHalqa(id, data);
  Future<List<dynamic>> getHalqaStudents(int halqaId) async => await _api.getHalqaStudents(halqaId);
  Future<void> deleteHalqa(int id) async => await _api.deleteHalqa(id);

  // =========================================================================
  // 3. الإعدادات الأكاديمية (Academic Years & Semesters)
  // =========================================================================

  // --- السنوات الأكاديمية ---
  Future<List<AcademicYearModel>> getAcademicYears() async {
    final data = await _api.getAcademicYears();
    try {
      return data.map((e) => AcademicYearModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception("خطأ في قراءة بيانات السنوات الدراسية: ${e.toString()}");
    }
  }

  Future<void> createAcademicYear(Map<String, dynamic> data) async {
    if (data['name']?.toString().trim().isEmpty ?? true) {
      throw Exception("يجب كتابة اسم السنة الدراسية.");
    }
    await _api.createAcademicYear(data);
  }

  Future<void> updateAcademicYear(int id, Map<String, dynamic> data) async => await _api.updateAcademicYear(id, data);
  Future<void> deleteAcademicYear(int id) async => await _api.deleteAcademicYear(id);

  // --- الفصول الدراسية ---
  Future<List<SemesterModel>> getSemesters({Map<String, dynamic>? queryParameters}) async {
    final data = await _api.getSemesters(queryParameters: queryParameters);
    try {
      return data.map((e) => SemesterModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception("خطأ في قراءة بيانات الفصول الدراسية: ${e.toString()}");
    }
  }

  Future<void> createSemester(Map<String, dynamic> data) async => await _api.createSemester(data);
  Future<void> updateSemester(int id, Map<String, dynamic> data) async => await _api.updateSemester(id, data);
  Future<void> deleteSemester(int id) async => await _api.deleteSemester(id);

  // =========================================================================
  // 4. الحضور والغياب (Attendance)
  // =========================================================================

  Future<List<AttendanceModel>> getAttendance({Map<String, dynamic>? queryParameters}) async {
    final data = await _api.getAttendance(queryParameters: queryParameters);
    try {
      return data.map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception("خطأ في قراءة سجلات الحضور: ${e.toString()}");
    }
  }

  Future<void> recordAttendance(Map<String, dynamic> data) async => await _api.recordAttendance(data);
  Future<void> deleteAttendance(int id) async => await _api.deleteAttendance(id);

  // =========================================================================
  // 5. جلسات التسميع (Memorization Sessions)
  // =========================================================================

  Future<List<MemorizationSessionModel>> getMemorizationSessions({Map<String, dynamic>? queryParameters}) async {
    final data = await _api.getMemorizationSessions(queryParameters: queryParameters);
    try {
      return data.map((e) => MemorizationSessionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception("خطأ في قراءة جلسات التسميع: ${e.toString()}");
    }
  }

  Future<void> createMemorizationSession(Map<String, dynamic> data) async => await _api.createMemorizationSession(data);
  Future<void> updateMemorizationSession(int id, Map<String, dynamic> data) async => await _api.updateMemorizationSession(id, data);
  Future<void> deleteMemorizationSession(int id) async => await _api.deleteMemorizationSession(id);

  // =========================================================================
  // 6. الاختبارات القرآنية (Quran Tests)
  // =========================================================================



/// 🛠️ واجهة جلب الاختبارات: تحدد الـ Endpoint والبارامترات وتمررها لطبقة الـ API
 // 🚀 التحديث الهندسي: تغيير نوع الخرج الصريح إلى List<QuranTestModel> بدلاً من List<dynamic>
Future<List<QuranTestModel>> getQuranTests({int? studentId, Map<String, dynamic>? queryParameters}) async {
  final Map<String, dynamic> params = queryParameters ?? {};
  String endpoint = "quran-tests/";

  if (studentId != null) {
    endpoint = "quran-tests/by_student/";
    params['student'] = studentId.toString();
  }

  // استدعاء طبقة الشبكة الصافية
  final rawData = await _api.getQuranTests(endpoint: endpoint, queryParameters: params);
  
  // 🚀 الحل الجذري: تحويل الـ Json Maps القادمة من Django إلى كائنات QuranTestModel
  try {
    return (rawData as List)
        .map((e) => QuranTestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception("خطأ في تحويل بيانات الاختبارات القرآنية (Parsing Error): $e");
  }
}

  /// 🛠️ واجهة إنشاء اختبار
  Future<void> createQuranTest(Map<String, dynamic> data) async {
    await _api.createQuranTest(data);
  }

  /// 🛠️ واجهة تعديل اختبار
  Future<void> updateTest(int id, Map<String, dynamic> data) async {
    await _api.updateQuranTest(id, data);
  }

  /// 🛠️ واجهة حذف اختبار
  Future<void> deleteQuranTest(int id) async {
    await _api.deleteQuranTest(id);
  }



  // =========================================================================
  // 7. تقدم الطلاب (Student Progress)
  // =========================================================================

  Future<List<StudentProgressModel>> getAllProgress({Map<String, dynamic>? queryParameters}) async {
    final data = await _api.getAllProgress(queryParameters: queryParameters);
    try {
      return data.map((e) => StudentProgressModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception("خطأ في قراءة إحصائيات التقدم: ${e.toString()}");
    }
  }

  Future<StudentProgressModel> getProgressByStudentId(int studentId) async {
    final data = await _api.getProgressByStudentId(studentId);
    try {
      return StudentProgressModel.fromJson(data);
    } catch (e) {
      throw Exception("خطأ في قراءة بيانات تقدم الطالب.");
    }
  }

  // =========================================================================
  // 8. الإشعارات (Notifications)
  // =========================================================================

  Future<List<NotificationModel>> getNotifications() async {
    final data = await _api.getNotifications();
    try {
      return data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception("خطأ في قراءة سجل الإشعارات: ${e.toString()}");
    }
  }

  Future<void> sendNotification(Map<String, dynamic> data) async {
    // Edge Case Validation: منع إرسال إشعارات فارغة العناوين أو المحتوى
    if ((data['title']?.toString().trim().isEmpty ?? true) || 
        (data['message']?.toString().trim().isEmpty ?? true)) {
      throw Exception("خطأ: لا يمكن إرسال إشعار بدون عنوان أو محتوى نصي (message).");
    }
    await _api.sendNotification(data);
  }

  Future<void> updateNotification(int id, Map<String, dynamic> data) async {
    if ((data['title']?.toString().trim().isEmpty ?? true) ||
        (data['message']?.toString().trim().isEmpty ?? true)) {
      throw Exception("خطأ: لا يمكن حفظ إشعار بدون عنوان أو محتوى نصي.");
    }
    await _api.updateNotification(id, data);
  }

  Future<void> deleteNotification(int id) async => await _api.deleteNotification(id);
}
