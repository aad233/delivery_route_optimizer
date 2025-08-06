import 'delivery_order.dart'; // Add this at the top

class DeliveryRun {
  final List<DeliveryOrder> orders;
  final DateTime startTime;
  final DateTime? estimatedEndTime;

  DeliveryRun({
    required this.orders,
    required this.startTime,
    this.estimatedEndTime,
  });

  int get orderCount => orders.length;

  Duration? get estimatedDuration => estimatedEndTime?.difference(startTime);

  factory DeliveryRun.fromJson(Map<String, dynamic> json) {
    return DeliveryRun(
      orders: (json['orders'] as List)
          .map((order) => DeliveryOrder.fromJson(order))
          .toList(),
      startTime: DateTime.parse(json['startTime']),
      estimatedEndTime: json['estimatedEndTime'] != null
          ? DateTime.parse(json['estimatedEndTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((order) => order.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'estimatedEndTime': estimatedEndTime?.toIso8601String(),
    };
  }
}
