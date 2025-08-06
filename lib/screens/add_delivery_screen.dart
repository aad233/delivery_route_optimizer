import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_route_optimizer/services/route_optimizer_service.dart';
import 'package:delivery_route_optimizer/models/delivery_order.dart'; // Removed unused import

class AddDeliveryScreen extends StatefulWidget {
  const AddDeliveryScreen({super.key});

  @override
  State<AddDeliveryScreen> createState() => _AddDeliveryScreenState();
}

class _AddDeliveryScreenState extends State<AddDeliveryScreen> {
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  DateTime? _selectedTime;
  bool _isAsap = false;

  @override
  void dispose() {
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        final now = DateTime.now();
        _selectedTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
        _isAsap = false;
      });
    }
  }

  void _addDelivery() {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an address')),
      );
      return;
    }

    final routeOptimizer =
        Provider.of<RouteOptimizerService>(context, listen: false);

    routeOptimizer.addOrder(
      DeliveryOrder(
        address: _addressController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty
            ? null
            : _postalCodeController.text.trim(),
        deliveryTime: _selectedTime,
        isAsap: _isAsap,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Delivery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                hintText: 'Enter address manually or use camera',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'Postal Code (Optional)',
                hintText: 'e.g., 3081KR',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectTime,
                    child: Text(
                      _selectedTime == null
                          ? 'Set Delivery Time'
                          : 'Time: ${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isAsap = !_isAsap;
                        if (_isAsap) {
                          _selectedTime = null;
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _isAsap ? Colors.orange.shade100 : null,
                    ),
                    child: Text(
                      'ASAP Delivery',
                      style: TextStyle(
                        color: _isAsap ? Colors.orange.shade800 : null,
                        fontWeight: _isAsap ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/camera');
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Use Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: _addDelivery,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Delivery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
