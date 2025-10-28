import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:delivery_route_optimizer/services/geocoding_service.dart';

void main() {
  group('GeocodingService', () {
    test('returns coordinates for a valid address', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '[{"lat": "51.9244", "lon": "4.4777"}]',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final geocodingService = GeocodingService(httpClient: mockClient);

      final coordinates =
          await geocodingService.getCoordinatesFromAddress('some address');

      expect(coordinates.latitude, 51.9244);
      expect(coordinates.longitude, 4.4777);
    });

    test('throws an exception for an invalid address', () async {
      final mockClient = MockClient((request) async {
        return http.Response('[]', 200);
      });

      final geocodingService = GeocodingService(httpClient: mockClient);

      expect(
        () async =>
            await geocodingService.getCoordinatesFromAddress('invalid address'),
        throwsException,
      );
    });

    test('throws an exception for a network error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final geocodingService = GeocodingService(httpClient: mockClient);

      expect(
        () async =>
            await geocodingService.getCoordinatesFromAddress('any address'),
        throwsException,
      );
    });
  });
}
