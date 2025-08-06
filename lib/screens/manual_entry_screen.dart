import 'package:flutter/material.dart';
import '../models/delivery_order.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _postalController = TextEditingController();
  DateTime? _deliveryTime;
  bool _isAsap = true;

  @override
  void dispose() {
    _addressController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Order Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Street and number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _postalController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  hintText: '1234 AB',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter postal code';
                  }
                  if (!RegExp(r'^\d{4}\s?[A-Za-z]{2}$').hasMatch(value)) {
                    return 'Invalid postal format';
                  }
                  return null;
                },
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
              const Spacer(),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Order'),
              ),
            ],
          ),
        ),
      ),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final order = DeliveryOrder(
        address: '${_addressController.text}, ${_postalController.text}',
        deliveryTime: _isAsap ? null : _deliveryTime,
        isAsap: _isAsap,
        postalCode: _postalController.text.replaceAll(' ', '').toUpperCase(),
      );
      Navigator.pop(context, [order]);
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
