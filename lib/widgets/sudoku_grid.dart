import 'package:flutter/material.dart';
import '../models/sudoku_puzzle.dart';

class SudokuGrid extends StatelessWidget {
  final SudokuPuzzle puzzle;
  final List<List<Set<int>>> notes;
  final int? selectedRow;
  final int? selectedCol;
  final Function(int row, int col) onCellTap;

  const SudokuGrid({
    super.key,
    required this.puzzle,
    required this.notes,
    required this.selectedRow,
    required this.selectedCol,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline, width: 2),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          final row = index ~/ 9;
          final col = index % 9;
          return _buildCell(context, row, col);
        },
      ),
    );
  }

  Widget _buildCell(BuildContext context, int row, int col) {
    final colorScheme = Theme.of(context).colorScheme;
    final value = puzzle.getValue(row, col);
    final isPrefilled = puzzle.isPrefilled(row, col);
    final isSelected = row == selectedRow && col == selectedCol;
    final hasConflict = puzzle.hasConflict(row, col);
    final cellNotes = notes[row][col];

    // Highlight cells in same row, column, or box as selected
    final isHighlighted = selectedRow != null &&
        selectedCol != null &&
        (row == selectedRow ||
            col == selectedCol ||
            ((row ~/ 3) == (selectedRow! ~/ 3) &&
                (col ~/ 3) == (selectedCol! ~/ 3)));

    // Highlight cells with same number as selected
    final selectedValue =
        selectedRow != null && selectedCol != null
            ? puzzle.getValue(selectedRow!, selectedCol!)
            : 0;
    final hasSameValue = value != 0 && value == selectedValue;

    // Determine cell background color
    Color backgroundColor;
    if (isSelected) {
      backgroundColor = colorScheme.primaryContainer;
    } else if (hasSameValue) {
      backgroundColor = colorScheme.tertiaryContainer.withOpacity(0.5);
    } else if (isHighlighted) {
      backgroundColor = colorScheme.surfaceContainerHighest.withOpacity(0.5);
    } else {
      backgroundColor = colorScheme.surface;
    }

    // Determine border widths for 3x3 box separation
    final rightBorder = (col == 2 || col == 5) ? 2.0 : 0.5;
    final bottomBorder = (row == 2 || row == 5) ? 2.0 : 0.5;

    return GestureDetector(
      onTap: () => onCellTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            right: BorderSide(color: colorScheme.outline, width: rightBorder),
            bottom: BorderSide(color: colorScheme.outline, width: bottomBorder),
          ),
        ),
        child: Center(
          child: value != 0
              ? Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        isPrefilled ? FontWeight.bold : FontWeight.normal,
                    color: hasConflict
                        ? colorScheme.error
                        : isPrefilled
                            ? colorScheme.onSurface
                            : colorScheme.primary,
                  ),
                )
              : _buildNotes(context, cellNotes),
        ),
      ),
    );
  }

  Widget _buildNotes(BuildContext context, Set<int> cellNotes) {
    if (cellNotes.isEmpty) return const SizedBox();

    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final noteNumber = index + 1;
        final hasNote = cellNotes.contains(noteNumber);
        return Center(
          child: Text(
            hasNote ? noteNumber.toString() : '',
            style: TextStyle(
              fontSize: 9,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
