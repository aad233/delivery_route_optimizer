import 'package:flutter/material.dart';
import '../models/delivery_order.dart';

class OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final int index;
  final bool isRestaurant;

  const OrderCard({
    super.key,
    required this.order,
    required this.index,
    this.isRestaurant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRestaurant ? Colors.blue : Colors.red,
          child: Text('${index + 1}'),
        ),
        title: Text(
          order.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: order.deliveryTime != null
            ? Text('Deliver by: ${_formatTime(order.deliveryTime!)}')
            : const Text('ASAP'),
        trailing: isRestaurant ? const Icon(Icons.restaurant) : null,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
