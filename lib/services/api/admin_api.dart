
// import '../dio_client.dart';
// import '../../data/models/person_model.dart';
// import '../../data/models/halqa_model.dart';

// class AdminApi {
//   final DioClient _client = DioClient();

//   // جلب الطلاب (باستخدام ميزة البحث في DRF)
//   Future<List<PersonModel>> getStudents() async {
//     final response = await _client.get("persons/?search=student");
//     return (response.data as List).map((e) => PersonModel.fromJson(e)).toList();
//   }

//   // جلب الأساتذة
//   Future<List<PersonModel>> getTeachers() async {
//     final response = await _client.get("persons/?search=teacher");
//     return (response.data as List).map((e) => PersonModel.fromJson(e)).toList();
//   }

//   // جلب الحلقات
//   Future<List<HalqaModel>> getHalqas() async {
//     final response = await _client.get("halqas/");
//     return (response.data as List).map((e) => HalqaModel.fromJson(e)).toList();
//   }

//   // إنشاء حلقة
//   Future<void> createHalqa(Map<String, dynamic> data) async {
//     await _client.post("halqas/", data: data);
//   }

//   // تسجيل حضور
//   Future<void> addAttendance(Map<String, dynamic> data) async {
//     await _client.post("attendance/", data: data);
//   }

//   // تسجيل حفظ
//   Future<void> addMemorization(Map<String, dynamic> data) async {
//     await _client.post("memorization/", data: data);
//   }

//   // تسجيل اختبار
//   Future<void> addTest(Map<String, dynamic> data) async {
//     await _client.post("quran-tests/", data: data);
//   }
// }