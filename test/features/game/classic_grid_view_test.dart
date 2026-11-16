import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schulte_focus/features/game/domain/entities/game_cell.dart';
import 'package:schulte_focus/features/game/presentation/widgets/classic_grid_view.dart';

void main() {
  testWidgets('ClassicGridView renders cells and handles tap', (WidgetTester tester) async {
    GameCell? tappedCell;

    final testCells = List.generate(
      9,
      (i) => GameCell(
        id: 'cell_$i',
        value: i + 1,
        displayText: '${i + 1}',
        color: const Color(0xFF6366F1),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClassicGridView(
            gridSize: 3,
            cells: testCells,
            onCellTapped: (cell) {
              tappedCell = cell;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(tappedCell, isNotNull);
    expect(tappedCell!.value, 1);
  });
}
