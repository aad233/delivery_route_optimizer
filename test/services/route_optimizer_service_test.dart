import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_route_optimizer/services/geocoding_service.dart';
import 'package:delivery_route_optimizer/services/route_optimizer_service.dart';
import 'package:delivery_route_optimizer/models/delivery_order.dart';

class MockGeocodingService extends GeocodingService {
  MockGeocodingService() : super(httpClient: null);

  @override
  Future<SimpleCoordinate> getCoordinatesFromAddress(String address) async {
    if (address == 'invalid address') {
      throw Exception('Failed to get coordinates for the address.');
    }
    return SimpleCoordinate(latitude: 51.9244, longitude: 4.4777);
  }
}

void main() {
  group('RouteOptimizerService', () {
    late RouteOptimizerService routeOptimizerService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockGeocodingService = MockGeocodingService();
      routeOptimizerService = RouteOptimizerService(mockGeocodingService);
    });

    test('addOrder geocodes the address and adds the order', () async {
      final order = DeliveryOrder(address: 'some address');
      await routeOptimizerService.addOrder(order);

      expect(routeOptimizerService.orders.length, 1);
      expect(routeOptimizerService.orders.first.latitude, 51.9244);
      expect(routeOptimizerService.orders.first.longitude, 4.4777);
    });

    test('_calculateRouteStats calculates distance and time correctly',
        () async {
      final order1 = DeliveryOrder(
        address: 'address1',
        latitude: 51.9244,
        longitude: 4.4777,
      );
      final order2 = DeliveryOrder(
        address: 'address2',
        latitude: 52.3676,
        longitude: 4.9041,
      );

      routeOptimizerService.setOrders([order1, order2]);

      // optimizeRoute is called by setOrders, which calls _calculateRouteStats
      expect(routeOptimizerService.totalDistance, greaterThan(0));
      expect(routeOptimizerService.estimatedTime, isNot(''));
    });
  });
}
