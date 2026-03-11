import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/accommodation_model.dart';
import '../models/dining_model.dart';

class LocalDataService {
  static Future<List<AccommodationModel>> loadAccommodations() async {
    final rawData = await rootBundle.loadString(
      'assets/data/accommodation_master_final_K.csv',
    );

    final List<List<dynamic>> csvTable = const CsvToListConverter(
      eol: '\n',
    ).convert(rawData);

    return csvTable
        .skip(1)
        .where((row) => row.isNotEmpty)
        .map((row) => AccommodationModel.fromCsv(row))
        .toList();
  }

  static Future<List<DiningModel>> loadDiningPlaces() async {
    final rawData = await rootBundle.loadString(
      'assets/data/dining.csv',
    );

    final List<List<dynamic>> csvTable = const CsvToListConverter(
      eol: '\n',
    ).convert(rawData);

    return csvTable
        .skip(1)
        .where((row) => row.isNotEmpty)
        .map((row) => DiningModel.fromCsv(row))
        .toList();
  }
}