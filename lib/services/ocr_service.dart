import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';
import '../models/delivery_order.dart';

class OcrService extends ChangeNotifier {
  final TextRecognizer _textRecognizer = TextRecognizer();
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  // Properties for settings
  bool _autoDetectFormat = true;
  bool _highAccuracyMode = false;
  int _routeOptimizationLevel = 1;
  List<DeliveryOrder> _lastScannedOrders = [];

  // Getters
  List<DeliveryOrder> get lastScannedOrders => _lastScannedOrders;
  bool get autoDetectFormat => _autoDetectFormat;
  bool get highAccuracyMode => _highAccuracyMode;
  int get routeOptimizationLevel => _routeOptimizationLevel;
  bool get isCameraInitialized => _isCameraInitialized;
  CameraController? get cameraController => _cameraController;

  // Setters
  void setAutoDetectFormat(bool value) {
    _autoDetectFormat = value;
    notifyListeners();
  }

  void setHighAccuracyMode(bool value) {
    _highAccuracyMode = value;
    notifyListeners();
  }

  void setRouteOptimizationLevel(int value) {
    if (value >= 1 && value <= 3) {
      _routeOptimizationLevel = value;
      notifyListeners();
    }
  }

  Future<void> initializeCamera() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();

      // Get the first camera (usually back camera)
      final firstCamera = cameras.first;

      // Create camera controller
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // Initialize controller
      await _cameraController!.initialize();
      _isCameraInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isCameraInitialized = false;
      notifyListeners();
    }
  }

  Future<void> disposeCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
    _isCameraInitialized = false;
    notifyListeners();
  }

  Future<String> processImageFromCamera() async {
    try {
      if (!_isCameraInitialized || _cameraController == null) {
        await initializeCamera();
      }

      if (!_isCameraInitialized || _cameraController == null) {
        return '';
      }

      // Take a picture
      final image = await _cameraController!.takePicture();

      // Create input image from file
      final inputImage = InputImage.fromFilePath(image.path);

      // Process with ML Kit
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      debugPrint('Error processing image: $e');
      return '';
    }
  }

  // Method to process text and create delivery orders
  Future<List<DeliveryOrder>> processText(String text) async {
    try {
      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 500));

      final orders = <DeliveryOrder>[];
      final lines = text.split('\n');
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          orders.add(DeliveryOrder(
            address: line.trim(),
            isAsap: true,
          ));
        }
      }

      _lastScannedOrders = orders;
      notifyListeners();

      return orders;
    } catch (e) {
      debugPrint('Error processing text: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
    disposeCamera();
    super.dispose();
  }
}
