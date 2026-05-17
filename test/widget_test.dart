import 'package:flutter_test/flutter_test.dart';
import 'package:quran_center_app/main.dart';

void main() {
  testWidgets('App loads without crashing', (tester) async {
    await tester.pumpWidget(QuranCenterApp());
    expect(find.byType(QuranCenterApp), findsOneWidget);
  });
}
