import 'package:flutter/material.dart';
import '../../data/models/surah_model.dart';
import '../../data/models/page_mapping_model.dart';
import '../../data/repositories/general_repository.dart';

class GeneralProvider extends ChangeNotifier {
  final GeneralRepository _repo = GeneralRepository();

  List<SurahModel> surahs = [];
  List<PageMappingModel> pageMappings = [];

  bool loading = false;
  String? error;

  Future<void> loadGeneralData() async {
    // إذا كانت محملة مسبقاً لا داعي لتحميلها مجدداً
    if (surahs.isNotEmpty && pageMappings.isNotEmpty) return;

    try {
      loading = true;
      error = null;
      notifyListeners();

      final results = await Future.wait([
        _repo.getSurahs(),
        _repo.getPageMappings(),
      ]);

      surahs = results[0] as List<SurahModel>;
      pageMappings = results[1] as List<PageMappingModel>;

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }
}