import 'package:cloud_firestore/cloud_firestore.dart';

class Testimonial {
  final String id;
  final String name;
  final String roleAndCountry;
  final String reviewText;
  final double rating;
  final DateTime timestamp;
  final String category; // 'job_seeker' or 'business'
  final String? imageUrl;

  const Testimonial({
    required this.id,
    required this.name,
    required this.roleAndCountry,
    required this.reviewText,
    required this.rating,
    required this.timestamp,
    this.category = 'job_seeker',
    this.imageUrl,
  });

  factory Testimonial.fromMap(String id, Map<String, dynamic> map) {
    return Testimonial(
      id: id,
      name: map['name'] ?? '',
      roleAndCountry: map['roleAndCountry'] ?? '',
      reviewText: map['reviewText'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: map['category'] ?? 'job_seeker',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'roleAndCountry': roleAndCountry,
      'reviewText': reviewText,
      'rating': rating,
      'timestamp': Timestamp.fromDate(timestamp),
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
