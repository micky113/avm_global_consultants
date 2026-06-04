import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/testimonial.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();

  FirebaseService._internal() {
    _initFallbackTestimonials();
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
      ),
      Testimonial(
        id: '2',
        name: 'Priya Patel',
        roleAndCountry: 'Head Nurse, Canada',
        reviewText:
            'Very professional services. They helped me with credential evaluation, IELTS prep recommendations, and matched me with a fantastic healthcare provider in Ontario.',
        rating: 5.0,
        timestamp: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Testimonial(
        id: '3',
        name: 'Anil Kumar',
        roleAndCountry: 'Operations Manager, Dubai',
        reviewText:
            'Great experience with the recruitment team. They kept me updated at every stage of my application. I highly recommend AVM for Gulf opportunities.',
        rating: 4.0,
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
    _testimonialsController.add(_localTestimonials);
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
        // Upload resume to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('resumes/${DateTime.now().millisecondsSinceEpoch}_$resumeFileName');
        
        final uploadTask = storageRef.putData(
          resumeFileBytes,
          SettableMetadata(contentType: 'application/pdf'),
        );
        
        final snapshot = await uploadTask;
        resumeUrl = await snapshot.ref.getDownloadURL();
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
        await FirebaseFirestore.instance.collection('candidates').add(candidateData);
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

  // Get Testimonials Stream (Realtime)
  Stream<List<Testimonial>> getTestimonialsStream() async* {
    if (isFirebaseInitialized) {
      yield* FirebaseFirestore.instance
          .collection('testimonials')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Testimonial.fromMap(doc.id, doc.data()))
            .toList();
      });
    } else {
      // Yield the current local testimonials list immediately,
      // and then yield any subsequent updates from the stream controller.
      yield List.from(_localTestimonials);
      yield* _testimonialsController.stream;
    }
  }

  // Submit Testimonial
  Future<void> submitTestimonial(Testimonial testimonial) async {
    try {
      if (isFirebaseInitialized) {
        await FirebaseFirestore.instance
            .collection('testimonials')
            .add(testimonial.toMap());
      } else {
        // Add to local list and notify stream
        _localTestimonials.insert(0, testimonial);
        _testimonialsController.add(List.from(_localTestimonials));
        if (kDebugMode) {
          print('Demo Mode: Testimonial submitted locally -> ${testimonial.toMap()}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting testimonial: $e');
      }
      rethrow;
    }
  }
}
