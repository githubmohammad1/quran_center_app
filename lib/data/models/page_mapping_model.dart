import 'surah_model.dart';

class PageMappingModel {
  final int pageNumber;
  final SurahModel surah;
  final int ayahFrom;
  final int ayahTo;

  PageMappingModel({
    required this.pageNumber,
    required this.surah,
    required this.ayahFrom,
    required this.ayahTo,
  });

  factory PageMappingModel.fromJson(Map<String, dynamic> json) {
    return PageMappingModel(
      pageNumber: json["page_number"],
      surah: SurahModel.fromJson(json["surah"]),
      ayahFrom: json["ayah_from"],
      ayahTo: json["ayah_to"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "page_number": pageNumber,
      "surah": surah.toJson(),
      "ayah_from": ayahFrom,
      "ayah_to": ayahTo,
    };
  }
}
