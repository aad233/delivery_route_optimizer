import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ocr_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ocrService = Provider.of<OcrService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          const Text(
            'OCR Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Auto-detect receipt format'),
            value: ocrService.autoDetectFormat,
            onChanged: (value) {
              ocrService.setAutoDetectFormat(value);
            },
          ),
          SwitchListTile(
            title: const Text('Use high-accuracy mode'),
            subtitle: const Text('Slower but more accurate'),
            value: ocrService.highAccuracyMode,
            onChanged: (value) {
              ocrService.setHighAccuracyMode(value);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Route Optimization',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Slider(
            value: ocrService.routeOptimizationLevel.toDouble(),
            min: 0,
            max: 2,
            divisions: 2,
            label: ocrService.routeOptimizationLevel == 0
                ? 'Basic'
                : ocrService.routeOptimizationLevel == 1
                    ? 'Balanced'
                    : 'Advanced',
            onChanged: (value) {
              ocrService.setRouteOptimizationLevel(value.toInt());
            },
          ),
        ],
      ),
    );
  }
}
