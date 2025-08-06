import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// Removed: import 'package:provider/provider.dart';
// Removed: import '../services/map_service.dart'; // Keep if getCoordinates is still needed for ordering
import '../models/delivery_order.dart'; // Added import for DeliveryOrder

class RouteMap extends StatefulWidget {
  final List<DeliveryOrder> orders;
  final Function(Uri)?
      onMapUrlGenerated; // Callback to provide the generated URL
  final bool interactive;

  const RouteMap({
    super.key,
    required this.orders,
    this.onMapUrlGenerated,
    this.interactive = true,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  Future<void> _openExternalMap() async {
    if (widget.orders.isEmpty) return;

    // Use only the first address as the destination
    final order = widget.orders.first;
    final encodedAddress = Uri.encodeComponent(order.address);
    final geoUrl = Uri.parse(
        'geo:0,0?q=$encodedAddress'); // Default to 0,0 if geocoding fails

    if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl);
      if (widget.onMapUrlGenerated != null) {
        widget.onMapUrlGenerated!(geoUrl);
      }
    } else {
      // Handle error: could not launch URL
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Could not open map. Please ensure Google Maps is installed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We are no longer displaying an embedded map.
    // Instead, we provide a button to open the route in an external map application.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _openExternalMap,
          child: const Text('Open Route in Google Maps'),
        ),
      ),
    );
  }
}
