import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'sudoku_screen.dart';
import '../models/sudoku_puzzle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ink2Think'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.grid_on,
                size: 100,
                color: Colors.indigo,
              ),
              const SizedBox(height: 32),
              const Text(
                'Sudoku Scanner',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan a sudoku puzzle with your camera and play it on your phone',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Puzzle'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(200, 56),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Load a sample puzzle for testing
                  final samplePuzzle = SudokuPuzzle.fromGrid([
                    [5, 3, 0, 0, 7, 0, 0, 0, 0],
                    [6, 0, 0, 1, 9, 5, 0, 0, 0],
                    [0, 9, 8, 0, 0, 0, 0, 6, 0],
                    [8, 0, 0, 0, 6, 0, 0, 0, 3],
                    [4, 0, 0, 8, 0, 3, 0, 0, 1],
                    [7, 0, 0, 0, 2, 0, 0, 0, 6],
                    [0, 6, 0, 0, 0, 0, 2, 8, 0],
                    [0, 0, 0, 4, 1, 9, 0, 0, 5],
                    [0, 0, 0, 0, 8, 0, 0, 7, 9],
                  ]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SudokuScreen(puzzle: samplePuzzle),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Try Sample Puzzle'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
