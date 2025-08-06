import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delivery_route_optimizer/services/route_optimizer_service.dart';

class MapService extends ChangeNotifier {
  Widget mapWidget = const Center(child: Text('Map will be displayed here'));

  Future<void> initializeMap() async {
    mapWidget = const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 100),
          SizedBox(height: 20),
          Text('Map View'),
        ],
      ),
    );

    notifyListeners();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<PointLatLng>> getRouteBetweenCoordinates(
      PointLatLng start, PointLatLng end) async {
    // Changed from LatLng to PointLatLng (from flutter_polyline_points)
    // In a real app, you would use the PolylinePoints package to get route points
    // For now, return an empty list
    return [];
  }

  Future<void> startNavigation(RouteOptimizerService routeOptimizer) async {
    try {
      final Position position = await getCurrentLocation();
      final origin = '${position.latitude},${position.longitude}';

      // Filter out restaurant addresses for navigation
      final deliveryAddresses = routeOptimizer.optimizedRoute
          .where((order) =>
              order.address != RouteOptimizerService.restaurantAddress)
          .toList();

      if (deliveryAddresses.isEmpty) {
        throw Exception('No delivery destinations available');
      }

      // Build waypoints string (all delivery points except the last one)
      final waypoints = deliveryAddresses
          .take(deliveryAddresses.length - 1)
          .map((delivery) => Uri.encodeComponent(delivery.address))
          .join('|');

      // Final destination is the last delivery point
      final destination = Uri.encodeComponent(deliveryAddresses.last.address);

      // Construct Google Maps URL
      String url = 'https://www.google.com/maps/dir/?api=1'
          '&origin=$origin'
          '&destination=$destination';

      // Add waypoints if there are any
      if (waypoints.isNotEmpty) {
        url += '&waypoints=$waypoints';
      }

      url += '&travelmode=driving';

      // Launch the URL
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch Google Maps');
      }
    } catch (e) {
      debugPrint('Error launching navigation: $e');
      rethrow;
    }
  }
}
