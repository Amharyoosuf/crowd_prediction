class AlternativePlace {
  final String place;
  final String category;
  final String month;
  final double temperature;
  final String predictedCrowd;

  AlternativePlace({
    required this.place,
    required this.category,
    required this.month,
    required this.temperature,
    required this.predictedCrowd,
  });

  factory AlternativePlace.fromJson(Map<String, dynamic> json) {
    return AlternativePlace(
      place: json['Place']?.toString() ?? '',
      category: json['Category']?.toString() ?? '',
      month: json['Month']?.toString() ?? '',
      temperature: (json['Temperature'] as num?)?.toDouble() ?? 0.0,
      predictedCrowd: json['Predicted_Crowd']?.toString() ?? '',
    );
  }
}

class PredictionResponse {
  final String month;
  final String place;
  final double temperature;
  final double events;
  final String predictedCrowd;
  final String? category;
  final List<AlternativePlace> alternatives;

  PredictionResponse({
    required this.month,
    required this.place,
    required this.temperature,
    required this.events,
    required this.predictedCrowd,
    required this.category,
    required this.alternatives,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      month: json['month']?.toString() ?? '',
      place: json['place']?.toString() ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      events: (json['events'] as num?)?.toDouble() ?? 0.0,
      predictedCrowd: json['predicted_crowd']?.toString() ?? '',
      category: json['category']?.toString(),
      alternatives: (json['alternatives'] as List<dynamic>? ?? [])
          .map((e) => AlternativePlace.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}