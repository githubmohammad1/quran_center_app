import 'package:dio/dio.dart';
import 'package:quran_center_app/services/dio_client.dart';

class GuardianApi {
  final DioClient _client = DioClient();

  // 1. جلب قائمة الأبناء المرتبطين برقم هاتف ولي الأمر (تصفية آمنة في السيرفر)
  Future<List<dynamic>> getChildren() async {
    final response = await _client.get("persons/my_children/");
    print(response.data);
    return response.data;
  }

Future<Map<String, dynamic>> getChildProfile(int childId) async {
    try {
      final response = await _client.get("persons/$childId/");
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("لم يتم العثور على بيانات هذا الابن في السيرفر.");
      }
      rethrow;
    }
  }
  // 3. جلب سجل الاختبارات القرآنية (الأجزاء والسور) بناءً على معرف الابن الرقمي
// 3. جلب سجل الاختبارات القرآنية بناءً على معرف الابن الرقمي
  Future<List<dynamic>> getChildTests(int childId) async {
    try {
      final response = await _client.get("quran-tests/by_student/?student=$childId"); 
      print(response.data);
      return response.data; 
    } on DioException catch (e) {
      // إذا لم يعثر السيرفر على اختبارات للطالب، نرجع مصفوفة فارغة بدلاً من الانهيار
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow; // إعادة إلقاء الأخطاء الأخرى مثل خطأ الاتصال 500 أو الشبكة
    }
  }

  // 4. تصحيح جودة: جلب التقدم التراكمي والنقاط بالاعتماد على الـ ID لمنع تضارب الأسماء
 // 4. جلب التقدم التراكمي والنقاط بالاعتماد على الـ ID لمنع تضارب الأسماء
  Future<Map<String, dynamic>?> getChildProgress(int childId) async {
    try {
      final response = await _client.get("progress/by_student/?student=$childId"); 
      print(response.data);
      List data = response.data; 
      if (data.isNotEmpty) return data.first; 
      return null; 
    } on DioException catch (e) {
      // إذا كان الطالب جديداً ولم يتم إنشاء سجل تقدم له بعد في الجانغو
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }
  // 5. تصحيح جودة: جلب سجل الحضور والغياب اليومي بالاعتماد على الـ ID الفريد للطالب
// 5. جلب سجل الحضور والغياب اليومي بالاعتماد على الـ ID الفريد للطالب
  Future<List<dynamic>> getChildAttendance(int childId) async {
  try {
    // 💡 إذا كان الباك إند يعتمد نظام الإجراء المخصص، قم بتغيير الرابط إلى: "attendance/by_student/?student=$childId"
    final response = await _client.get("attendance/by_student/?student=$childId");
    print(response.data);
    return response.data; 
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      return []; // إرجاع مصفوفة فارغة لمنع انهيار الواجهة في حال عدم وجود سجلات
    }
    rethrow;
  }
}
  // 6. إضافة برمجية حتمية: جلب جلسات التسميع اليومية الحية للابن (مفقودة سابقاً)
// 6. جلب جلسات التسميع اليومية الحية للابن
Future<List<dynamic>> getChildMemorizationSessions(int childId) async {
  try {
    // 💡 تأكد إذا كان الرابط يتطلب إجراءً مخصصاً: "memorization/by_student/?student=$childId"
    final response = await _client.get("memorization/by_student/?student=$childId");
    print(response.data); 
    return response.data; 
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      return [];
    }
    rethrow;
  }
}

  // 7. إضافة برمجية حتمية: جلب الإشعارات الخاصة بأبناء ولي الأمر المفرسة خلفياً
  Future<List<dynamic>> getNotifications() async {
    final response = await _client.get("notifications/");
    print(response.data);
    return response.data;
  }

  // 8. إجراء جودة: تفعيل Custom Action لتأكيد قراءة الإشعار من الوالد لتحديث الحالة بالسيرفر
  Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    
    final response = await _client.post("notifications/$notificationId/mark_read/");
    print(response.data);
    return response.data;
  }
}