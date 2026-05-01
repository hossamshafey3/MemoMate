// ─────────────────────────────────────────────
//  location_model.dart  –  Memomate
// ─────────────────────────────────────────────

class LocationModel {
  final double lat;
  final double lng;
  final String? city;
  final String? country;
  final String? updatedAt;

  LocationModel({
    required this.lat,
    required this.lng,
    this.city,
    this.country,
    this.updatedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      city: json['city'] as String?,
      country: json['country'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}
