import 'package:flutter/material.dart';
import '../../data/models/surah_model.dart';
import '../../data/models/page_mapping_model.dart';
import '../../data/repositories/general_repository.dart';
class GeneralProvider extends ChangeNotifier {
  final GeneralRepository _repo = GeneralRepository();

  List<SurahModel> surahs = [];
  List<PageMappingModel> pageMappings = [];

  bool loadingSurahs = false;
  bool loadingPages = false;
  String? error;

  Future<void> loadGeneralData() async {
    try {
      loadingSurahs = true;
      loadingPages = true;
      notifyListeners();

      surahs = await _repo.getSurahs();
      pageMappings = await _repo.getPageMappings();

    } catch (e) {
      error = e.toString();
    } finally {
      loadingSurahs = false;
      loadingPages = false;
      notifyListeners();
    }
  }

  Future<void> loadPageMappings() async {
    try {
      loadingPages = true;
      notifyListeners();

      pageMappings = await _repo.getPageMappings();

    } catch (e) {
      error = e.toString();
    } finally {
      loadingPages = false;
      notifyListeners();
    }
  }
}
