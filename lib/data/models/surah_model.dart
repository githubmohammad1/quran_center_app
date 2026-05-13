class SurahModel {
  final int number;
  final String name;
  final int totalAyahs;

  SurahModel({
    required this.number,
    required this.name,
    required this.totalAyahs,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json["number"],
      name: json["name"],
      totalAyahs: json["total_ayahs"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "number": number,
      "name": name,
      "total_ayahs": totalAyahs,
    };
  }
}
