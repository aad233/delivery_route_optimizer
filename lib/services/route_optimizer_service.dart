import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/delivery_order.dart';
import 'geocoding_service.dart';

class RouteOptimizerService extends ChangeNotifier {
  static const String restaurantAddress =
      'Wolphaertsbocht 276A, 3081 KR Rotterdam';
  static const String restaurantPostal = '3081KR';

  static const Duration _maxTimeBetweenOrders = Duration(minutes: 45);
  static const int _minutesPerKm = 5;
  static const int _minutesPerStop = 5;
  static const int _minPostalCodeLength = 4;
  static const int _postalCodePrefixLength = 2;

  List<DeliveryOrder> _orders = [];
  List<DeliveryOrder> _optimizedRoute = [];
  double _totalDistance = 0.0;
  String _estimatedTime = '';

  List<DeliveryOrder> get orders => _orders;
  List<DeliveryOrder> get optimizedRoute => _optimizedRoute;
  double get totalDistance => _totalDistance;
  String get estimatedTime => _estimatedTime;

  void setOrders(List<DeliveryOrder> orders) {
    _orders = orders;
    optimizeRoute();
  }

  Future<void> addOrder(DeliveryOrder order) async {
    try {
      final coords =
          await _geocodingService.getCoordinatesFromAddress(order.address);
      final newOrder = order.copyWith(
        latitude: coords.latitude,
        longitude: coords.longitude,
      );
      _orders.add(newOrder);
      optimizeRoute();
    } catch (e) {
      // Handle geocoding errors, e.g., by showing a message to the user
      debugPrint('Error adding order: $e');
      // Optionally, rethrow the exception to be caught by the UI
      rethrow;
    }
  }

  void removeOrder(int index) {
    if (index < _orders.length) {
      _orders.removeAt(index);
      optimizeRoute();
    }
  }

  void optimizeRoute() {
    _optimizedRoute = _optimizeRoute(_orders);
    _calculateRouteStats();
    notifyListeners();
  }

  List<DeliveryOrder> _optimizeRoute(List<DeliveryOrder> orders) {
    // Separate time-specific and ASAP orders
    final timeSpecificOrders = orders
        .where((order) => order.deliveryTime != null)
        .toList()
      ..sort((a, b) => a.deliveryTime!.compareTo(b.deliveryTime!));
    final asapOrders = orders.where((order) => order.isAsap).toList();

    // Group orders into runs based on time windows
    final List<List<DeliveryOrder>> runs = [];
    List<DeliveryOrder> currentRun = [];

    for (final order in timeSpecificOrders) {
      // Check if we need to start a new run
      if (currentRun.isNotEmpty &&
          order.deliveryTime!.difference(currentRun.last.deliveryTime!) >
              _maxTimeBetweenOrders) {
        runs.add(_finalizeRun(currentRun));
        currentRun = [];
      }
      currentRun.add(order);

      // Add nearby ASAP orders
      final nearbyAsap = _findNearbyOrders(asapOrders, order.postalCode ?? '');
      currentRun.addAll(nearbyAsap);
      asapOrders.removeWhere((o) => nearbyAsap.contains(o));
    }

    // Add remaining ASAP orders
    if (asapOrders.isNotEmpty) {
      currentRun.addAll(asapOrders);
    }

    if (currentRun.isNotEmpty) {
      runs.add(_finalizeRun(currentRun));
    }

    return runs.expand((run) => run).toList();
  }

  List<DeliveryOrder> _finalizeRun(List<DeliveryOrder> orders) {
    // Sort ASAP orders by postal code proximity
    final asapOrders = orders.where((o) => o.isAsap).toList()
      ..sort((a, b) => (a.postalCode ?? '').compareTo(b.postalCode ?? ''));

    return [
      DeliveryOrder(
        address: restaurantAddress,
        postalCode: restaurantPostal,
      ),
      ...orders.where((o) => !o.isAsap),
      ...asapOrders,
      DeliveryOrder(
        address: restaurantAddress,
        postalCode: restaurantPostal,
      ),
    ];
  }

  List<DeliveryOrder> _findNearbyOrders(
      List<DeliveryOrder> orders, String referencePostal) {
    if (referencePostal.length < _minPostalCodeLength) return [];
    return orders.where((order) {
      final orderPostal = order.postalCode ?? '';
      return orderPostal.length >= _minPostalCodeLength &&
          orderPostal.substring(0, _postalCodePrefixLength) ==
              referencePostal.substring(0, _postalCodePrefixLength);
    }).toList();
  }

  void _calculateRouteStats() {
    double totalDistance = 0.0;
    for (int i = 0; i < _optimizedRoute.length - 1; i++) {
      final from = _optimizedRoute[i];
      final to = _optimizedRoute[i + 1];

      if (from.latitude != null &&
          from.longitude != null &&
          to.latitude != null &&
          to.longitude != null) {
        totalDistance += Geolocator.distanceBetween(
          from.latitude!,
          from.longitude!,
          to.latitude!,
          to.longitude!,
        );
      }
    }
    _totalDistance = totalDistance / 1000; // Convert to km

    // Simple time estimation: 5 minutes per km + 5 minutes per stop
    final totalTime =
        (_totalDistance * _minutesPerKm) + (_optimizedRoute.length * _minutesPerStop);
    _estimatedTime = '${totalTime.round()} minutes';
  }

  final GeocodingService _geocodingService;

  RouteOptimizerService(this._geocodingService);
  // New method to update priority and reorder
  void updatePriority(int index, double priority) {
    if (index < _optimizedRoute.length) {
      // Skip restaurant addresses
      if (_optimizedRoute[index].address == restaurantAddress) return;

      // Create a new list with updated priority
      final updatedOrder = _optimizedRoute[index].copyWith(priority: priority);
      _optimizedRoute[index] = updatedOrder;

      // Reorder based on priority while respecting time constraints
      _reorderByPriority();
      notifyListeners();
    }
  }

  void _reorderByPriority() {
    final newOptimizedRoute = <DeliveryOrder>[];
    List<DeliveryOrder> currentRunAsapOrders = [];
    List<DeliveryOrder> currentRunTimeSpecificOrders = [];

    for (int i = 0; i < _optimizedRoute.length; i++) {
      final order = _optimizedRoute[i];

      if (order.address == restaurantAddress) {
        if (currentRunTimeSpecificOrders.isNotEmpty ||
            currentRunAsapOrders.isNotEmpty) {
          // This is the end of a run.
          // Sort ASAP orders.
          currentRunAsapOrders.sort((a, b) => b.priority.compareTo(a.priority));
          // Add time-specific orders first, then sorted ASAP orders.
          newOptimizedRoute.addAll(currentRunTimeSpecificOrders);
          newOptimizedRoute.addAll(currentRunAsapOrders);

          // Reset buffers.
          currentRunTimeSpecificOrders = [];
          currentRunAsapOrders = [];
        }
        // Add the restaurant stop.
        newOptimizedRoute.add(order);
      } else if (order.isAsap) {
        currentRunAsapOrders.add(order);
      } else { // Time-specific
        currentRunTimeSpecificOrders.add(order);
      }
    }

    // Add any remaining orders if the route doesn't end with a restaurant.
    if (currentRunTimeSpecificOrders.isNotEmpty ||
        currentRunAsapOrders.isNotEmpty) {
      currentRunAsapOrders.sort((a, b) => b.priority.compareTo(a.priority));
      newOptimizedRoute.addAll(currentRunTimeSpecificOrders);
      newOptimizedRoute.addAll(currentRunAsapOrders);
    }

    _optimizedRoute = newOptimizedRoute;
  }

  // Reset all priorities to default
  void resetPriorities() {
    for (int i = 0; i < _optimizedRoute.length; i++) {
      if (_optimizedRoute[i].address != restaurantAddress) {
        _optimizedRoute[i] = _optimizedRoute[i].copyWith(priority: 0.5);
      }
    }
    optimizeRoute();
  }
}
