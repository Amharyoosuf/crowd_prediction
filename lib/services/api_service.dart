import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_response.dart';

class ApiService {
  static const String baseUrl =
      'https://amhayyoosuf-tourism-crowd-api.hf.space';

  static Future<PredictionResponse> predictCrowd({
    required String month,
    required String place,
    required double temperature,
    required double events,
  }) async {
    final url = Uri.parse('$baseUrl/predict');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'month': month,
        'place': place,
        'temperature': temperature,
        'events': events,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return PredictionResponse.fromJson(data);
    } else {
      throw Exception(
        'API error: ${response.statusCode} ${response.body}',
      );
    }
  }
}