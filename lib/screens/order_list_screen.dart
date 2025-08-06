import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/delivery_order.dart';
import '../services/ocr_service.dart';
import '../widgets/order_card.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late List<DeliveryOrder> _orders;

  @override
  void initState() {
    super.initState();
    _orders = Provider.of<OcrService>(context, listen: false).lastScannedOrders;
  }

  void _editOrder(int index) async {
    final editedOrder = await showDialog<DeliveryOrder>(
      context: context,
      builder: (context) => _EditOrderDialog(order: _orders[index]),
    );

    if (editedOrder != null) {
      setState(() {
        _orders[index] = editedOrder;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _orders);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _editOrder(index),
            child: OrderCard(
              order: _orders[index],
              index: index,
              isRestaurant: false,
            ),
          );
        },
      ),
    );
  }
}

class _EditOrderDialog extends StatefulWidget {
  final DeliveryOrder order;

  const _EditOrderDialog({required this.order});

  @override
  State<_EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<_EditOrderDialog> {
  late TextEditingController _addressController;
  late TextEditingController _postalController;
  late DateTime? _deliveryTime;
  late bool _isAsap;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: widget.order.address.split(',').first.trim(),
    );
    _postalController = TextEditingController(
      text: widget.order.postalCode,
    );
    _deliveryTime = widget.order.deliveryTime;
    _isAsap = widget.order.isAsap;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Order'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          TextField(
            controller: _postalController,
            decoration: const InputDecoration(labelText: 'Postal Code'),
          ),
          SwitchListTile(
            title: const Text('ASAP Delivery'),
            value: _isAsap,
            onChanged: (value) {
              setState(() {
                _isAsap = value;
                if (!_isAsap) {
                  _selectTime(context);
                }
              });
            },
          ),
          if (!_isAsap && _deliveryTime != null)
            Text('Delivery Time: ${_formatTime(_deliveryTime!)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final editedOrder = DeliveryOrder(
              address: '${_addressController.text}, ${_postalController.text}',
              postalCode: _postalController.text,
              deliveryTime: _deliveryTime,
              isAsap: _isAsap,
            );
            Navigator.pop(context, editedOrder);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _deliveryTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
