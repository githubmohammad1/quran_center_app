
import 'package:quran_center_app/services/dio_client.dart';
import '../../data/models/surah_model.dart';
import '../../data/models/page_mapping_model.dart';

class GeneralRepository {
  final GeneralApi _api = GeneralApi();

  Future<List<SurahModel>> getSurahs() async {
    final data = await _api.getSurahs();
    return data.map((e) => SurahModel.fromJson(e)).toList();
  }

  Future<List<PageMappingModel>> getPageMappings() async {
    final data = await _api.getPageMappings();
    return data.map((e) => PageMappingModel.fromJson(e)).toList();
  }
}