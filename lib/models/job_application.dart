import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplication {
  final String id;
  final String jobId;
  final String jobTitle;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String resumeUrl;
  final String resumeFileName;
  final DateTime appliedAt;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.resumeUrl,
    required this.resumeFileName,
    required this.appliedAt,
  });

  factory JobApplication.fromMap(String id, Map<String, dynamic> map) {
    return JobApplication(
      id: id,
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      applicantName: map['applicantName'] ?? '',
      applicantEmail: map['applicantEmail'] ?? '',
      applicantPhone: map['applicantPhone'] ?? '',
      resumeUrl: map['resumeUrl'] ?? '',
      resumeFileName: map['resumeFileName'] ?? '',
      appliedAt: map['appliedAt'] is Timestamp
          ? (map['appliedAt'] as Timestamp).toDate()
          : (map['appliedAt'] != null ? DateTime.tryParse(map['appliedAt'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantPhone': applicantPhone,
      'resumeUrl': resumeUrl,
      'resumeFileName': resumeFileName,
      'appliedAt': Timestamp.fromDate(appliedAt),
    };
  }
}
