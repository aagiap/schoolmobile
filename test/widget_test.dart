import 'package:flutter_test/flutter_test.dart';
import 'package:schoolmobile/main.dart';

void main() {
  testWidgets('renders app shell', (tester) async {
    await tester.pumpWidget(const SchoolMobileApp());

    expect(find.text('THPT Hữu Lũng'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
