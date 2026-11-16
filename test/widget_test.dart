import 'package:flutter_test/flutter_test.dart';
import 'package:schulte_focus/core/di/injection.dart' as di;
import 'package:schulte_focus/main.dart';

void main() {
  setUp(() async {
    await di.initDependencies();
  });

  tearDown(() async {
    await di.sl.reset();
  });

  testWidgets('App renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SchulteFocusApp());
    expect(find.byType(SchulteFocusApp), findsOneWidget);
  });
}
