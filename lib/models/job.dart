import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type; // 'Full-time', 'Part-time', 'Contract', etc.
  final String salaryRange;
  final String description;
  final String requirements;
  final DateTime postedAt;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salaryRange,
    required this.description,
    required this.requirements,
    required this.postedAt,
  });

  factory Job.fromMap(String id, Map<String, dynamic> map) {
    return Job(
      id: id,
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      type: map['type'] ?? 'Full-time',
      salaryRange: map['salaryRange'] ?? '',
      description: map['description'] ?? '',
      requirements: map['requirements'] ?? '',
      postedAt: map['postedAt'] is Timestamp
          ? (map['postedAt'] as Timestamp).toDate()
          : (map['postedAt'] != null ? DateTime.tryParse(map['postedAt'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'salaryRange': salaryRange,
      'description': description,
      'requirements': requirements,
      'postedAt': Timestamp.fromDate(postedAt),
    };
  }
}
