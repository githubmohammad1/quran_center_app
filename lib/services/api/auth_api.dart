// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../dio_client.dart';
// import '../../data/models/person_model.dart';

// class AuthApi {
//   final DioClient _client = DioClient();
//   final _storage = const FlutterSecureStorage();

//   // تسجيل الدخول
//    Future<PersonModel> login(String phone, String password) async {
//     try {
//       final response = await _client.post(
//         "auth/login/",
//         data: {
//           "phone": phone,
//           "password": password,
//         },
//       );

//       final data = response.data;

//       // التحقق مما إذا كان السيرفر أرجع بيانات المستخدم فارغة (null)
//       if (data["user"] == null) {
//         throw Exception("تم تسجيل الدخول، ولكن هذا الحساب ليس له ملف شخصي (Profile) في النظام.");
//       }

//       // حفظ التوكنز في التخزين الآمن
//       await _storage.write(key: "access_token", value: data["access"]);
//       await _storage.write(key: "refresh_token", value: data["refresh"]);

//       // إرجاع بيانات الشخص
//       return PersonModel.fromJson(data["user"]);
      
//     } on DioException catch (e) {
//       throw Exception(e.response?.data["detail"] ?? "خطأ في تسجيل الدخول. تأكد من البيانات.");
//     }
//   }

//   // تحديث FCM Token للإشعارات
//   Future<void> updateFcmToken(String token) async {
//     try {
//       await _client.post(
//         "auth/update-fcm/",
//         data: {"fcm_token": token},
//       );
//     } catch (e) {
//       print("⚠ فشل تحديث FCM Token");
//     }
//   }

//   // تسجيل الخروج
//   Future<void> logout() async {
//     try {
//       // إحضار الـ refresh token لإرساله للسيرفر لإيقافه
//       final refreshToken = await _storage.read(key: "refresh_token");
      
//       if (refreshToken != null) {
//         await _client.post(
//           "auth/logout/",
//           data: {"refresh": refreshToken},
//         );
//       }
//     } catch (e) {
//       print("⚠ خطأ أثناء تسجيل الخروج من السيرفر: $e");
//       // نستمر في مسح البيانات محلياً حتى لو فشل السيرفر
//     } finally {
//       // مسح جميع التوكنز المحفوظة محلياً
//       await _storage.deleteAll();
//     }
//   }

//   // تغيير كلمة المرور (جديد)
//   Future<void> changePassword(String oldPassword, String newPassword) async {
//     try {
//       await _client.post(
//         "auth/change-password/",
//         data: {
//           "old_password": oldPassword,
//           "new_password": newPassword,
//         },
//       );
//     } on DioException catch (e) {
//       throw Exception(e.response?.data["detail"] ?? "فشل تغيير كلمة المرور. تأكد من كلمة المرور القديمة.");
//     }
//   }
// }