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
  final String phone;
  final String email;
  final String link;
  final String name;
  final String employerId;
  final String clientCompany;
  final String status; // 'Open', 'Closed'

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
    this.phone = '',
    this.email = '',
    this.link = '',
    this.name = '',
    this.employerId = '',
    this.clientCompany = '',
    this.status = 'Open',
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
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      link: map['link'] ?? '',
      name: map['name'] ?? '',
      employerId: map['employerId'] ?? '',
      clientCompany: map['clientCompany'] ?? '',
      status: map['status'] ?? 'Open',
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
      'phone': phone,
      'email': email,
      'link': link,
      'name': name,
      'employerId': employerId,
      'clientCompany': clientCompany,
      'status': status,
    };
  }
}
