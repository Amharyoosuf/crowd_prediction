class DiningModel {
  final String district;
  final String restaurantName;
  final String travelClass;
  final String specialty;
  final String approxRangeLkr;
  final String bestTime;
  final String timeCategory;

  DiningModel({
    required this.district,
    required this.restaurantName,
    required this.travelClass,
    required this.specialty,
    required this.approxRangeLkr,
    required this.bestTime,
    required this.timeCategory,
  });

  factory DiningModel.fromCsv(List<dynamic> row) {
    return DiningModel(
      district: row[0]?.toString() ?? '',
      restaurantName: row[1]?.toString() ?? '',
      travelClass: row[2]?.toString() ?? '',
      specialty: row[3]?.toString() ?? '',
      approxRangeLkr: row[4]?.toString() ?? '',
      bestTime: row[5]?.toString() ?? '',
      timeCategory: row[6]?.toString() ?? '',
    );
  }
}