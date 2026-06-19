import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce_app/main.dart';

void main() {
  testWidgets('Log up screen renders registration form',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Tao tai khoan'), findsOneWidget);
    expect(find.text('Dang ky'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });
}
