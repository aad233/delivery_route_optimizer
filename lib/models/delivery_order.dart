class DeliveryOrder {
  final String address;
  final DateTime? deliveryTime;
  final bool isAsap;
  final String? postalCode;
  final double priority; // New field for priority (0.0 to 1.0)

  DeliveryOrder({
    required this.address,
    this.deliveryTime,
    this.isAsap = false,
    this.postalCode,
    this.priority = 0.5, // Default priority
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      address: json['address'],
      deliveryTime: json['deliveryTime'] != null
          ? DateTime.parse(json['deliveryTime'])
          : null,
      isAsap: json['isAsap'] ?? false,
      postalCode: json['postalCode'],
      priority: json['priority'] ?? 0.5, // Handle missing priority
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'deliveryTime': deliveryTime?.toIso8601String(),
      'isAsap': isAsap,
      'postalCode': postalCode,
      'priority': priority, // Include priority in JSON
    };
  }

  // Create a copy with updated priority
  DeliveryOrder copyWithPriority(double newPriority) {
    return DeliveryOrder(
      address: address,
      deliveryTime: deliveryTime,
      isAsap: isAsap,
      postalCode: postalCode,
      priority: newPriority,
    );
  }
}
