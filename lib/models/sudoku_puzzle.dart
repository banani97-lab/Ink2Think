class SudokuPuzzle {
  // The original puzzle (0 = empty cell)
  final List<List<int>> original;

  // The current state (player's progress)
  final List<List<int>> current;

  // Track which cells are pre-filled (cannot be edited)
  final List<List<bool>> prefilled;

  SudokuPuzzle._({
    required this.original,
    required this.current,
    required this.prefilled,
  });

  factory SudokuPuzzle.fromGrid(List<List<int>> grid) {
    final original = List.generate(
      9,
      (i) => List.generate(9, (j) => grid[i][j]),
    );
    final current = List.generate(
      9,
      (i) => List.generate(9, (j) => grid[i][j]),
    );
    final prefilled = List.generate(
      9,
      (i) => List.generate(9, (j) => grid[i][j] != 0),
    );
    return SudokuPuzzle._(
      original: original,
      current: current,
      prefilled: prefilled,
    );
  }

  factory SudokuPuzzle.empty() {
    return SudokuPuzzle.fromGrid(
      List.generate(9, (_) => List.generate(9, (_) => 0)),
    );
  }

  bool isPrefilled(int row, int col) => prefilled[row][col];

  int getValue(int row, int col) => current[row][col];

  void setValue(int row, int col, int value) {
    if (!prefilled[row][col]) {
      current[row][col] = value;
    }
  }

  void clearCell(int row, int col) {
    if (!prefilled[row][col]) {
      current[row][col] = 0;
    }
  }

  bool isCellEmpty(int row, int col) => current[row][col] == 0;

  // Check if a value at position conflicts with sudoku rules
  bool hasConflict(int row, int col) {
    final value = current[row][col];
    if (value == 0) return false;

    // Check row
    for (int c = 0; c < 9; c++) {
      if (c != col && current[row][c] == value) return true;
    }

    // Check column
    for (int r = 0; r < 9; r++) {
      if (r != row && current[r][col] == value) return true;
    }

    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (r != row && c != col && current[r][c] == value) return true;
      }
    }

    return false;
  }

  // Check if the puzzle is complete and valid
  bool isComplete() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (current[r][c] == 0 || hasConflict(r, c)) {
          return false;
        }
      }
    }
    return true;
  }

  // Check if the puzzle is filled (may have errors)
  bool isFilled() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (current[r][c] == 0) return false;
      }
    }
    return true;
  }

  // Reset to original state
  void reset() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        current[r][c] = original[r][c];
      }
    }
  }

  // Get count of empty cells
  int get emptyCellCount {
    int count = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (current[r][c] == 0) count++;
      }
    }
    return count;
  }
}
