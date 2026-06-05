import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for the web platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCOztdrT-qeNyAswj5IH6XMVDy7PgXTqIA',
    authDomain: 'avmglobal-consultants-113.firebaseapp.com',
    projectId: 'avmglobal-consultants-113',
    storageBucket: 'avmglobal-consultants-113.firebasestorage.app',
    messagingSenderId: '650421354673',
    appId: '1:650421354673:web:5d6ccc5d8ed821000fa290',
  );
}
