import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schulte_focus/features/game/domain/entities/game_cell.dart';
import 'package:schulte_focus/features/game/presentation/widgets/circular_3d_view.dart';

void main() {
  testWidgets('Circular3DView renders cells in 3D circular rings and handles tap',
      (WidgetTester tester) async {
    GameCell? tappedCell;

    final testCells = [
      const GameCell(
        id: 'c_1',
        value: 1,
        displayText: '1',
        color: Color(0xFF6366F1),
        ringIndex: 0,
        polarAngle: 0.0,
      ),
      const GameCell(
        id: 'c_2',
        value: 2,
        displayText: '2',
        color: Color(0xFF10B981),
        ringIndex: 1,
        polarAngle: 3.14,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Circular3DView(
            cells: testCells,
            ringCount: 2,
            autoRotation: false,
            onCellTapped: (cell) {
              tappedCell = cell;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(tappedCell, isNotNull);
    expect(tappedCell!.value, 1);
  });
}
