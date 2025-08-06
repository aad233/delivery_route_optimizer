import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:delivery_route_optimizer/services/ocr_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Initialize camera when the screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ocrService = Provider.of<OcrService>(context, listen: false);
      ocrService.initializeCamera();
    });
  }

  @override
  void dispose() {
    // Dispose camera when the screen is disposed
    final ocrService = Provider.of<OcrService>(context, listen: false);
    ocrService.disposeCamera();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final ocrService = Provider.of<OcrService>(context, listen: false);
      final recognizedText = await ocrService.processImageFromCamera();

      if (mounted && recognizedText.isNotEmpty) {
        // Process the recognized text
        await ocrService.processText(recognizedText);

        // Navigate to order list screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/orders');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              // Toggle flash
              final ocrService =
                  Provider.of<OcrService>(context, listen: false);
              if (ocrService.cameraController != null) {
                if (ocrService.cameraController!.value.flashMode ==
                    FlashMode.off) {
                  ocrService.cameraController!.setFlashMode(FlashMode.torch);
                } else {
                  ocrService.cameraController!.setFlashMode(FlashMode.off);
                }
              }
            },
          ),
        ],
      ),
      body: Consumer<OcrService>(
        builder: (context, ocrService, child) {
          if (!ocrService.isCameraInitialized ||
              ocrService.cameraController == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Stack(
            children: [
              // Camera preview
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CameraPreview(ocrService.cameraController!),
              ),

              // Processing overlay
              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Processing...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

              // Capture button
              if (!_isProcessing)
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      onPressed:
                          _captureAndProcess, // Fixed: Now this method is properly referenced
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
