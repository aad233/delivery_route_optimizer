import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_route_optimizer/screens/home_screen.dart';
import 'package:delivery_route_optimizer/screens/route_screen.dart';
import 'package:delivery_route_optimizer/screens/settings_screen.dart';
import 'package:delivery_route_optimizer/screens/camera_screen.dart';
import 'package:delivery_route_optimizer/screens/order_list_screen.dart';
import 'package:delivery_route_optimizer/services/route_optimizer_service.dart';
import 'package:delivery_route_optimizer/services/ocr_service.dart';
import 'package:delivery_route_optimizer/services/map_service.dart';
import 'package:delivery_route_optimizer/services/geocoding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final mapService = MapService();
  await mapService.initializeMap();

  final geocodingService = GeocodingService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OcrService()),
        ChangeNotifierProvider(
            create: (_) => RouteOptimizerService(geocodingService)),
        ChangeNotifierProvider<MapService>(create: (_) => mapService),
        Provider<GeocodingService>(create: (_) => geocodingService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Route Optimizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // Fixed: HomeScreen should be properly defined
      routes: {
        '/route': (context) => const RouteScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/camera': (context) => const CameraScreen(),
        '/orders': (context) => const OrderListScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
