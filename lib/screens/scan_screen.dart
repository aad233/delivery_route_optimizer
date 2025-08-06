import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import '../services/ocr_service.dart';
import '../widgets/scan_button.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController; // Make nullable
  Future<void>? _initializeControllerFuture; // Make nullable
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isProcessingImage = false;
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllerFuture =
        _initializeCamera(); // Assign the future directly
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose(); // Use null-aware operator
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed to inactive.
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose(); // Dispose if not null
    } else if (state == AppLifecycleState.resumed) {
      // App state changed to resumed.
      // Reinitialize the camera if it was previously initialized.
      if (_cameraController != null) {
        _initializeControllerFuture = _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Dispose existing controller if any
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!
          .initialize(); // Use ! because we just initialized it

      if (!mounted) {
        return;
      }
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Camera initialization failed: ${e.toString()}')),
      );
      setState(() => _isCameraInitialized = false);
      rethrow; // Re-throw the error so the FutureBuilder can catch it and show the error UI
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) {
      return; // Add null check
    }
    try {
      await _cameraController!.setFlashMode(
        // Use !
        _isFlashOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Camera initialization failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _captureAndProcessImage() async {
    if (!_isCameraInitialized ||
        _isProcessingImage ||
        _cameraController == null) {
      return; // Add null check
    }

    setState(() => _isProcessingImage = true);

    try {
      final image = await _cameraController!.takePicture(); // Use !
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (!mounted) {
        return;
      }

      final ocrService = Provider.of<OcrService>(context, listen: false);
      final orders = ocrService.processText(recognizedText.text);

      Navigator.pop(context, orders);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingImage = false);
      }
    }
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return _buildCameraLoading(); // Or an error widget
    }
    return Stack(
      children: [
        Positioned.fill(
          child: CameraPreview(_cameraController!), // Use !
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _toggleFlash,
          ),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Align receipt within frame',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ScanButton(
                onPressed: _captureAndProcessImage,
                isProcessing: _isProcessingImage,
                size: 80, // Make sure this matches your ScanButton constructor
              ),
            ],
          ),
        ),
        if (_isProcessingImage)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Initializing camera...'),
        ],
      ),
    );
  }

  Widget _buildCameraError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Camera initialization failed',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _initializeCamera,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture, // This can now be null
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return _buildCameraError();
            } else if (_isCameraInitialized &&
                _cameraController != null &&
                _cameraController!.value.isInitialized) {
              return _buildCameraPreview();
            } else {
              // Fallback for unexpected states, perhaps camera not initialized despite no error
              return _buildCameraError();
            }
          } else {
            return _buildCameraLoading();
          }
        },
      ),
    );
  }
}
