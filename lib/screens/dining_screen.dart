import 'package:flutter/material.dart';
import '../models/dining_model.dart';

class DiningScreen extends StatelessWidget {
  final List<DiningModel> diningPlaces;

  const DiningScreen({
    super.key,
    required this.diningPlaces,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Dining Places'),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF3F7FC),
      body: diningPlaces.isEmpty
          ? const Center(
        child: Text('No dining places found.'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: diningPlaces.length,
        itemBuilder: (context, index) {
          final place = diningPlaces[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.restaurantName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('District: ${place.district}'),
                Text('Class: ${place.travelClass}'),
                Text('Specialty: ${place.specialty}'),
                Text('Approx. Range: ${place.approxRangeLkr}'),
                Text('Best Time: ${place.bestTime}'),
                Text('Time: ${place.timeCategory}'),
              ],
            ),
          );
        },
      ),
    );
  }
}