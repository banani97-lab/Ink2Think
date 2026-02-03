import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/sudoku_scanner.dart';
import 'sudoku_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _errorMessage = 'Camera permission is required to scan puzzles';
      });
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _captureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _controller!.takePicture();
      final scanner = SudokuScanner();
      final puzzle = await scanner.scanImage(File(image.path));

      if (puzzle != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SudokuScreen(puzzle: puzzle),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not detect a sudoku puzzle. Try again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Puzzle'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                  _initializeCamera();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_controller!),
        ),
        // Overlay guide
        Positioned.fill(
          child: CustomPaint(
            painter: GridOverlayPainter(),
          ),
        ),
        // Instructions
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Position the sudoku puzzle within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        // Capture button
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _isProcessing ? null : _captureAndProcess,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: _isProcessing ? Colors.grey : Colors.white24,
                ),
                child: _isProcessing
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Icon(
                        Icons.camera,
                        color: Colors.white,
                        size: 40,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GridOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Calculate square area in center
    final squareSize = size.width * 0.85;
    final left = (size.width - squareSize) / 2;
    final top = (size.height - squareSize) / 2;

    // Draw outer rectangle
    canvas.drawRect(
      Rect.fromLTWH(left, top, squareSize, squareSize),
      paint,
    );

    // Draw corner brackets
    final bracketLength = squareSize * 0.1;
    final bracketPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + bracketLength),
      Offset(left, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + bracketLength, top),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + squareSize - bracketLength, top),
      Offset(left + squareSize, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + squareSize, top),
      Offset(left + squareSize, top + bracketLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + squareSize - bracketLength),
      Offset(left, top + squareSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top + squareSize),
      Offset(left + bracketLength, top + squareSize),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + squareSize - bracketLength, top + squareSize),
      Offset(left + squareSize, top + squareSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + squareSize, top + squareSize - bracketLength),
      Offset(left + squareSize, top + squareSize),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
