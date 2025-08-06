import 'package:flutter/foundation.dart';
import '../models/delivery_order.dart';

class RouteOptimizerService extends ChangeNotifier {
  static const String restaurantAddress =
      'Wolphaertsbocht 276A, 3081 KR Rotterdam';
  static const String restaurantPostal = '3081KR';

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

  void addOrder(DeliveryOrder order) {
    _orders.add(order);
    optimizeRoute();
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
              const Duration(minutes: 45)) {
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
    if (referencePostal.length < 4) return [];
    return orders.where((order) {
      final orderPostal = order.postalCode ?? '';
      return orderPostal.length >= 4 &&
          orderPostal.substring(0, 2) == referencePostal.substring(0, 2);
    }).toList();
  }

  void _calculateRouteStats() {
    // Mock distance and time calculation
    _totalDistance = _optimizedRoute.length * 5.2;
    _estimatedTime = '${(_optimizedRoute.length * 15).toString()} minutes';
  }

  // New method to update priority and reorder
  void updatePriority(int index, double priority) {
    if (index < _optimizedRoute.length) {
      // Skip restaurant addresses
      if (_optimizedRoute[index].address == restaurantAddress) return;

      // Create a new list with updated priority
      final updatedOrder = _optimizedRoute[index].copyWithPriority(priority);
      _optimizedRoute[index] = updatedOrder;

      // Reorder based on priority while respecting time constraints
      _reorderByPriority();
      notifyListeners();
    }
  }

  void _reorderByPriority() {
    // Create a new list for the reordered route
    final newRoute = <DeliveryOrder>[];

    // Keep track of which orders we've already added
    final addedIndices = <int>{}; // Fixed: Changed from Set<bool> to Set<int>

    // First, add all restaurant stops in their original positions
    for (int i = 0; i < _optimizedRoute.length; i++) {
      if (_optimizedRoute[i].address == restaurantAddress) {
        newRoute.add(_optimizedRoute[i]);
        addedIndices.add(i); // Fixed: Now adding int instead of bool
      }
    }

    // Then, add time-specific orders in their original order
    for (int i = 0; i < _optimizedRoute.length; i++) {
      if (!addedIndices.contains(i) &&
          _optimizedRoute[i].deliveryTime != null) {
        newRoute.add(_optimizedRoute[i]);
        addedIndices.add(i); // Fixed: Now adding int instead of bool
      }
    }

    // Finally, add ASAP orders sorted by priority (highest first)
    final asapOrders = <DeliveryOrder>[];
    for (int i = 0; i < _optimizedRoute.length; i++) {
      if (!addedIndices.contains(i) && _optimizedRoute[i].isAsap) {
        asapOrders.add(_optimizedRoute[i]);
      }
    }

    // Sort ASAP orders by priority (descending)
    asapOrders.sort((a, b) => b.priority.compareTo(a.priority));

    // Add the sorted ASAP orders to the new route
    newRoute.addAll(asapOrders);

    _optimizedRoute = newRoute;
  }

  // Reset all priorities to default
  void resetPriorities() {
    for (int i = 0; i < _optimizedRoute.length; i++) {
      if (_optimizedRoute[i].address != restaurantAddress) {
        _optimizedRoute[i] = _optimizedRoute[i].copyWithPriority(0.5);
      }
    }
    optimizeRoute();
  }
}
