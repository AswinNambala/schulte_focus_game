import 'package:flutter_test/flutter_test.dart';
import 'package:schulte_focus/features/game/domain/entities/game_config.dart';
import 'package:schulte_focus/features/game/domain/services/table_generator_service.dart';

void main() {
  group('TableGeneratorService Tests', () {
    test('generates correct number of cells for 5x5 grid', () {
      const config = GameConfig(
        gridSize: 5,
        tableType: TableType.number,
        mode: GameMode.classic,
      );

      final cells = TableGeneratorService.generateCells(config);

      expect(cells.length, 25);
      final values = cells.map((c) => c.value).toSet();
      expect(values.length, 25);
      expect(values.contains(1), true);
      expect(values.contains(25), true);
    });

    test('generates correct letter cells for 3x3 letter grid', () {
      const config = GameConfig(
        gridSize: 3,
        tableType: TableType.letter,
        mode: GameMode.classic,
      );

      final cells = TableGeneratorService.generateCells(config);

      expect(cells.length, 9);
      final textValues = cells.map((c) => c.displayText).toSet();
      expect(textValues.contains('A'), true);
      expect(textValues.contains('I'), true);
    });

    test('generates 36 cells for 6x6 pro grid', () {
      const config = GameConfig(
        gridSize: 6,
        totalCells: 36,
        mode: GameMode.classic,
      );

      final cells = TableGeneratorService.generateCells(config);

      expect(cells.length, 36);
      expect(cells.first.value >= 1 && cells.first.value <= 36, true);
    });

    test('shuffleRemaining keeps completed cells in place and shuffles uncompleted', () {
      const config = GameConfig(
        gridSize: 3,
        totalCells: 9,
        mode: GameMode.classic,
      );

      final cells = TableGeneratorService.generateCells(config);
      // Mark first cell completed
      final completedCell = cells[0].copyWith(isCompleted: true);
      final modifiedCells = [completedCell, ...cells.sublist(1)];

      final reshuffled = TableGeneratorService.shuffleRemaining(modifiedCells);

      expect(reshuffled.length, 9);
      expect(reshuffled[0].isCompleted, true);
      expect(reshuffled[0].id, completedCell.id);
    });
  });
}
