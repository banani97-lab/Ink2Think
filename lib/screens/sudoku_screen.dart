import 'package:flutter/material.dart';
import '../models/sudoku_puzzle.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';

class SudokuScreen extends StatefulWidget {
  final SudokuPuzzle puzzle;

  const SudokuScreen({super.key, required this.puzzle});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  int? selectedRow;
  int? selectedCol;
  bool notesMode = false;
  late SudokuPuzzle puzzle;

  // Notes for each cell (set of possible values)
  late List<List<Set<int>>> notes;

  @override
  void initState() {
    super.initState();
    puzzle = widget.puzzle;
    notes = List.generate(
      9,
      (_) => List.generate(9, (_) => <int>{}),
    );
  }

  void _selectCell(int row, int col) {
    setState(() {
      if (selectedRow == row && selectedCol == col) {
        // Deselect if tapping the same cell
        selectedRow = null;
        selectedCol = null;
      } else {
        selectedRow = row;
        selectedCol = col;
      }
    });
  }

  void _enterNumber(int number) {
    if (selectedRow == null || selectedCol == null) return;
    if (puzzle.isPrefilled(selectedRow!, selectedCol!)) return;

    setState(() {
      if (notesMode) {
        // Toggle note
        if (notes[selectedRow!][selectedCol!].contains(number)) {
          notes[selectedRow!][selectedCol!].remove(number);
        } else {
          notes[selectedRow!][selectedCol!].add(number);
        }
      } else {
        // Enter number and clear notes
        puzzle.setValue(selectedRow!, selectedCol!, number);
        notes[selectedRow!][selectedCol!].clear();

        // Check for completion
        if (puzzle.isComplete()) {
          _showCompletionDialog();
        }
      }
    });
  }

  void _clearCell() {
    if (selectedRow == null || selectedCol == null) return;
    if (puzzle.isPrefilled(selectedRow!, selectedCol!)) return;

    setState(() {
      puzzle.clearCell(selectedRow!, selectedCol!);
      notes[selectedRow!][selectedCol!].clear();
    });
  }

  void _toggleNotesMode() {
    setState(() {
      notesMode = !notesMode;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            SizedBox(width: 8),
            Text('Congratulations!'),
          ],
        ),
        content: const Text('You solved the puzzle!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Home'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                puzzle.reset();
                notes = List.generate(
                  9,
                  (_) => List.generate(9, (_) => <int>{}),
                );
                selectedRow = null;
                selectedCol = null;
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Puzzle?'),
        content: const Text('This will clear all your progress.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                puzzle.reset();
                notes = List.generate(
                  9,
                  (_) => List.generate(9, (_) => <int>{}),
                );
                selectedRow = null;
                selectedCol = null;
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        actions: [
          IconButton(
            onPressed: _showResetDialog,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${puzzle.emptyCellCount} cells remaining',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SudokuGrid(
                      puzzle: puzzle,
                      notes: notes,
                      selectedRow: selectedRow,
                      selectedCol: selectedCol,
                      onCellTap: _selectCell,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: NumberPad(
                onNumberPressed: _enterNumber,
                onClearPressed: _clearCell,
                onNotesToggle: _toggleNotesMode,
                notesMode: notesMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
