import 'dart:async';
import 'dart:convert';
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

  final List<Map<String, dynamic>> _localInquiries = [];
  final StreamController<List<Map<String, dynamic>>> _inquiriesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

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
        
        final snapshot = await uploadTask;
        resumeUrl = await snapshot.ref.getDownloadURL();
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

      if (isFirebaseInitialized) {
        await FirebaseFirestore.instance.collection('inquiries').add(inquiryData);
      } else {
        final mockId = DateTime.now().millisecondsSinceEpoch.toString();
        final localData = {
          'id': mockId,
          ...inquiryData,
          'submittedAt': DateTime.now(), // Use standard DateTime for mock local list
        };
        _localInquiries.insert(0, localData);
        _inquiriesController.add(List.from(_localInquiries));
        if (kDebugMode) {
          print('Demo Mode: Contact inquiry submitted locally -> $localData');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting contact inquiry: $e');
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
  Future<void> submitTestimonial(
    Testimonial testimonial, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      String? imageUrl = testimonial.imageUrl;

      if (isFirebaseInitialized && imageBytes != null && imageName != null) {
        try {
          // Upload testimonial photo to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('testimonials/${DateTime.now().millisecondsSinceEpoch}_$imageName');
          
          final uploadTask = storageRef.putData(
            imageBytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (storageError) {
          if (kDebugMode) {
            print('Firebase Storage upload failed: $storageError. Falling back to local Base64.');
          }
          // Fallback to Base64 data URI if storage fails
          final base64Str = base64Encode(imageBytes);
          final extension = imageName.split('.').last.toLowerCase();
          final mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';
          imageUrl = 'data:$mimeType;base64,$base64Str';
        }
      } else if (imageBytes != null && imageName != null) {
        // Convert to data URI for local display in Demo mode
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

      if (isFirebaseInitialized) {
        await FirebaseFirestore.instance
            .collection('testimonials')
            .add(finalTestimonial.toMap());
      } else {
        // Add to local list and notify stream
        _localTestimonials.insert(0, finalTestimonial);
        _testimonialsController.add(List.from(_localTestimonials));
        if (kDebugMode) {
          print('Demo Mode: Testimonial submitted locally -> ${finalTestimonial.toMap()}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting testimonial: $e');
      }
      rethrow;
    }
  }

  // Get Inquiries Stream (Realtime)
  Stream<List<Map<String, dynamic>>> getInquiriesStream() async* {
    if (isFirebaseInitialized) {
      yield* FirebaseFirestore.instance
          .collection('inquiries')
          .orderBy('submittedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
              };
            })
            .toList();
      });
    } else {
      yield List.from(_localInquiries);
      yield* _inquiriesController.stream;
    }
  }

  // Delete Inquiry
  Future<void> deleteInquiry(String id) async {
    try {
      if (isFirebaseInitialized) {
        await FirebaseFirestore.instance.collection('inquiries').doc(id).delete();
      } else {
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

  // Update Testimonial
  Future<void> updateTestimonial(
    Testimonial testimonial, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      String? imageUrl = testimonial.imageUrl;

      if (isFirebaseInitialized && imageBytes != null && imageName != null) {
        try {
          // Upload testimonial photo to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('testimonials/${DateTime.now().millisecondsSinceEpoch}_$imageName');
          
          final uploadTask = storageRef.putData(
            imageBytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (storageError) {
          if (kDebugMode) {
            print('Firebase Storage upload failed: $storageError. Falling back to local Base64.');
          }
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

      if (isFirebaseInitialized) {
        await FirebaseFirestore.instance
            .collection('testimonials')
            .doc(updatedTestimonial.id)
            .update(updatedTestimonial.toMap());
      } else {
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

  // Delete Testimonial
  Future<void> deleteTestimonial(String id) async {
    try {
      if (isFirebaseInitialized) {
        await FirebaseFirestore.instance
            .collection('testimonials')
            .doc(id)
            .delete();
      } else {
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
}
