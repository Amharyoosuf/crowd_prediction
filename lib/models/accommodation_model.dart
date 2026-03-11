class AccommodationModel {
  final String district;
  final String hotelName;
  final String pricePerNightLkr;
  final String rating;
  final String travelClass;

  AccommodationModel({
    required this.district,
    required this.hotelName,
    required this.pricePerNightLkr,
    required this.rating,
    required this.travelClass,
  });

  factory AccommodationModel.fromCsv(List<dynamic> row) {
    return AccommodationModel(
      district: row[0]?.toString() ?? '',
      hotelName: row[1]?.toString() ?? '',
      pricePerNightLkr: row[2]?.toString() ?? '',
      rating: row[3]?.toString() ?? '',
      travelClass: row[4]?.toString() ?? '',
    );
  }
}