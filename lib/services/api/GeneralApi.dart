import 'package:quran_center_app/services/dio_client.dart';

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

  /// 🚀 التابع المطور: جلب بيانات لوحة الصدارة والالتزام ديناميكياً
  /// 
  /// [period] يحدد النطاق الزمني: 'daily', 'weekly', 'monthly', 'semester'
  /// [metric] يحدد معيار الفرز: 'pages', 'points', 'excellent', 'very_good'
  /// [scope] يحدد النطاق الإداري: 'global' (عام للكل) أو 'my_halqa' (خاص بطلاب المعلم)
  Future<Map<String, dynamic>> getLeaderboard({
    String period = 'weekly',
    String metric = 'pages',
    String scope = 'global',
  }) async {
    // إرسال الطلب مع تمرير الفلاتر عبر الـ Query Parameters تماشياً مع معايير RESTful APIs
    final response = await _client.get(
      "leaderboard/",
      queryParameters: {
        'period': period,
        'metric': metric,
        'scope': scope,
      },
    );
    
    // الاستجابة تعيد Map يحتوي على الميتا-داتا ومصفوفة الطلاب تحت مفتاح 'leaderboard'
    return response.data as Map<String, dynamic>;
  }
}