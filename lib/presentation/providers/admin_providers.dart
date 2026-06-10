import 'package:flutter/material.dart';
import 'package:quran_center_app/data/models/quran_test_model.dart';

// استيراد كافة الموديلات والمستودعات المعتمدة
import '../../data/models/person_model.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/academic_year_model.dart';
import '../../data/models/semester_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/student_progress_model.dart';
import '../../data/models/memorization_session_model.dart';
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
  List<AttendanceModel> attendance = [];
  List<MemorizationSessionModel> memorizationSessions = [];
  List<NotificationModel> notifications = [];

  // حالة خاصة بعرض تقدم الطالب المحدد في لوحة التحكم
  StudentProgressModel? selectedStudentProgress;

  // سجل الاختبارات القرآنية للطالب المحدد حالياً بالواجهة
  List<dynamic> studentTests = [];

  // نتائج البحث
  List<PersonModel> searchResults = [];

  // =========================================================================
  // 2. إدارة الحالة المعزولة ومؤشرات التحميل والأخطاء
  // =========================================================================
  bool isDashboardLoading = false;
  bool isPersonsLoading = false;
  bool isHalqasLoading = false;
  bool isAcademicLoading = false;
  bool isNotificationsLoading = false;
  bool isProgressLoading = false;
  bool isAttendanceLoading = false;
  bool isLoading = false; // مؤشر تحميل عمليات البحث والاختبارات العام
  bool isMutationLoading = false; // خاص بحفظ/تعديل/حذف البيانات

  String? error;
  int? selectedHalqaId;

  // =========================================================================
  // 3. منطق البحث واختبارات الطلاب (Search & Student Tests)
  // =========================================================================

  /// 🔍 منطق البحث الموحد عن الطلاب بالاسم أو الـ ID
  // 3. تحديث دالة البحث لتصفية الـ ID بشكل صارم ومنع تداخل رقم الهاتف
  Future<void> performSearch(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      _applyCurrentFilter();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // 1. جلب نتائج البحث العامة من السيرفر (تعتمد على الـ API الخاص بـ Django)
      final serverResults = await _adminRepo.searchStudents(trimmedQuery);

      // 2. إذا كان المدخل رقماً خالصاً، فلتر محلياً لتطابق الـ ID الصارم فقط ومنع تداخل الهاتف
      final isNumeric = int.tryParse(trimmedQuery) != null;
      if (isNumeric) {
        final targetId = int.parse(trimmedQuery);
        searchResults = serverResults
            .where((student) => student.id == targetId)
            .toList();
      } else {
        searchResults = serverResults;
      }

      // 3. 🚀 تقاطع البحث مع الفلتر: إذا كانت هناك حلقة محددة، احصر النتائج بطلابها فقط
      if (selectedHalqaId != null) {
        final targetHalqa = halqas.firstWhere((h) => h.id == selectedHalqaId);

        // نقوم بفحص ما إذا كان الطالب القادم من السيرفر موجوداً ضمن قائمة طلاب الحلقة محلياً عبر الـ ID
        final halqaStudentIds = targetHalqa.students.map((s) => s.id).toSet();
        searchResults = searchResults
            .where((student) => halqaStudentIds.contains(student.id))
            .toList();
      }
    } catch (e) {
      error = _cleanError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 4. دالة الفلترة حسب الحلقة (تستدعيها الـ Dropdown)
  void filterByHalqa(int? halqaId) {
    selectedHalqaId = halqaId;
    _applyCurrentFilter();
  }

  // دالة مساعدة داخلية لتطبيق الفلترة المدمجة دون تكرار الكود
  // دالة الفلترة المحدثة بناءً على المعمارية الحقيقية للموديلات
  void _applyCurrentFilter() {
    if (selectedHalqaId == null) {
      // إذا اختار "جميع الحلقات"، نعيد القائمة الكاملة لجميع الطلاب
      searchResults = List.from(students);
    } else {
      try {
        // 1. البحث عن الحلقة المختارة داخل مصفوفة الحلقات المجلوبة من السيرفر
        final targetHalqa = halqas.firstWhere((h) => h.id == selectedHalqaId);

        // 2. 🚀 الحل الهندسي: إسناد قائمة الطلاب المسجلين في هذه الحلقة مباشرة
        // بما يطابق تماماً حقل `students` الموجود داخل كائن `HalqaModel`
        searchResults = List.from(targetHalqa.students);
      } catch (e) {
        // في حال عدم العثور على الحلقة (Edge Case)، نفرغ النتائج كإجراء أمان
        searchResults = [];
      }
    }
    notifyListeners();
  }

  /// 📥 جلب اختبارات طالب معين عبر المعرّف (تستدعي الـ Backend ببارامتر مخصص)
  Future<void> fetchTestsByStudent(int studentId, {bool silent = false}) async {
    try {
      error = null;
      if (!silent) {
        isLoading = true;
        notifyListeners();
      }

      // استدعاء المستودع المحدث والذي يعيد الآن كائنات جاهزة ومحولة
      final List<QuranTestModel> parsedTests = await _adminRepo.getQuranTests(
        studentId: studentId,
      );

      studentTests = parsedTests;
    } catch (e) {
      error = _cleanError(e);
    } finally {
      if (!silent) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  /// 📤 إنشاء اختبار قرآني جديد (جزء أو سورة)
  Future<bool> createQuranTest(Map<String, dynamic> data, int studentId) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      // استدعاء المستودع لإرسال الطلب الصافي للباك إند
      await _adminRepo.createQuranTest(data);

      // تحديث قائمة اختبارات الطالب تلقائياً وصامتاً فور الإضافة الناجحة
      await fetchTestsByStudent(studentId, silent: true);

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 تعديل بيانات اختبار سابق
  Future<bool> updateQuranTest(
    int id,
    Map<String, dynamic> data,
    int studentId,
  ) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _adminRepo.updateTest(id, data);
      await fetchTestsByStudent(studentId, silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
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

      await _adminRepo.deleteQuranTest(id);
      await fetchTestsByStudent(studentId, silent: true);
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
  // 4. التحديث الميداني والصامت (Refreshers & Fetchers)
  // =========================================================================

  // Future<void> loadDashboardData() async {
  //   try {
  //     isDashboardLoading = true;
  //     error = null;
  //     notifyListeners();

  //     final results = await Future.wait([
  //       _adminRepo.getStudents().catchError((_) => <PersonModel>[]),
  //       _adminRepo.getTeachers().catchError((_) => <PersonModel>[]),
  //       _adminRepo.getSupervisors().catchError((_) => <PersonModel>[]),
  //       _adminRepo.getHalqas().catchError((_) => <HalqaModel>[]),
  //       _adminRepo.getAcademicYears().catchError((_) => <AcademicYearModel>[]),
  //       _adminRepo.getSemesters().catchError((_) => <SemesterModel>[]),
  //       _adminRepo.getNotifications().catchError((_) => <NotificationModel>[])
  //     ]);

  //     students = results[0] as List<PersonModel>;
  //     teachers = results[1] as List<PersonModel>;
  //     supervisors = results[2] as List<PersonModel>;
  //     halqas = results[3] as List<HalqaModel>;
  //     years = results[4] as List<AcademicYearModel>;
  //     semesters = SmallCastToSemesterList(results[5]);
  //     notifications = results[6] as List<NotificationModel>;
  //   } catch (e) {
  //     error = _cleanError(e);
  //   } finally {
  //     isDashboardLoading = false;
  //     notifyListeners();
  //   }
  // }
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
      semesters = (results[5] as List).cast<SemesterModel>();
      notifications = results[6] as List<NotificationModel>;

      // 🚀 التحديث الهندسي: جعل نتائج البحث تعرض كل الطلاب افتراضياً عند الفتح
      searchResults = List.from(students);
      selectedHalqaId = null; // إعادة تصغير الفلتر
    } catch (e) {
      error = _cleanError(e);
    } finally {
      isDashboardLoading = false;
      notifyListeners();
    }
  }

  static List<SemesterModel> SmallCastToSemesterList(dynamic dynamicList) {
    return (dynamicList as List).cast<SemesterModel>();
  }

  Future<void> refreshPersons({bool silent = false}) async {
    try {
      if (!silent) {
        isPersonsLoading = true;
        notifyListeners();
      }

      final results = await Future.wait([
        _adminRepo.getStudents(),
        _adminRepo.getTeachers(),
        _adminRepo.getSupervisors(),
      ]);

      students = results[0];
      teachers = results[1];
      supervisors = results[2];
    } catch (e) {
      error = _cleanError(e);
    } finally {
      if (!silent) {
        isPersonsLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshHalqas({bool silent = false}) async {
    try {
      if (!silent) {
        isHalqasLoading = true;
        notifyListeners();
      }
      halqas = await _adminRepo.getHalqas();
    } catch (e) {
      error = _cleanError(e);
    } finally {
      if (!silent) {
        isHalqasLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshAcademicData({bool silent = false}) async {
    try {
      if (!silent) {
        isAcademicLoading = true;
        notifyListeners();
      }

      // تنفيذ الاستدعاءات بالتوازي
      final results = await Future.wait([
        _adminRepo.getAcademicYears(),
        _adminRepo.getSemesters(),
      ]);

      // تحويل العناصر بشكل صريح وآمن لمنع خطأ الـ Invalid Assignment
      years = (results[0] as List).cast<AcademicYearModel>();
      semesters = (results[1] as List).cast<SemesterModel>();
    } catch (e) {
      error = _cleanError(e);
    } finally {
      if (!silent) {
        isAcademicLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshAttendance({
    Map<String, dynamic>? queryParameters,
    bool silent = false,
  }) async {
    try {
      if (!silent) {
        isAttendanceLoading = true;
        notifyListeners();
      }

      attendance = await _adminRepo.getAttendance(
        queryParameters: queryParameters,
      );
    } catch (e) {
      error = _cleanError(e);
    } finally {
      if (!silent) {
        isAttendanceLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> recordAttendance(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _adminRepo.recordAttendance(data);
      await refreshAttendance(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<int> recordAttendanceBatch(List<Map<String, dynamic>> entries) async {
    var successCount = 0;
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      for (final entry in entries) {
        await _adminRepo.recordAttendance(entry);
        successCount++;
      }

      return successCount;
    } catch (e) {
      error = _cleanError(e);
      return successCount;
    } finally {
      await refreshAttendance(silent: true);
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMemorizationSession(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _adminRepo.createMemorizationSession(data);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<int> createMemorizationSessionsBatch(
    List<Map<String, dynamic>> entries,
  ) async {
    var successCount = 0;
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      for (final entry in entries) {
        await _adminRepo.createMemorizationSession(entry);
        successCount++;
      }

      return successCount;
    } catch (e) {
      error = _cleanError(e);
      return successCount;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAttendance(int id) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _adminRepo.deleteAttendance(id);
      await refreshAttendance(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications({bool silent = false}) async {
    try {
      if (!silent) {
        isNotificationsLoading = true;
        notifyListeners();
      }
      notifications = await _adminRepo.getNotifications();
    } catch (e) {
      error = _cleanError(e);
    } finally {
      if (!silent) {
        isNotificationsLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadStudentProgress(int studentId) async {
    try {
      isProgressLoading = true;
      error = null;
      selectedStudentProgress = null;
      notifyListeners();

      selectedStudentProgress = await _adminRepo.getProgressByStudentId(
        studentId,
      );
    } catch (e) {
      error = _cleanError(e);
    } finally {
      isProgressLoading = false;
      notifyListeners();
    }
  }

  // =========================================================================
  // 5. عمليات الأشخاص والكيانات (CRUD Operations)
  // =========================================================================

  Future<bool> createPerson(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.createPerson(data);
      await refreshPersons(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePerson(int id, Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.updatePerson(id, data);
      await refreshPersons(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePerson(int id) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.deletePerson(id);
      await refreshPersons(silent: true);
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
  // 🚀 طبقة إدارة الحلقات المتقدمة (Halqas Management Provider)
  // =========================================================================

  // 0. إنشاء حلقة قرآنية جديدة
  Future<bool> createHalqa(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _adminRepo.createHalqa(data);
      await refreshHalqas(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  // 1. تحديث بيانات الحلقة وقائمة طلابها بالكامل
  Future<bool> updateHalqa(int id, Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      // إرسال طلب التعديل (PATCH) للمستودع
      await _adminRepo.updateHalqa(id, data);

      // إعادة تحميل الحلقات مع إشعار الواجهة فوراً
      await refreshHalqas();

      // جلب عضوية الطلاب الحالية للحلقة وتحديث الكاش المحلي إن لزم الأمر
      await fetchStudentsForHalqa(id);
      final index = halqas.indexWhere((item) => item.id == id);
      if (index != -1) {
        halqas[index] = halqas[index].copyWith(students: _currentHalqaStudents);
        notifyListeners();
      }

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  // 2. حذف حلقة قرآنية نهائياً مع معالجة قيود المفاتيح الأجنبية القادمة من الجانغو
  Future<bool> deleteHalqa(int id) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      await _adminRepo.deleteHalqa(id);

      // تحديث فوري للقائمة بعد الحذف
      await refreshHalqas(silent: true);
      return true;
    } catch (e) {
      // هنا سيتم التقاط رسالة الجانغو: "لا يمكن حذف الحلقة لوجود سجلات حضور..."
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  // 3. ميزة تتبع وإدارة الطلاب: جلب طلاب حلقة معينة حصرياً من السيرفر بشكل مباشر (Endpoint المخصص)
  List<PersonModel> _currentHalqaStudents = [];
  List<PersonModel> get currentHalqaStudents => _currentHalqaStudents;
  bool isLoadingStudents = false;

  Future<void> fetchStudentsForHalqa(int halqaId) async {
    try {
      isLoadingStudents = true;
      error = null;
      notifyListeners();

      // استدعاء دالة الـ Repo التي تربط مع الـ @action(detail=True) المكتوب في الجانغو
      final List<dynamic> data = await _adminRepo.getHalqaStudents(halqaId);
      _currentHalqaStudents = data
          .map((e) => PersonModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error = _cleanError(e);
    } finally {
      isLoadingStudents = false;
      notifyListeners();
    }
  }

  Future<bool> createAcademicYear(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.createAcademicYear(data);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAcademicYear(int id, Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.updateAcademicYear(id, data);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAcademicYear(int id) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.deleteAcademicYear(id);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSemester(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.createSemester(data);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSemester(int id, Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.updateSemester(id, data);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSemester(int id) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.deleteSemester(id);
      await refreshAcademicData(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendNotification(Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.sendNotification(data);
      await refreshNotifications(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<int> sendNotificationsBatch(List<Map<String, dynamic>> entries) async {
    var successCount = 0;
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();

      for (final entry in entries) {
        await _adminRepo.sendNotification(entry);
        successCount++;
      }

      await refreshNotifications(silent: true);
      return successCount;
    } catch (e) {
      error = _cleanError(e);
      return successCount;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateNotification(int id, Map<String, dynamic> data) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.updateNotification(id, data);
      await refreshNotifications(silent: true);
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      isMutationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNotification(int id) async {
    try {
      isMutationLoading = true;
      error = null;
      notifyListeners();
      await _adminRepo.deleteNotification(id);
      await refreshNotifications(silent: true);
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
  // 6. دوال مساعدة لتنظيف الأخطاء وتحسين العرض للواجهات
  // =========================================================================
  String _cleanError(dynamic e) {
    return e.toString().replaceAll("Exception: ", "").trim();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
