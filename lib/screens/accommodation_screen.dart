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
      // A slightly warmer, cleaner off-white for the background
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        title: const Text(
          'Top Recommendations',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: accommodations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: accommodations.length,
        itemBuilder: (context, index) {
          final hotel = accommodations[index];
          return _buildModernTextCard(hotel);
        },
      ),
    );
  }

  Widget _buildModernTextCard(AccommodationModel hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade50, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title and Class Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hotel.hotelName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              _buildRatingBadge(hotel.rating),
            ],
          ),

          const SizedBox(height: 12),

          // Location and Class Info
          Row(
            children: [
              _infoChip(Icons.location_on_rounded, hotel.district, Colors.redAccent ),
              const SizedBox(width: 12),
              _infoChip(Icons.stars_rounded, hotel.travelClass, Colors.orange.shade700),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFE3F2FD), thickness: 1.5),
          ),

          // Price Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRICE PER NIGHT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${hotel.pricePerNightLkr} ',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900 ,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const TextSpan(
                          text: 'LKR',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Sublte Chevron icon to imply "Details"
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBadge(var rating) {
    const amberDetail = Color(0xFF795548); // define locally
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 2),
          Text(
            '$rating',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: amberDetail, // use local variable
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hotel_outlined, size: 64, color: Colors.blue.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            'No matches found.',
            style: TextStyle(color: Colors.blueGrey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// Helper for Amber color detail if needed
extension on Color {
  static const Color amberDetail = Color(0xFF795548);
}