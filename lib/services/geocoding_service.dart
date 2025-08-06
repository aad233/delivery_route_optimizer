import 'dart:convert';
import 'package:http/http.dart' as http;

// Define SimpleCoordinate class
class SimpleCoordinate {
  final double latitude;
  final double longitude;

  SimpleCoordinate({required this.latitude, required this.longitude});
}

class GeocodingService {
  final String _baseUrl = 'https://nominatim.openstreetmap.org/search';
  final http.Client? _httpClient;

  GeocodingService({http.Client? httpClient}) : _httpClient = httpClient;

  Future<SimpleCoordinate> getCoordinatesFromAddress(String address) async {
    final url = Uri.parse('$_baseUrl?q=$address&format=json&limit=1');

    try {
      final client = _httpClient ?? http.Client();
      final response = await client.get(url, headers: {
        'User-Agent': 'DeliveryRouteOptimizer/1.0',
      });

      if (response.statusCode == 200) {
        final results = json.decode(response.body);
        if (results.isNotEmpty) {
          final lat = double.parse(results[0]['lat']);
          final lon = double.parse(results[0]['lon']);
          return SimpleCoordinate(latitude: lat, longitude: lon);
        }
      }
      // Return a default coordinate or throw an exception if address not found
      throw Exception('Failed to get coordinates for the address.');
    } catch (e) {
      // Handle exceptions like no internet connection
      throw Exception('Failed to get coordinates: $e');
    }
  }

  // This method is redundant as getCoordinatesFromAddress serves the same purpose.
  // It was likely a fix for a previous issue, but it's better to call
  // getCoordinatesFromAddress directly.
  // Future<SimpleCoordinate> getCoordinates(String address) async {
  //   return getCoordinatesFromAddress(address);
  // }
}
