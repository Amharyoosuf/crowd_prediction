import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/favorites_manager.dart';
class PlacesScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> places;

  const PlacesScreen({
    super.key,
    required this.title,
    required this.places,
  });

  Future<void> _openMaps(String placeName) async {
    final encodedPlace = Uri.encodeComponent(placeName);

    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedPlace',
    );

    try {
      final launched = await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint('Could not open Google Maps');
      }
    } catch (e) {
      debugPrint('Error opening Google Maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.asset(
                      place['image'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            place['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: FavoritesManager.favorites,
                          builder: (context, favorites, _) {
                            final isSaved =
                            FavoritesManager.isFavorite(place);

                            return IconButton(
                              onPressed: () {
                                FavoritesManager.toggleFavorite(place);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isSaved
                                          ? '${place['name']} removed from saved places'
                                          : '${place['name']} added to saved places',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isSaved
                                    ? Colors.deepPurple
                                    : Colors.grey,
                                size: 28,
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 6),

                        ElevatedButton.icon(
                          onPressed: () async {
                            await _openMaps(place['name']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.navigation),
                          label: const Text('Navigate'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}