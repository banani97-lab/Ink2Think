import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onNotesToggle;
  final bool notesMode;

  const NumberPad({
    super.key,
    required this.onNumberPressed,
    required this.onClearPressed,
    required this.onNotesToggle,
    required this.notesMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Number buttons 1-9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(9, (index) {
            final number = index + 1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: FilledButton.tonal(
                    onPressed: () => onNumberPressed(number),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      number.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: OutlinedButton.icon(
                  onPressed: onClearPressed,
                  icon: const Icon(Icons.backspace_outlined),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: notesMode
                    ? FilledButton.icon(
                        onPressed: onNotesToggle,
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Notes'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: onNotesToggle,
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Notes'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
