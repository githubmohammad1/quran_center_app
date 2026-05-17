import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- (1) Dio Client Setup ---

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;
  final _storage = const FlutterSecureStorage();

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://mohammadpythonanywher1.pythonanywhere.com/api/",
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ❗ لا نرسل التوكن في تسجيل الدخول أو تحديث التوكن
          if (options.path.contains("auth/login") ||
              options.path.contains("auth/refresh")) {
            return handler.next(options);
          }

          final token = await _storage.read(key: "access_token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },

        onError: (error, handler) async {
          // إذا كان الخطأ 401 → نحاول تحديث التوكن تلقائياً
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();

            if (refreshed) {
              // إعادة إرسال الطلب الأصلي بعد تحديث التوكن
              final newToken = await _storage.read(key: "access_token");
              error.requestOptions.headers["Authorization"] =
                  "Bearer $newToken";

              final cloned = await dio.request(
                error.requestOptions.path,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
              );

              return handler.resolve(cloned);
            }
          }

          // طباعة الخطأ
          print("❌ API Error: ${error.response?.data}");
          return handler.next(error);
        },
      ),
    );
  }

  // -----------------------------
  // 🔄 Auto Refresh Token
  // -----------------------------
  Future<bool> _refreshToken() async {
    try {
      final refresh = await _storage.read(key: "refresh_token");
      if (refresh == null) return false;

      final response = await dio.post(
        "auth/refresh/",
        data: {"refresh": refresh},
      );

      final newAccess = response.data["access"];
      await _storage.write(key: "access_token", value: newAccess);

      return true;
    } catch (e) {
      await _storage.deleteAll();
      return false;
    }
  }

  // -----------------------------
  // Requests
  // -----------------------------
  Future<Response> get(String path) async => await dio.get(path);
  Future<Response> post(String path, {dynamic data}) async =>
      await dio.post(path, data: data);
  Future<Response> put(String path, {dynamic data}) async =>
      await dio.put(path, data: data);
  Future<Response> patch(String path, {dynamic data}) async =>
      await dio.patch(path, data: data);
  Future<Response> delete(String path) async => await dio.delete(path);
}


// --- (2) Auth API ---
class AuthApi {
  final DioClient _client = DioClient();
  final _storage = const FlutterSecureStorage();
Future<void> updateFcmToken(String token) async {
  await _client.post(
    "auth/update-fcm/",
    data: {"fcm_token": token},
  );
}

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _client.post(
        "auth/login/",
        data: {"phone": phone, "password": password},
      );
      final data = response.data;

      if (data["user"] == null) {
        throw Exception("الحساب ليس له ملف شخصي.");
      }

      await _storage.write(key: "access_token", value: data["access"]);
      await _storage.write(key: "refresh_token", value: data["refresh"]);

      return data["user"]; // إرجاع ماب ليتم تحويله في الـ Repository
    } on DioException catch (e) {
      throw Exception(e.response?.data["detail"] ?? "بيانات الدخول غير صحيحة.");
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: "refresh_token");
      if (refreshToken != null) {
        await _client.post("auth/logout/", data: {"refresh": refreshToken});
      }
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _client.post(
        "auth/change-password/",
        data: {"old_password": oldPassword, "new_password": newPassword},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data["detail"] ?? "فشل تغيير كلمة المرور.");
    }
  }

  // استخدام TokenRefreshView
  Future<String?> refreshToken() async {
    try {
      final refresh = await _storage.read(key: "refresh_token");
      if (refresh == null) return null;

      final response = await _client.post("auth/refresh/", data: {"refresh": refresh});
      final newAccess = response.data["access"];
      await _storage.write(key: "access_token", value: newAccess);
      return newAccess;
    } catch (e) {
      await _storage.deleteAll();
      return null;
    }
  }
}

// --- (3) General API (البيانات المشتركة والقراءة فقط) ---
class GeneralApi {
  final DioClient _client = DioClient();

  Future<List<dynamic>> getSurahs() async {
    final response = await _client.get("surahs/");
    return response.data;
  }

  Future<List<dynamic>> getPageMappings() async {
    final response = await _client.get("pages/");
    return response.data;
  }
}

// --- (4) Admin API ---
class AdminApi {
  final DioClient _client = DioClient();

  // الأشخاص (CRUD)
  Future<List<dynamic>> getPersons(String role) async {
    final response = await _client.get("persons/?search=$role");
    return response.data;
  }
  
  Future<void> createPerson(Map<String, dynamic> data) async => await _client.post("persons/", data: data);
  Future<void> updatePerson(int id, Map<String, dynamic> data) async => await _client.patch("persons/$id/", data: data);
  Future<void> deletePerson(int id) async => await _client.delete("persons/$id/");

  // السنوات والفصول الأكاديمية
  Future<List<dynamic>> getAcademicYears() async {
    final response = await _client.get("academic-years/");
    return response.data;
  }
  
  Future<List<dynamic>> getSemesters() async {
    final response = await _client.get("semesters/");
    return response.data;
  }

  // الحلقات (CRUD)
  Future<List<dynamic>> getHalqas() async {
    final response = await _client.get("halqas/");
    return response.data;
  }
  
  Future<void> createHalqa(Map<String, dynamic> data) async => await _client.post("halqas/", data: data);
  Future<void> updateHalqa(int id, Map<String, dynamic> data) async => await _client.patch("halqas/$id/", data: data);
  Future<void> deleteHalqa(int id) async => await _client.delete("halqas/$id/");
  
  // الإشعارات للإدارة
  Future<void> sendNotification(Map<String, dynamic> data) async => await _client.post("notifications/", data: data);
}

// --- (5) Teacher API (خاص بالأساتذة) ---
class TeacherApi {
  final DioClient _client = DioClient();
  Future<Map<String, dynamic>> getTeacherStats() async {
    final response = await _client.get("persons/teacher_stats/");
    return response.data;
  }
  // دوال الحلقات المخصصة للمعلم
  Future<List<dynamic>> getMyHalqas() async {
    final response = await _client.get("halqas/my_halqas/");
    return response.data;
  }

  Future<List<dynamic>> getHalqaStudents(int halqaId) async {
    final response = await _client.get("halqas/$halqaId/students/");
    return response.data;
  }

  // تسجيل العمليات
  Future<void> addAttendance(Map<String, dynamic> data) async => await _client.post("attendance/", data: data);
  Future<void> addMemorization(Map<String, dynamic> data) async => await _client.post("memorization/", data: data);
  Future<void> addTest(Map<String, dynamic> data) async => await _client.post("quran-tests/", data: data);
}

// --- (6) Student API ---
class StudentApi {
  final DioClient _client = DioClient();

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get("persons/my_profile/");
    return response.data;
  }

  Future<List<dynamic>> getAttendance(String studentName) async {
    final response = await _client.get("attendance/?search=$studentName");
    return response.data;
  }

  Future<List<dynamic>> getMemorizationSessions(String studentName) async {
    final response = await _client.get("memorization/?search=$studentName");
    return response.data;
  }

  Future<List<dynamic>> getTests(int studentId) async {
    final response = await _client.get("quran-tests/by_student/?student=$studentId");
    return response.data;
  }

  Future<Map<String, dynamic>> getProgress() async {
    final response = await _client.get("progress/my_progress/");
    return response.data;
  }

  // الإشعارات
  Future<List<dynamic>> getNotifications() async {
    final response = await _client.get("notifications/");
    return response.data;
  }

  Future<void> markNotificationRead(int notificationId) async {
    await _client.post("notifications/$notificationId/mark_read/");
  }
}

// --- (7) Guardian API ---
class GuardianApi {
  final DioClient _client = DioClient();

  Future<List<dynamic>> getChildren() async {
    final response = await _client.get("persons/my_children/");
    return response.data;
  }

  Future<Map<String, dynamic>> getChildProfile(int childId) async {
    final response = await _client.get("persons/$childId/");
    return response.data;
  }

  Future<List<dynamic>> getChildTests(int childId) async {
    final response = await _client.get("quran-tests/by_student/?student=$childId");
    return response.data;
  }

  Future<Map<String, dynamic>?> getChildProgress(String childName) async {
    final response = await _client.get("progress/?search=$childName");
    List data = response.data;
    if (data.isNotEmpty) return data.first;
    return null;
  }

  Future<List<dynamic>> getChildAttendance(String childName) async {
    final response = await _client.get("attendance/?search=$childName");
    return response.data;
  }
}