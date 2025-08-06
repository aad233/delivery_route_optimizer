import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isProcessing;
  final double? size;

  const ScanButton({
    super.key,
    required this.onPressed,
    this.isProcessing = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        backgroundColor: isProcessing ? Colors.grey : Colors.red,
        onPressed: isProcessing ? null : onPressed,
        child: isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.camera_alt, size: 32),
      ),
    );
  }
}
