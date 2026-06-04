import 'package:cloud_firestore/cloud_firestore.dart';

class Testimonial {
  final String id;
  final String name;
  final String roleAndCountry;
  final String reviewText;
  final double rating;
  final DateTime timestamp;

  const Testimonial({
    required this.id,
    required this.name,
    required this.roleAndCountry,
    required this.reviewText,
    required this.rating,
    required this.timestamp,
  });

  factory Testimonial.fromMap(String id, Map<String, dynamic> map) {
    return Testimonial(
      id: id,
      name: map['name'] ?? '',
      roleAndCountry: map['roleAndCountry'] ?? '',
      reviewText: map['reviewText'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'roleAndCountry': roleAndCountry,
      'reviewText': reviewText,
      'rating': rating,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
