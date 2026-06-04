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
}
