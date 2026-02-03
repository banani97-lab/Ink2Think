import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import '../models/sudoku_puzzle.dart';

class SudokuScanner {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<SudokuPuzzle?> scanImage(File imageFile) async {
    try {
      // Load and preprocess the image
      final inputImage = InputImage.fromFile(imageFile);

      // Perform text recognition
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract the grid from recognized text
      final grid = await _extractGrid(imageFile, recognizedText);

      if (grid != null && _isValidSudokuGrid(grid)) {
        return SudokuPuzzle.fromGrid(grid);
      }

      return null;
    } catch (e) {
      print('Error scanning image: $e');
      return null;
    }
  }

  Future<List<List<int>>?> _extractGrid(
    File imageFile,
    RecognizedText recognizedText,
  ) async {
    // Load image to get dimensions
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    // Initialize empty grid
    final grid = List.generate(9, (_) => List.filled(9, 0));

    // Find the bounding box of all detected text to estimate grid location
    double minX = imageWidth;
    double minY = imageHeight;
    double maxX = 0;
    double maxY = 0;

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final bbox = line.boundingBox;
        if (bbox.left < minX) minX = bbox.left;
        if (bbox.top < minY) minY = bbox.top;
        if (bbox.right > maxX) maxX = bbox.right;
        if (bbox.bottom > maxY) maxY = bbox.bottom;
      }
    }

    // Calculate cell size based on detected text bounds
    final gridWidth = maxX - minX;
    final gridHeight = maxY - minY;
    final cellWidth = gridWidth / 9;
    final cellHeight = gridHeight / 9;

    // Map each detected digit to a cell
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final text = element.text.trim();

          // Check if it's a single digit 1-9
          if (text.length == 1 && RegExp(r'[1-9]').hasMatch(text)) {
            final digit = int.parse(text);
            final bbox = element.boundingBox;

            // Calculate center of the detected text
            final centerX = (bbox.left + bbox.right) / 2;
            final centerY = (bbox.top + bbox.bottom) / 2;

            // Determine which cell this belongs to
            final col = ((centerX - minX) / cellWidth).floor().clamp(0, 8);
            final row = ((centerY - minY) / cellHeight).floor().clamp(0, 8);

            // Only set if cell is empty (first detection wins)
            if (grid[row][col] == 0) {
              grid[row][col] = digit;
            }
          }
        }
      }
    }

    return grid;
  }

  bool _isValidSudokuGrid(List<List<int>> grid) {
    // Check that we have at least some numbers (typical puzzles have 17-35 clues)
    int filledCells = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell != 0) filledCells++;
      }
    }

    // A valid sudoku needs at least 17 clues to be uniquely solvable
    if (filledCells < 10) {
      return false;
    }

    // Validate no duplicates in rows
    for (int r = 0; r < 9; r++) {
      final seen = <int>{};
      for (int c = 0; c < 9; c++) {
        final val = grid[r][c];
        if (val != 0) {
          if (seen.contains(val)) return false;
          seen.add(val);
        }
      }
    }

    // Validate no duplicates in columns
    for (int c = 0; c < 9; c++) {
      final seen = <int>{};
      for (int r = 0; r < 9; r++) {
        final val = grid[r][c];
        if (val != 0) {
          if (seen.contains(val)) return false;
          seen.add(val);
        }
      }
    }

    // Validate no duplicates in 3x3 boxes
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        final seen = <int>{};
        for (int r = boxRow * 3; r < boxRow * 3 + 3; r++) {
          for (int c = boxCol * 3; c < boxCol * 3 + 3; c++) {
            final val = grid[r][c];
            if (val != 0) {
              if (seen.contains(val)) return false;
              seen.add(val);
            }
          }
        }
      }
    }

    return true;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
