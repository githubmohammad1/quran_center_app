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
          // 🎯 تحصين جودة: التحقق من أن الخطأ 401 وليس قادماً من مسار تحديث التوكن نفسه لمنع الـ Infinite Loop
          if (error.response?.statusCode == 401 && 
              !error.requestOptions.path.contains("auth/refresh")) {
            
            final refreshed = await _refreshToken();

            if (refreshed) {
              // إعادة إرسال الطلب الأصلي بعد تحديث التوكن بنجاح
              final newToken = await _storage.read(key: "access_token");
              error.requestOptions.headers["Authorization"] = "Bearer $newToken";

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
      // إذا فشل التحديث (انتهت صلاحية الـ Refresh) نمسح البيانات لتوجيه المستخدم لصفحة تسجيل الدخول
      await _storage.deleteAll();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 🚀 تمديد وتوسيع التوابع القياسية لدعم المعاملات (Forwarding Parameters)
  // ---------------------------------------------------------------------------
  
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}