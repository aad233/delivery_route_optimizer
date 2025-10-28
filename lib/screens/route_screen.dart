import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_route_optimizer/services/route_optimizer_service.dart';
import 'package:delivery_route_optimizer/services/map_service.dart';
import 'package:delivery_route_optimizer/services/geocoding_service.dart';

class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimized Route'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<RouteOptimizerService>(context, listen: false)
                  .resetPriorities();
            },
            tooltip: 'Reset Priorities',
          ),
        ],
      ),
      body: Column(
        children: [
          // Map section with fixed height
          SizedBox(
            height: 200,
            child: Consumer<MapService>(
              builder: (context, mapService, child) {
                return mapService.mapWidget;
              },
            ),
          ),

          // Delivery list section
          Expanded(
            child: Consumer<RouteOptimizerService>(
              builder: (context, routeOptimizer, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Distance: ${routeOptimizer.totalDistance.toStringAsFixed(2)} km',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Estimated Time: ${routeOptimizer.estimatedTime}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Delivery Order:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Higher priority = Earlier delivery',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // List of deliveries with sliders
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: routeOptimizer.optimizedRoute.length,
                        itemBuilder: (context, index) {
                          final delivery = routeOptimizer.optimizedRoute[index];
                          final isRestaurant = delivery.address ==
                              RouteOptimizerService.restaurantAddress;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: isRestaurant ? Colors.blue.shade50 : null,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Delivery information row
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isRestaurant
                                              ? Colors.blue
                                              : Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            isRestaurant ? 'R' : '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          delivery.address,
                                          style: TextStyle(
                                            fontWeight: isRestaurant
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (delivery.deliveryTime != null)
                                        Text(
                                          '${delivery.deliveryTime!.hour}:${delivery.deliveryTime!.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      else if (delivery.isAsap)
                                        const Text(
                                          'ASAP',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),

                                  // Priority slider for non-restaurant deliveries
                                  if (!isRestaurant) ...[
                                    const SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.schedule, size: 16),
                                            SizedBox(width: 5),
                                            Text('Priority:'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.low_priority,
                                                size: 20),
                                            Expanded(
                                              child: Slider(
                                                value: delivery.priority,
                                                min: 0.0,
                                                max: 1.0,
                                                divisions: 10,
                                                label: delivery.priority
                                                    .toStringAsFixed(1),
                                                onChanged: (value) {
                                                  routeOptimizer.updatePriority(
                                                      index, value);
                                                },
                                                activeColor: Colors.blue,
                                                inactiveColor:
                                                    Colors.grey.shade300,
                                              ),
                                            ),
                                            const Icon(Icons.priority_high,
                                                size: 20),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Center(
                                          child: Text(
                                            'Priority: ${delivery.priority.toStringAsFixed(1)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Center(
                                          child: Text(
                                            delivery.priority >= 0.7
                                                ? 'High Priority'
                                                : delivery.priority >= 0.4
                                                    ? 'Medium Priority'
                                                    : 'Low Priority',
                                            style: TextStyle(
                                              color: delivery.priority >= 0.7
                                                  ? Colors.red
                                                  : delivery.priority >= 0.4
                                                      ? Colors.orange
                                                      : Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Navigation button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Consumer3<RouteOptimizerService, MapService, GeocodingService>(
              builder: (context, routeOptimizer, mapService, geocodingService,
                  child) {
                return ElevatedButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preparing navigation...')),
                    );

                    try {
                      // Get coordinates for each delivery
                      for (var delivery in routeOptimizer.optimizedRoute) {
                        if (delivery.address !=
                            RouteOptimizerService.restaurantAddress) {
                          final coords = await geocodingService
                              .getCoordinatesFromAddress(delivery.address);
                          debugPrint(
                              'Coordinates for ${delivery.address}: ${coords.latitude}, ${coords.longitude}');
                        }
                      }

                      // Check if the widget is still mounted before using context
                      if (context.mounted) {
                        // Start navigation with Google Maps
                        await mapService.startNavigation(routeOptimizer);
                      }
                    } catch (e) {
                      // Check if the widget is still mounted before using context
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Start Navigation in Google Maps'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
