import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_route_optimizer/screens/add_delivery_screen.dart';
// Removed unused imports
import 'package:delivery_route_optimizer/services/route_optimizer_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Route Optimizer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Delivery Route Optimizer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera Scan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Scanned Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: Consumer<RouteOptimizerService>(
        builder: (context, routeOptimizer, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'You have ${routeOptimizer.orders.length} deliveries',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: routeOptimizer.orders.length,
                  itemBuilder: (context, index) {
                    final delivery = routeOptimizer.orders[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(delivery.address),
                      subtitle: Text(delivery.isAsap
                          ? 'ASAP'
                          : delivery.deliveryTime != null
                              ? '${delivery.deliveryTime!.hour}:${delivery.deliveryTime!.minute.toString().padLeft(2, '0')}'
                              : 'No time set'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          routeOptimizer.removeOrder(index);
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddDeliveryScreen(),
                          ),
                        );
                      },
                      child: const Text('Add Delivery'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: routeOptimizer.orders.isEmpty
                          ? null
                          : () async {
                              // Show loading indicator
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Optimizing route...')),
                              );

                              // Optimize the route
                              routeOptimizer.optimizeRoute();

                              // Navigate to route screen
                              Navigator.pushNamed(context, '/route');
                            },
                      child: const Text('Optimize Route'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
