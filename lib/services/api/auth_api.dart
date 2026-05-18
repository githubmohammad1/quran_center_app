import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quran_center_app/services/dio_client.dart';

class AuthApi {
  final DioClient _client = DioClient();
  final _storage = const FlutterSecureStorage();

  // دالة مساعدة لتوحيد اقتناص أخطاء الـ Django واستخراج الـ Detail بدقة
  Exception _handleDioError(DioException e, String defaultMessage) {
    if (e.response != null && e.response?.data is Map) {
      final backendDetail = e.response?.data['detail'] ?? e.response?.data['error'];
      if (backendDetail != null) {
        return Exception(backendDetail.toString());
      }
    }
    return Exception(defaultMessage);
  }

  // =========================================================================
  // 1. تحديث رمز دفع الإشعارات (FCM Token)
  // =========================================================================
  Future<void> updateFcmToken(String token) async {
    try {
      await _client.post(
        "auth/update-fcm/",
        data: {"fcm_token": token},
      );
    } on DioException catch (e) {
      throw _handleDioError(e, "فشل في تحديث رمز الإشعارات المزامن.");
    }
  }

  // =========================================================================
  // 2. تسجيل الدخول ودعم تعدديّة الأدوار
  // =========================================================================
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _client.post(
        "auth/login/",
        data: {"phone": phone, "password": password},
      );
      final data = response.data;

      // تدقيق أمني منطقي: الباك إند يرجع ماب تحتوي على بيانات المستخدم وأدواره المتعددة
      if (data["user"] == null) {
        throw Exception("الحساب المسجل لا يملك ملفاً شخصياً نشطاً.");
      }

      // حفظ التوكنات محلياً بشكل آمن
      await _storage.write(key: "access_token", value: data["access"]);
      await _storage.write(key: "refresh_token", value: data["refresh"]);

      // إرجاع ماب بيانات الـ User (والتي تحتوي على الـ profiles أو الأدوار المدمجة)
      return data["user"] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, "بيانات الدخول غير صحيحة، يرجى التحقق وإعادة المحاولة.");
    }
  }

  // =========================================================================
  // 3. تسجيل الخروج وتصفير السجلات المحلية
  // =========================================================================
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: "refresh_token");
      if (refreshToken != null) {
        // إعلام الباك إند لإدراج التوكن في القائمة السوداء (Blacklist Token) لضمان الأمان
        await _client.post("auth/logout/", data: {"refresh": refreshToken}).catchError((_) {
          // نتجاوز خطأ الشبكة هنا لضمان إتمام الحذف المحلي في كل الأحوال
          return Response(requestOptions: RequestOptions(path: ''));
        });
      }
    } finally {
      // تنظيف الخزن الآمن تماماً عند الخروج
      await _storage.deleteAll();
    }
  }

  // =========================================================================
  // 4. تغيير كلمة المرور للمستخدم الحالي
  // =========================================================================
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _client.post(
        "auth/change-password/",
        data: {"old_password": oldPassword, "new_password": newPassword},
      );
    } on DioException catch (e) {
      throw _handleDioError(e, "فشل تغيير كلمة المرور، تحقق من الحقول المدخلة.");
    }
  }

  // =========================================================================
  // 5. تحديث التوكن التلقائي (Token Refresh Lifecycle)
  // =========================================================================
  Future<String?> refreshToken() async {
    try {
      final refresh = await _storage.read(key: "refresh_token");
      if (refresh == null) return null;

      // كسر الحلقة التكرارية: نستخدم مثيل كائن دايو منفصل وخفيف لتحديث التوكن
      // لكي لا يمر بـ Interceptor الـ DioClient المعتاد ويتسبب في Loop عند انتهاء الصلاحية المتزامن
      final dioRefresh = Dio(BaseOptions(
        baseUrl: "https://mohammadpythonanywher1.pythonanywhere.com/api/",
        connectTimeout: const Duration(seconds: 10),
      ));

      final response = await dioRefresh.post("auth/refresh/", data: {"refresh": refresh});
      final newAccess = response.data["access"];
      
      await _storage.write(key: "access_token", value: newAccess);
      return newAccess;
    } catch (e) {
      // في حال فشل التحديث (التوكن منتهي تماماً أو تم حذفه من السيرفر) يتم مسح السجلات وإجبار المستخدم على تسجيل الدخول
      await _storage.deleteAll();
      return null;
    }
  }
}