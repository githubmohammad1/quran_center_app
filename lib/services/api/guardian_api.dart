// // import 'package:dio/dio.dart';
// import '../dio_client.dart';
// import '../../data/models/person_model.dart';
// import '../../data/models/attendance_model.dart';
// import '../../data/models/quran_test_model.dart';
// // import '../../data/models/notification_model.dart';
// import '../../data/models/student_progress_model.dart';

// class GuardianApi {
//   final DioClient _client = DioClient();

//   // جلب الأبناء (نقطة النهاية المخصصة التي صنعناها في جانغو)
//   Future<List<PersonModel>> getChildren() async {
//     final response = await _client.get("persons/my_children/");
//     return (response.data as List).map((e) => PersonModel.fromJson(e)).toList();
//   }

//   // بيانات ابن واحد
//   Future<PersonModel> getChildProfile(int childId) async {
//     final response = await _client.get("persons/$childId/");
//     return PersonModel.fromJson(response.data);
//   }

//   // اختبارات ابن (باستخدام الدالة المخصصة by_student)
//   Future<List<QuranTestModel>> getChildTests(int childId) async {
//     final response = await _client.get("quran-tests/by_student/?student=$childId");
//     return (response.data as List).map((e) => QuranTestModel.fromJson(e)).toList();
//   }

//   // تقدم الابن 
//   // (ملاحظة: جانغو لا تملك API لجلب تقدم ابن محدد بالـ ID حالياً سوى جلب كل التقدم والفلترة)
//   Future<StudentProgressModel?> getChildProgress(String childName) async {
//     final response = await _client.get("progress/?search=$childName");
//     List data = response.data;
//     if (data.isNotEmpty) {
//       return StudentProgressModel.fromJson(data.first);
//     }
//     return null;
//   }
  
//   // الحضور للابن (عبر البحث باسمه)
//   Future<List<AttendanceModel>> getChildAttendance(String childName) async {
//     final response = await _client.get("attendance/?search=$childName");
//     return (response.data as List).map((e) => AttendanceModel.fromJson(e)).toList();
//   }
// }