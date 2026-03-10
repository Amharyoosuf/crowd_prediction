import 'package:flutter/material.dart';
import 'PlacesScreen.dart';
import 'data.dart'; // Make sure path matches your project structure

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Nature', 'places': naturePlaces},
      {'name': 'Adventure', 'places': adventurePlaces},
      {'name': 'Historical', 'places': historicalPlaces},
      {'name': 'Beaches', 'places': beachPlaces},
      {'name': 'Cultural', 'places': culturalPlaces},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Explore Sri Lanka')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(category['name'] as String),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlacesScreen(
                      title: category['name'] as String,
                      places: category['places'] as List<Map<String, dynamic>>,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
