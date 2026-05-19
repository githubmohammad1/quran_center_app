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
      // 🖨️ تتبع مدخلات الدالة
      print("--- [تتبع التقدم] البدء برقم معرف الطالب: $studentId ---");

      final data = await _api.getStudentProgress(studentId);

      // 🖨️ تتبع البيانات الخام المستلمة من السيرفر (Raw JSON)
      print("-> [البيانات الخام من السيرفر]: $data");

      if (data.isEmpty || data.containsKey('detail')) {
        // 🖨️ رصد حالة البيانات الفارغة أو رسائل التفاصيل المرجعة من الباك إند
        print("-> [مسار خطي]: البيانات فارغة أو تحتوي على حقل 'detail'، سيتم إرجاع null.");
        return null;
      }

      // تحويل البيانات الخام إلى كائن مصنف (Model Mapping)
      final progress = StudentProgressModel.fromJson(data);

      // 🖨️ رصد نجاح عملية التفكيك وقراءة المتغيرات الداخلية للكائن المستهدف
      print(
        "🎯 [تم التحويل بنجاح]: "
        "معرف السجل: ${progress.id} | "
        "الصفحات المحفوظة: ${progress.totalPagesMemorized} | "
        "النقاط التراكمية: ${progress.points} | "
        "الأجزاء المختبرة: ${progress.totalPartsTested}"
      );
      print("---------------------------------------------------------------------");

      return progress;
    } catch (e) {
      final errorStr = e.toString();
      
      // 🖨️ طباعة الخطأ الأصلي بمجرد التقاطه قبل الفلترة
      print("⚠️ [التقاط استثناء] نص الخطأ الخام: $errorStr");

      // 🛠️ تصحيح الجودة (Edge Case): فحص شروط المعالجة الآمنة لحالة الـ 404
      if (errorStr.contains('404') || errorStr.contains('لم يتم إنشاء سجل تقدم')) {
        // 🖨️ تأكيد تفعيل المعالجة الذكية لحالة الطالب الجديد
        print("💡 [حالة خاصة معالجة]: تم رصد 404 أو سجل غير منشأ، سيتم إرجاع null بأمان لتفادي انهيار الواجهة.");
        print("---------------------------------------------------------------------");
        return null;
      }
      
      // 🖨️ طباعة الأخطاء الحرجة الأخرى (مثل انقطاع الإنترنت أو انهيار السيرفر 500)
      print("❌ [خطأ حرج غير متوقع]: فشلت الدالة تماماً، سيتم إعادة رمي الاستثناء لطبقة الـ Provider.");
      print("---------------------------------------------------------------------");
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
  /// جلب قائمة طلاب حلقة معينة متضمنة روابط الـ QR المعتمدة
  Future<List<PersonModel>> getHalqaStudents(int halqaId) async {
    try {
      // 1. جلب البيانات الخام من طبقة الـ API
      final data = await _api.getHalqaStudents(halqaId);

      // 2. 🛠️ [تحصين الجودة معماريًا]: معالجة البيانات الخام داخل الريبو قبل تمريرها للموديل
      final List<PersonModel> studentsList = data.map((jsonRecord) {
        
        // التحقق من وجود حقل الـ qr_code ومعالجته ليكون رابطاً مطلقاً
        if (jsonRecord["qr_code"] != null && jsonRecord["qr_code"].toString().isNotEmpty) {
          final String rawQr = jsonRecord["qr_code"].toString();
          if (!rawQr.startsWith("http")) {
            jsonRecord["qr_code"] = "https://mohammadpythonanywher1.pythonanywhere.com$rawQr";
          }
        }

        // 3. تمرير الـ JSON المنظف والمجهز بالكامل إلى الموديل الغبي
        return PersonModel.fromJson(jsonRecord);
      }).toList();

      print("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
      print("--- [فحص الحلقة] المعرف: $halqaId | إجمالي الطلاب: ${studentsList.length} ---");
      print("-------------------------------------------------------------");
      for (var student in studentsList) {
        print("طالب -> معرف: ${student.id} | الاسم: ${student.fullName} | الرمز: ${student.qrCode ?? 'لا يوجد'}");
      }
      print("-------------------------------------------------------------");

      return studentsList;
    } catch (e) {
      print("❌ خطأ صريح في جلب طلاب الحلقة [$halqaId]: $e");
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
      data['date'] = (data['date'] as DateTime)
          .toIso8601String()
          .split('T')
          .first;
    }
  }
}
