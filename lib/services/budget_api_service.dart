import 'dart:convert';
import 'package:http/http.dart' as http;

class BudgetApiService {
  static const String baseUrl = 'https://amhayyoosuf-budget.hf.space';

  static Future<Map<String, dynamic>> predictBudget({
    required int adults,
    required int childrens,
    required int days,
    required String travelClass,
    required List<String> districts,
  }) async {
    final url = Uri.parse('$baseUrl/predict');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'adults': adults,
        'childrens': childrens,
        'days': days,
        'class': travelClass,
        'districts': districts,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to predict budget: ${response.body}');
    }
  }
}