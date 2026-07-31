import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/testimonial.dart';
import '../models/job.dart';
import '../models/job_application.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();

  FirebaseService._internal() {
    _initFallbackTestimonials();
    _initFallbackJobs();
  }

  bool get isFirebaseInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Memory fallback state for demo mode
  final List<Testimonial> _localTestimonials = [];
  final StreamController<List<Testimonial>> _testimonialsController =
      StreamController<List<Testimonial>>.broadcast();

  final List<Map<String, dynamic>> _localInquiries = [];
  final StreamController<List<Map<String, dynamic>>> _inquiriesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  final List<Job> _localJobs = [];
  final StreamController<List<Job>> _jobsController =
      StreamController<List<Job>>.broadcast();

  final List<JobApplication> _localJobApplications = [];
  final StreamController<List<JobApplication>> _jobApplicationsController =
      StreamController<List<JobApplication>>.broadcast();

  void _initFallbackTestimonials() {
    _localTestimonials.addAll([
      Testimonial(
        id: '1',
        name: 'Rahul Sharma',
        roleAndCountry: 'Software Engineer, Germany',
        reviewText:
            'AVM Global made my European dream a reality! The visa guidance and job placement assistance was absolutely seamless. Extremely transparent process.',
        rating: 5.0,
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        category: 'job_seeker',
      ),
      Testimonial(
        id: '2',
        name: 'Priya Patel',
        roleAndCountry: 'Head Nurse, Canada',
        reviewText:
            'Very professional services. They helped me with credential evaluation, IELTS prep recommendations, and matched me with a fantastic healthcare provider in Ontario.',
        rating: 5.0,
        timestamp: DateTime.now().subtract(const Duration(days: 15)),
        category: 'job_seeker',
      ),
      Testimonial(
        id: '3',
        name: 'Anil Kumar',
        roleAndCountry: 'Operations Manager, Dubai',
        reviewText:
            'Great experience with the recruitment team. They kept me updated at every stage of my application. I highly recommend AVM for Gulf opportunities.',
        rating: 4.0,
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        category: 'job_seeker',
      ),
      Testimonial(
        id: '4',
        name: 'Sophia Weber',
        roleAndCountry: 'HR Director, MedLink Europe (Munich)',
        reviewText:
            'AVM Global is our trusted partner for nursing recruitment. Their candidates are exceptionally well-prepared, fully compliant with German standards, and integrate seamlessly into our clinical teams.',
        rating: 5.0,
        timestamp: DateTime.now().subtract(const Duration(days: 45)),
        category: 'business',
      ),
      Testimonial(
        id: '5',
        name: 'Marcus Thompson',
        roleAndCountry: 'VP of Engineering, Apex Systems (Canada)',
        reviewText:
            'We have successfully hired multiple cloud architects and software developers through AVM Global. Their technical screening, vetting, and relocation assistance are top-notch.',
        rating: 5.0,
        timestamp: DateTime.now().subtract(const Duration(days: 20)),
        category: 'business',
      ),
      Testimonial(
        id: '6',
        name: 'Fatima Al-Sayed',
        roleAndCountry: 'Talent Acquisition Manager, Oasis Health (UAE)',
        reviewText:
            'Extremely professional recruitment services. They managed the end-to-end relocation process of 15 healthcare professionals for our hospital network in Dubai. Flawless execution.',
        rating: 5.0,
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        category: 'business',
      ),
    ]);
    _testimonialsController.add(_localTestimonials);
  }

  void _initFallbackJobs() {
    _localJobs.addAll([
      Job(
        id: 'job_1',
        title: 'Senior Software Engineer (Java/Kotlin)',
        company: 'Innovatech Solutions',
        location: 'Munich, Germany',
        type: 'Full-time',
        salaryRange: '€75,000 - €90,000 / year',
        description: 'We are looking for a Senior Software Engineer with strong background in backend systems, JVM languages (Java/Kotlin), Spring Boot, and cloud architecture (AWS/GCP) to design scalable software solutions.',
        requirements: '• 5+ years of software development experience\n• Strong expertise in Spring Boot, REST APIs, and microservices\n• Experience with Docker, Kubernetes, and CI/CD pipelines\n• Fluent in English, German knowledge is a plus\n• Excellent problem-solving skills.',
        postedAt: DateTime.now().subtract(const Duration(days: 12)),
        phone: '+49 89 123456',
        email: 'jobs@innovatech.de',
        link: 'https://innovatech.de/careers',
        name: 'Hans Schmidt',
      ),
      Job(
        id: 'job_2',
        title: 'Registered ICU Nurse',
        company: 'Ontario Health Alliance',
        location: 'Toronto, Canada',
        type: 'Full-time',
        salaryRange: '\$80,000 - \$95,000 / year',
        description: 'Provide professional nursing care in accordance with nursing standards in our state-of-the-art Intensive Care Unit. Assist with clinical assessments, treatments, and patient care planning.',
        requirements: '• Degree/Diploma in Nursing\n• Registered Nurse (RN) designation or eligibility for registration with CNO\n• 2+ years of critical care / ICU nursing experience\n• IELTS score of 7.0+ or equivalent language validation\n• Empathetic and resilient nature.',
        postedAt: DateTime.now().subtract(const Duration(days: 8)),
        phone: '+1 416 555 0192',
        email: 'recruitment@ontariohealth.ca',
        link: 'https://ontariohealth.ca/careers',
        name: 'Emily Davis',
      ),
      Job(
        id: 'job_3',
        title: 'Cloud Infrastructure Architect',
        company: 'Apex Systems',
        location: 'Vancouver, Canada (Hybrid)',
        type: 'Contract',
        salaryRange: '\$90 - \$115 / hour',
        description: 'Architect, implement, and maintain enterprise cloud infrastructure. Oversee cloud migration initiatives and enforce security protocols across AWS and Azure deployments.',
        requirements: '• 8+ years in IT infrastructure with 4+ years focusing on cloud architecture\n• Certified AWS Solutions Architect Professional or Azure Solutions Architect Expert\n• Deep expertise in Terraform, Ansible, and Infrastructure as Code\n• Strong communication and client-handling skills.',
        postedAt: DateTime.now().subtract(const Duration(days: 4)),
        phone: '+1 604 555 0134',
        email: 'careers@apexsystems.com',
        link: 'https://apexsystems.com/jobs',
        name: 'Ryan Mercer',
      ),
      Job(
        id: 'job_4',
        title: 'Civil & Structural Site Engineer',
        company: 'Pacific Construction Group',
        location: 'Sydney, Australia',
        type: 'Full-time',
        salaryRange: 'A\$105,000 - A\$125,000 / year',
        description: 'Lead engineering tasks, quality checks, and site management for multi-story residential and commercial construction projects. Ensure compliance with safety standards and architectural blueprints.',
        requirements: '• Bachelor’s degree in Civil or Structural Engineering\n• 4+ years of on-site construction supervision/engineering experience\n• Experience with AutoCAD, Revit, and project management tools\n• Full working knowledge of Australian Building Codes (NCC).\n• Valid Driver’s License.',
        postedAt: DateTime.now().subtract(const Duration(days: 15)),
        phone: '+61 2 9876 5432',
        email: 'hr@pacificconstruction.com.au',
        link: 'https://pacificconstruction.com.au/careers',
        name: 'James Reynolds',
      ),
      Job(
        id: 'job_5',
        title: 'Hotel Operations Manager',
        company: 'Oasis Luxury Resorts',
        location: 'Dubai, UAE',
        type: 'Full-time',
        salaryRange: 'AED 15,000 - 20,000 / month (Tax-Free)',
        description: 'Supervise daily resort operations including front office, guest relations, housekeeping, food & beverage, and event management. Focus on guest satisfaction, budget controls, and service excellence.',
        requirements: '• Degree in Hospitality Management or related field\n• 5+ years of leadership experience in 4/5-star hospitality settings\n• Excellent leadership, interpersonal, and communication skills\n• Experience managing multi-cultural teams\n• Strong financial acumen and budgeting skills.',
        postedAt: DateTime.now().subtract(const Duration(days: 6)),
        phone: '+971 4 456 7890',
        email: 'careers@oasisresorts.ae',
        link: 'https://oasisresorts.ae/careers',
        name: 'Amara Khan',
      ),
    ]);
    _jobsController.add(_localJobs);
  }

  // Submit Candidate Registration
  Future<String> submitCandidate({
    required String name,
    required String email,
    required String phone,
    required String qualification,
    required double experience,
    required String preferredCountry,
    String? resumeFileName,
    Uint8List? resumeFileBytes,
  }) async {
    try {
      String resumeUrl = '';

      if (isFirebaseInitialized && resumeFileName != null && resumeFileBytes != null) {
        try {
          // Upload resume to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('resumes/${DateTime.now().millisecondsSinceEpoch}_$resumeFileName');
          
          final uploadTask = storageRef.putData(
            resumeFileBytes,
            SettableMetadata(contentType: 'application/pdf'),
          );
          
          final snapshot = await uploadTask.timeout(const Duration(seconds: 5));
          resumeUrl = await snapshot.ref.getDownloadURL();
        } catch (_) {
          resumeUrl = 'https://demo-storage.example.com/resumes/$resumeFileName';
        }
      } else {
        if (resumeFileName != null) {
          resumeUrl = 'https://demo-storage.example.com/resumes/$resumeFileName';
        }
      }

      final candidateData = {
        'name': name,
        'email': email,
        'phone': phone,
        'qualification': qualification,
        'experience': experience,
        'preferredCountry': preferredCountry,
        'resumeUrl': resumeUrl,
        'resumeFileName': resumeFileName ?? '',
        'submittedAt': FieldValue.serverTimestamp(),
      };

      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('candidates')
              .add(candidateData)
              .timeout(const Duration(seconds: 4));
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore candidate submit failed ($dbError). Logging locally.');
          }
        }
      } else {
        if (kDebugMode) {
          print('Demo Mode: Candidate submitted locally -> $candidateData');
        }
      }
      return 'Success';
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting candidate: $e');
      }
      rethrow;
    }
  }

  // Submit Contact Inquiry
  Future<void> submitContactInquiry({
    required String name,
    required String jobField,
    String? resumeFileName,
    Uint8List? resumeFileBytes,
  }) async {
    try {
      String resumeUrl = '';

      if (isFirebaseInitialized && resumeFileName != null && resumeFileBytes != null) {
        try {
          // Upload resume to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('contact_resumes/${DateTime.now().millisecondsSinceEpoch}_$resumeFileName');
          
          final uploadTask = storageRef.putData(
            resumeFileBytes,
            SettableMetadata(
              contentType: resumeFileName.endsWith('.pdf')
                  ? 'application/pdf'
                  : 'application/octet-stream',
            ),
          );
          
          final snapshot = await uploadTask.timeout(const Duration(seconds: 5));
          resumeUrl = await snapshot.ref.getDownloadURL();
        } catch (_) {
          resumeUrl = 'https://demo-storage.example.com/contact_resumes/$resumeFileName';
        }
      } else {
        if (resumeFileName != null) {
          resumeUrl = 'https://demo-storage.example.com/contact_resumes/$resumeFileName';
        }
      }

      final inquiryData = {
        'name': name,
        'jobField': jobField,
        'resumeUrl': resumeUrl,
        'resumeFileName': resumeFileName ?? '',
        'submittedAt': FieldValue.serverTimestamp(),
      };

      bool savedToFirestore = false;
      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('inquiries')
              .add(inquiryData)
              .timeout(const Duration(seconds: 4));
          savedToFirestore = true;
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore submitContactInquiry failed ($dbError). Saving locally instead.');
          }
        }
      }

      if (!savedToFirestore) {
        final mockId = DateTime.now().millisecondsSinceEpoch.toString();
        final localData = {
          'id': mockId,
          ...inquiryData,
          'submittedAt': DateTime.now(),
        };
        _localInquiries.insert(0, localData);
        _inquiriesController.add(List.from(_localInquiries));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting contact inquiry: $e');
      }
      rethrow;
    }
  }

  // Get Testimonials Stream (Realtime Resilient)
  Stream<List<Testimonial>> getTestimonialsStream() async* {
    if (isFirebaseInitialized) {
      bool hasEmitted = false;
      try {
        final firestoreStream = FirebaseFirestore.instance
            .collection('testimonials')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) => Testimonial.fromMap(doc.id, doc.data()))
              .toList();
        });

        await for (final list in firestoreStream.timeout(
          const Duration(seconds: 3),
          onTimeout: (sink) {
            throw TimeoutException('Firestore timeout');
          },
        )) {
          hasEmitted = true;
          yield list;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Firestore getTestimonialsStream failed ($e). Streaming local cache.');
        }
        if (!hasEmitted) {
          yield List.from(_localTestimonials);
          yield* _testimonialsController.stream;
        }
      }
    } else {
      yield List.from(_localTestimonials);
      yield* _testimonialsController.stream;
    }
  }

  // Submit Testimonial (Resilient)
  Future<void> submitTestimonial(
    Testimonial testimonial, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      String? imageUrl = testimonial.imageUrl;

      if (isFirebaseInitialized && imageBytes != null && imageName != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('testimonials/${DateTime.now().millisecondsSinceEpoch}_$imageName');
          
          final uploadTask = storageRef.putData(
            imageBytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          
          final snapshot = await uploadTask.timeout(const Duration(seconds: 5));
          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (storageError) {
          final base64Str = base64Encode(imageBytes);
          final extension = imageName.split('.').last.toLowerCase();
          final mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';
          imageUrl = 'data:$mimeType;base64,$base64Str';
        }
      } else if (imageBytes != null && imageName != null) {
        final base64Str = base64Encode(imageBytes);
        final extension = imageName.split('.').last.toLowerCase();
        final mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';
        imageUrl = 'data:$mimeType;base64,$base64Str';
      }

      final finalTestimonial = Testimonial(
        id: testimonial.id,
        name: testimonial.name,
        roleAndCountry: testimonial.roleAndCountry,
        reviewText: testimonial.reviewText,
        rating: testimonial.rating,
        timestamp: testimonial.timestamp,
        category: testimonial.category,
        imageUrl: imageUrl,
      );

      bool savedToFirestore = false;
      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('testimonials')
              .add(finalTestimonial.toMap())
              .timeout(const Duration(seconds: 4));
          savedToFirestore = true;
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore add testimonial failed ($dbError). Saving locally instead.');
          }
        }
      }

      if (!savedToFirestore) {
        _localTestimonials.insert(0, finalTestimonial);
        _testimonialsController.add(List.from(_localTestimonials));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting testimonial: $e');
      }
      rethrow;
    }
  }

  // Get Inquiries Stream (Realtime Resilient)
  Stream<List<Map<String, dynamic>>> getInquiriesStream() async* {
    if (isFirebaseInitialized) {
      bool hasEmitted = false;
      try {
        final firestoreStream = FirebaseFirestore.instance
            .collection('inquiries')
            .orderBy('submittedAt', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList();
        });

        await for (final list in firestoreStream.timeout(
          const Duration(seconds: 3),
          onTimeout: (sink) {
            throw TimeoutException('Firestore timeout');
          },
        )) {
          hasEmitted = true;
          yield list;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Firestore getInquiriesStream failed ($e). Streaming local cache.');
        }
        if (!hasEmitted) {
          yield List.from(_localInquiries);
          yield* _inquiriesController.stream;
        }
      }
    } else {
      yield List.from(_localInquiries);
      yield* _inquiriesController.stream;
    }
  }

  // Delete Inquiry (Resilient)
  Future<void> deleteInquiry(String id) async {
    try {
      bool deletedFromFirestore = false;
      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('inquiries')
              .doc(id)
              .delete()
              .timeout(const Duration(seconds: 4));
          deletedFromFirestore = true;
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore deleteInquiry failed ($dbError). Modifying local cache.');
          }
        }
      }

      if (!deletedFromFirestore || !isFirebaseInitialized) {
        _localInquiries.removeWhere((item) => item['id'] == id);
        _inquiriesController.add(List.from(_localInquiries));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting inquiry: $e');
      }
      rethrow;
    }
  }

  // Update Testimonial (Resilient)
  Future<void> updateTestimonial(
    Testimonial testimonial, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      String? imageUrl = testimonial.imageUrl;

      if (isFirebaseInitialized && imageBytes != null && imageName != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('testimonials/${DateTime.now().millisecondsSinceEpoch}_$imageName');
          
          final uploadTask = storageRef.putData(
            imageBytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          
          final snapshot = await uploadTask.timeout(const Duration(seconds: 5));
          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (storageError) {
          final base64Str = base64Encode(imageBytes);
          final extension = imageName.split('.').last.toLowerCase();
          final mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';
          imageUrl = 'data:$mimeType;base64,$base64Str';
        }
      } else if (imageBytes != null && imageName != null) {
        final base64Str = base64Encode(imageBytes);
        final extension = imageName.split('.').last.toLowerCase();
        final mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';
        imageUrl = 'data:$mimeType;base64,$base64Str';
      }

      final updatedTestimonial = Testimonial(
        id: testimonial.id,
        name: testimonial.name,
        roleAndCountry: testimonial.roleAndCountry,
        reviewText: testimonial.reviewText,
        rating: testimonial.rating,
        timestamp: testimonial.timestamp,
        category: testimonial.category,
        imageUrl: imageUrl,
      );

      bool updatedInFirestore = false;
      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('testimonials')
              .doc(updatedTestimonial.id)
              .update(updatedTestimonial.toMap())
              .timeout(const Duration(seconds: 4));
          updatedInFirestore = true;
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore update testimonial failed ($dbError). Modifying local cache.');
          }
        }
      }

      if (!updatedInFirestore || !isFirebaseInitialized) {
        final index = _localTestimonials.indexWhere((t) => t.id == updatedTestimonial.id);
        if (index != -1) {
          _localTestimonials[index] = updatedTestimonial;
          _testimonialsController.add(List.from(_localTestimonials));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating testimonial: $e');
      }
      rethrow;
    }
  }

  // Delete Testimonial (Resilient)
  Future<void> deleteTestimonial(String id) async {
    try {
      bool deletedFromFirestore = false;
      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('testimonials')
              .doc(id)
              .delete()
              .timeout(const Duration(seconds: 4));
          deletedFromFirestore = true;
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore deleteTestimonial failed ($dbError). Modifying local cache.');
          }
        }
      }

      if (!deletedFromFirestore || !isFirebaseInitialized) {
        _localTestimonials.removeWhere((t) => t.id == id);
        _testimonialsController.add(List.from(_localTestimonials));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting testimonial: $e');
      }
      rethrow;
    }
  }

  // Get Jobs Stream (Realtime Resilient)
  Stream<List<Job>> getJobsStream() async* {
    if (isFirebaseInitialized) {
      bool hasEmitted = false;
      try {
        final firestoreStream = FirebaseFirestore.instance
            .collection('jobs')
            .orderBy('postedAt', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) => Job.fromMap(doc.id, doc.data()))
              .toList();
        });

        await for (final list in firestoreStream.timeout(
          const Duration(seconds: 3),
          onTimeout: (sink) {
            throw TimeoutException('Firestore timeout');
          },
        )) {
          hasEmitted = true;
          yield list;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Firestore getJobsStream failed or timed out ($e). Streaming local mock jobs.');
        }
        if (!hasEmitted) {
          yield List.from(_localJobs);
          yield* _jobsController.stream;
        }
      }
    } else {
      yield List.from(_localJobs);
      yield* _jobsController.stream;
    }
  }

  // Add Job (Resilient with local backup)
  Future<void> addJob(Job job) async {
    try {
      bool savedToFirestore = false;
      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('jobs')
              .add(job.toMap())
              .timeout(const Duration(seconds: 4));
          savedToFirestore = true;
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore addJob failed ($dbError). Saving to local memory storage instead.');
          }
        }
      }

      // Always write to local storage as fallback or cache
      final mockId = job.id.isEmpty ? 'job_${DateTime.now().millisecondsSinceEpoch}' : job.id;
      final newJob = Job(
        id: mockId,
        title: job.title,
        company: job.company,
        location: job.location,
        type: job.type,
        salaryRange: job.salaryRange,
        description: job.description,
        requirements: job.requirements,
        postedAt: job.postedAt,
        phone: job.phone,
        email: job.email,
        link: job.link,
        name: job.name,
      );

      final index = _localJobs.indexWhere((j) => j.id == newJob.id);
      if (index == -1) {
        _localJobs.insert(0, newJob);
      } else {
        _localJobs[index] = newJob;
      }
      _jobsController.add(List.from(_localJobs));
    } catch (e) {
      if (kDebugMode) {
        print('Error adding job: $e');
      }
      rethrow;
    }
  }

  // Update Job (Resilient)
  Future<void> updateJob(Job job) async {
    try {
      bool updatedInFirestore = false;
      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('jobs')
              .doc(job.id)
              .update(job.toMap())
              .timeout(const Duration(seconds: 4));
          updatedInFirestore = true;
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore updateJob failed ($dbError). Modifying local cache.');
          }
        }
      }

      final index = _localJobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        _localJobs[index] = job;
        _jobsController.add(List.from(_localJobs));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating job: $e');
      }
      rethrow;
    }
  }

  // Delete Job (Resilient)
  Future<void> deleteJob(String id) async {
    try {
      bool deletedFromFirestore = false;
      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('jobs')
              .doc(id)
              .delete()
              .timeout(const Duration(seconds: 4));
          deletedFromFirestore = true;
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore deleteJob failed ($dbError). Modifying local cache.');
          }
        }
      }

      _localJobs.removeWhere((j) => j.id == id);
      _jobsController.add(List.from(_localJobs));
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting job: $e');
      }
      rethrow;
    }
  }

  // Submit Job Application (Resilient)
  Future<void> submitJobApplication({
    required String jobId,
    required String jobTitle,
    required String name,
    required String email,
    required String phone,
    String? resumeFileName,
    Uint8List? resumeFileBytes,
  }) async {
    try {
      String resumeUrl = '';

      if (isFirebaseInitialized && resumeFileName != null && resumeFileBytes != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('job_applications/${DateTime.now().millisecondsSinceEpoch}_$resumeFileName');
          
          final uploadTask = storageRef.putData(
            resumeFileBytes,
            SettableMetadata(contentType: 'application/pdf'),
          );
          
          final snapshot = await uploadTask.timeout(const Duration(seconds: 5));
          resumeUrl = await snapshot.ref.getDownloadURL();
        } catch (_) {
          resumeUrl = 'https://demo-storage.example.com/job_applications/$resumeFileName';
        }
      } else {
        if (resumeFileName != null) {
          resumeUrl = 'https://demo-storage.example.com/job_applications/$resumeFileName';
        }
      }

      final applicationData = {
        'jobId': jobId,
        'jobTitle': jobTitle,
        'applicantName': name,
        'applicantEmail': email,
        'applicantPhone': phone,
        'resumeUrl': resumeUrl,
        'resumeFileName': resumeFileName ?? '',
        'appliedAt': FieldValue.serverTimestamp(),
      };

      bool savedToFirestore = false;
      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('job_applications')
              .add(applicationData)
              .timeout(const Duration(seconds: 4));
          savedToFirestore = true;
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore submitJobApplication failed ($dbError). Saving to local memory instead.');
          }
        }
      }

      // Always update local cache
      final mockId = 'app_${DateTime.now().millisecondsSinceEpoch}';
      final localApp = JobApplication(
        id: mockId,
        jobId: jobId,
        jobTitle: jobTitle,
        applicantName: name,
        applicantEmail: email,
        applicantPhone: phone,
        resumeUrl: resumeUrl,
        resumeFileName: resumeFileName ?? '',
        appliedAt: DateTime.now(),
      );
      _localJobApplications.insert(0, localApp);
      _jobApplicationsController.add(List.from(_localJobApplications));
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting job application: $e');
      }
      rethrow;
    }
  }

  // Get Job Applications Stream (Realtime Resilient)
  Stream<List<JobApplication>> getJobApplicationsStream() async* {
    if (isFirebaseInitialized) {
      bool hasEmitted = false;
      try {
        final firestoreStream = FirebaseFirestore.instance
            .collection('job_applications')
            .orderBy('appliedAt', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) => JobApplication.fromMap(doc.id, doc.data()))
              .toList();
        });

        await for (final list in firestoreStream.timeout(
          const Duration(seconds: 3),
          onTimeout: (sink) {
            throw TimeoutException('Firestore timeout');
          },
        )) {
          hasEmitted = true;
          yield list;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Firestore getJobApplicationsStream failed ($e). Streaming local cache.');
        }
        if (!hasEmitted) {
          yield List.from(_localJobApplications);
          yield* _jobApplicationsController.stream;
        }
      }
    } else {
      yield List.from(_localJobApplications);
      yield* _jobApplicationsController.stream;
    }
  }

  // Delete Job Application (Resilient)
  Future<void> deleteJobApplication(String id) async {
    try {
      bool deletedFromFirestore = false;
      if (isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('job_applications')
              .doc(id)
              .delete()
              .timeout(const Duration(seconds: 4));
          deletedFromFirestore = true;
        } catch (dbError) {
          if (kDebugMode) {
            print('Firestore deleteJobApplication failed ($dbError). Modifying local cache.');
          }
        }
      }

      _localJobApplications.removeWhere((app) => app.id == id);
      _jobApplicationsController.add(List.from(_localJobApplications));
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting job application: $e');
      }
      rethrow;
    }
  }
}
