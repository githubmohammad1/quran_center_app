class JuzHelper {
  // قائمة ثابتة تبدأ برقم أول صفحة في كل جزء (من الجزء 1 إلى الجزء 30)
  // مأخوذة من مصحف المدينة النبوية (604 صفحات)
  static const List<int> juzStartPages = [
    1, 22, 42, 62, 82, 102, 122, 142, 162, 182, // أجزاء 1 - 10
    202, 222, 242, 262, 282, 302, 322, 342, 362, 382, // أجزاء 11 - 20
    402, 422, 442, 462, 482, 502, 522, 542, 562, 582 // أجزاء 21 - 30
  ];

  /// يُدخل رقم الصفحة فيعطيك رقم الجزء (1 إلى 30)
  static int getJuzFromPage(int page) {
    if (page < 1 || page > 604) return 1;
    for (int i = 29; i >= 0; i--) {
      if (page >= juzStartPages[i]) return i + 1;
    }
    return 1;
  }

  /// يُدخل رقم الجزء فيعطيك بداية ونهاية الصفحات لهذا الجزء
  static Map<String, int> getJuzBounds(int juzNumber) {
    if (juzNumber < 1 || juzNumber > 30) juzNumber = 1;
    int start = juzStartPages[juzNumber - 1];
    int end = (juzNumber == 30) ? 604 : juzStartPages[juzNumber] - 1;
    return {"start": start, "end": end};
  }

  /// يُنشئ مصفوفة بأرقام الصفحات لجزء معين (استعداداً لرسم المربعات في الـ UI)
  static List<int> getPagesForJuz(int juzNumber) {
    final bounds = getJuzBounds(juzNumber);
    List<int> pages = [];
    for (int i = bounds['start']!; i <= bounds['end']!; i++) {
      pages.add(i);
    }
    return pages;
  }
}