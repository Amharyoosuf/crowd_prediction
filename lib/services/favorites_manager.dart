import 'package:flutter/material.dart';

class FavoritesManager {
  static final ValueNotifier<List<Map<String, dynamic>>> favorites =
  ValueNotifier<List<Map<String, dynamic>>>([]);

  static bool isFavorite(Map<String, dynamic> place) {
    return favorites.value.any((item) => item['name'] == place['name']);
  }

  static void toggleFavorite(Map<String, dynamic> place) {
    final current = List<Map<String, dynamic>>.from(favorites.value);

    final exists = current.any((item) => item['name'] == place['name']);

    if (exists) {
      current.removeWhere((item) => item['name'] == place['name']);
    } else {
      current.add(place);
    }

    favorites.value = current;
  }
}