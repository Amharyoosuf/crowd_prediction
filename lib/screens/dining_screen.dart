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
      backgroundColor: const Color(0xFFF3F7FC),
      appBar: AppBar(
        title: const Text(
          'Culinary Recommendations',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: diningPlaces.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: diningPlaces.length,
        itemBuilder: (context, index) {
          final place = diningPlaces[index];
          return _buildElegantDiningCard(place);
        },
      ),
    );
  }

  Widget _buildElegantDiningCard(DiningModel place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Restaurant Name + Class Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    place.restaurantName,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                ),
                _buildCategoryBadge(place.travelClass),
              ],
            ),

            const SizedBox(height: 6),

            /// Specialty
            Text(
              place.specialty,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF26A69A),
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(
                height: 1,
                thickness: 1.2,
                color: Color(0xFFE3F2FD),
              ),
            ),

            /// BIG DETAILS SECTION
            Row(
              children: [
                Expanded(
                  child: _bigDetail(
                    Icons.location_on_rounded,
                    place.district,
                    const Color(0xFF1565C0),
                  ),
                ),
                Expanded(
                  child: _bigDetail(
                    Icons.access_time_rounded,
                    place.timeCategory,
                    const Color(0xFF26A69A),
                  ),
                ),
                Expanded(
                  child: _bigDetail(
                    Icons.restaurant_menu,
                    place.bestTime,
                    const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// BIG DETAIL ICON STYLE
  Widget _bigDetail(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 26,
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  /// CATEGORY BADGE
  Widget _buildCategoryBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF26A69A).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF26A69A),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  /// EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            size: 80,
            color: const Color(0xFF1565C0).withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'No dining spots available yet.',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}