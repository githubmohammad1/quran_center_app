import 'package:flutter_test/flutter_test.dart';
import 'package:quran_center_app/main.dart';

void main() {
  testWidgets('App loads without crashing', (tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
