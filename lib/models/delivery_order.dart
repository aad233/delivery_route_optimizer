class DeliveryOrder {
  final String address;
  final DateTime? deliveryTime;
  final bool isAsap;
  final String? postalCode;
  final double priority;
  final double? latitude;
  final double? longitude;

  DeliveryOrder({
    required this.address,
    this.deliveryTime,
    this.isAsap = false,
    this.postalCode,
    this.priority = 0.5,
    this.latitude,
    this.longitude,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      address: json['address'],
      deliveryTime: json['deliveryTime'] != null
          ? DateTime.parse(json['deliveryTime'])
          : null,
      isAsap: json['isAsap'] ?? false,
      postalCode: json['postalCode'],
      priority: json['priority'] ?? 0.5,
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'deliveryTime': deliveryTime?.toIso8601String(),
      'isAsap': isAsap,
      'postalCode': postalCode,
      'priority': priority,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  DeliveryOrder copyWith({
    String? address,
    DateTime? deliveryTime,
    bool? isAsap,
    String? postalCode,
    double? priority,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryOrder(
      address: address ?? this.address,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      isAsap: isAsap ?? this.isAsap,
      postalCode: postalCode ?? this.postalCode,
      priority: priority ?? this.priority,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
