import 'dart:async';
import 'dart:js' as js;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _cachedToken;
  bool _isInitialized = false;

  /// Returns cached or fresh FCM token
  String? get cachedToken => _cachedToken;

  static const String vapidKey =
      'BOeWx1VSPrUPEUhTA14tZb5fTcSmznfPwyGOWFd6na-PF4FVSYBNbsfmqVcPDfTDfuYkKkvMaop-oKDaT-zq26A';

  /// Initialize Firebase Messaging listeners
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure foreground notification presentation options
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Foreground FCM Message received: ${message.notification?.title}');
        }
        try {
          if (kIsWeb && js.context.hasProperty('showWebNotification')) {
            final title = message.notification?.title ??
                message.data['jobTitle'] ??
                'New Job Alert | AVM Global';
            final body = message.notification?.body ??
                message.data['body'] ??
                'Exciting new opening matching your profile is live!';
            final url = message.data['url'] ?? message.data['click_action'] ?? '/jobs';
            js.context.callMethod('showWebNotification', [title, body, url]);
          }
        } catch (e) {
          if (kDebugMode) {
            print('showWebNotification error: $e');
          }
        }
      });

      // Token refresh listener
      _fcm.onTokenRefresh.listen((newToken) {
        _cachedToken = newToken;
        if (kDebugMode) {
          print('FCM Token refreshed: $newToken');
        }
      });

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService initialize warning: $e');
      }
    }
  }

  /// Request Notification Permissions from user's web browser
  Future<NotificationSettings?> requestPermission() async {
    if (kIsWeb) {
      try {
        if (js.context.hasProperty('Notification')) {
          js.context.callMethod('eval', [
            "if (typeof Notification !== 'undefined') { Notification.requestPermission(); }"
          ]);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Web requestPermission warning: $e');
        }
      }
      return null;
    }

    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (kDebugMode) {
        print('FCM AuthorizationStatus: ${settings.authorizationStatus}');
      }
      return settings;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permission: $e');
      }
      return null;
    }
  }

  /// Helper to resolve token via JS bridge if running on Web
  Future<String?> _getTokenViaJs(String key) {
    final completer = Completer<String?>();
    try {
      if (kIsWeb && js.context.hasProperty('getFcmWebTokenCallback')) {
        js.context.callMethod('getFcmWebTokenCallback', [
          key,
          js.allowInterop((token) {
            if (!completer.isCompleted) {
              completer.complete(token != null ? token.toString() : null);
            }
          })
        ]);
      } else {
        completer.complete(null);
      }
    } catch (e) {
      if (!completer.isCompleted) completer.complete(null);
    }
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
  }

  /// Fetch active FCM Web browser token with dual resolution and retry
  Future<String?> getDeviceToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) return _cachedToken;

    // 1. First attempt direct JS token resolution
    if (kIsWeb) {
      try {
        final jsToken = await _getTokenViaJs(vapidKey);
        if (jsToken != null && jsToken.isNotEmpty) {
          _cachedToken = jsToken;
          if (kDebugMode) {
            print('FCM Token resolved via JS SDK: $jsToken');
          }
          return jsToken;
        }
      } catch (jsErr) {
        if (kDebugMode) {
          print('JS Token resolver warning: $jsErr');
        }
      }
    }

    // 2. Fallback to FlutterFire FCM plugin with retries
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final token = await _fcm.getToken(
          vapidKey: kIsWeb ? vapidKey : null,
        );
        if (token != null && token.isNotEmpty) {
          _cachedToken = token;
          if (kDebugMode) {
            print('FCM Web Token successfully generated via plugin: $token');
          }
          return token;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error retrieving FCM token (attempt ${attempt + 1}): $e');
        }
      }
      if (attempt < 2) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return _cachedToken;
  }

  /// Helper to sanitize search query for FCM Topic format:
  /// Must match [a-zA-Z0-9-_.~%]{1,900}
  static String sanitizeTopic(String query) {
    final sanitized = query
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    final finalKey = sanitized.isEmpty ? 'general' : sanitized;
    return 'job_search_$finalKey';
  }

  /// Subscribe active web browser to a debounced Search Topic
  Future<bool> subscribeToSearchTopic(String query) async {
    if (query.trim().isEmpty) return false;

    try {
      NotificationSettings? settings;
      try {
        settings = await requestPermission();
      } catch (permError) {
        if (kDebugMode) {
          print('Permission request error: $permError');
        }
      }

      // Wait up to 3 seconds for token to resolve after permission prompt
      String? token = await getDeviceToken();
      if (token == null || token.isEmpty) {
        for (int i = 0; i < 6; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          token = await getDeviceToken();
          if (token != null && token.isNotEmpty) break;
        }
      }

      final topicName = sanitizeTopic(query);

      // Attempt client-side topic subscription if supported
      try {
        await _fcm.subscribeToTopic(topicName);
      } catch (topicError) {
        if (kDebugMode) {
          print('Client topic subscription note: $topicError');
        }
      }

      // Persist topic subscription to Firestore for server-side topic/token targeting
      final docId = (token != null && token.isNotEmpty)
          ? '${token.substring(0, token.length > 20 ? 20 : token.length)}_$topicName'
          : 'web_${DateTime.now().millisecondsSinceEpoch}_$topicName';

      await _firestore.collection('search_subscriptions').doc(docId).set({
        'fcmToken': token ?? '',
        'topic': topicName,
        'rawQuery': query.trim(),
        'subscribedAt': FieldValue.serverTimestamp(),
        'platform': 'web',
        'isAuthorized': settings?.authorizationStatus == AuthorizationStatus.authorized,
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('Saved search subscription to Firestore: $docId (Token: ${token != null && token.isNotEmpty})');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to search topic: $e');
      }
      return false;
    }
  }

  /// Track Direct Applicant details & token in the 'applicants' collection
  Future<void> registerApplicantNotification({
    required String phone,
    required String jobCategory,
    required String jobTitle,
    String? name,
    String? email,
  }) async {
    try {
      await requestPermission();
      final token = await getDeviceToken();

      final applicantData = {
        'applicantName': name ?? '',
        'applicantEmail': email ?? '',
        'applicantPhone': phone.trim(),
        'jobCategory': jobCategory.trim(),
        'jobTitle': jobTitle.trim(),
        'fcmToken': token ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'subscribedToAlerts': token != null && token.isNotEmpty,
      };

      // Key document by phone or generated ID
      final docKey = phone.isNotEmpty
          ? phone.replaceAll(RegExp(r'[^0-9]'), '')
          : (email ?? DateTime.now().millisecondsSinceEpoch.toString());

      await _firestore
          .collection('applicants')
          .doc(docKey.isEmpty ? 'anon_${DateTime.now().millisecondsSinceEpoch}' : docKey)
          .set(applicantData, SetOptions(merge: true));

      if (kDebugMode) {
        print('Saved applicant tracking details to applicants collection.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering applicant notification: $e');
      }
    }
  }

  /// Sync Registered User explicit skills & browser FCM token to the 'users' collection
  Future<void> syncUserSkillsAndToken({
    required String name,
    required String email,
    required String phone,
    required List<String> skills,
    String? userId,
  }) async {
    try {
      await requestPermission();
      final token = await getDeviceToken();

      final userData = {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'skills': skills.map((s) => s.trim().toLowerCase()).toList(),
        'rawSkills': skills,
        'fcmToken': token ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docId = userId ?? (email.isNotEmpty ? email.trim() : phone.trim());
      if (docId.isNotEmpty) {
        await _firestore.collection('users').doc(docId).set(userData, SetOptions(merge: true));
      }

      if (kDebugMode) {
        print('Synced user skills and FCM token to users collection: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing user skills and token: $e');
      }
    }
  }
}
