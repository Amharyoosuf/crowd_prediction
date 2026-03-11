import 'package:flutter/material.dart';
import '../models/accommodation_model.dart';

class AccommodationScreen extends StatelessWidget {
  final List<AccommodationModel> accommodations;

  const AccommodationScreen({
    super.key,
    required this.accommodations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Accommodation'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF3F7FC),
      body: accommodations.isEmpty
          ? const Center(
        child: Text('No accommodation found.'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: accommodations.length,
        itemBuilder: (context, index) {
          final hotel = accommodations[index];

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
                  hotel.hotelName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('District: ${hotel.district}'),
                Text('Class: ${hotel.travelClass}'),
                Text('Price per Night: ${hotel.pricePerNightLkr} LKR'),
                Text('Rating: ${hotel.rating}'),
              ],
            ),
          );
        },
      ),
    );
  }
}