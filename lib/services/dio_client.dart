import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;
  final _storage = const FlutterSecureStorage();

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.1.104:8000/api/",
        // baseUrl: "https://mohammadpythonanywher1.pythonanywhere.com/api/",
        // 🎯 استبدال الـ localhost بالـ IPv4 الحقيقي لجهازك المشترك بنفس الشبكة
          // baseUrl : "http://192.168.1.102:8000/api/",
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




