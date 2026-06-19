import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce_app/injection_contaner.dart';
import 'package:e_commerce_app/main.dart';

void main() {
  testWidgets('Login screen renders authentication form',
      (WidgetTester tester) async {
    setUpDi();

    await tester.pumpWidget(const MyApp());

    expect(find.text('Dang nhap'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mat khau'), findsOneWidget);
  });
}
