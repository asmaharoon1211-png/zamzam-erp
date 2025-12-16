// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_1cMic-B8DyXFbVt-s5kxMNTtFoVkEcE',
    appId: '1:535434587724:web:6275970f812f4aa9638ee9',
    messagingSenderId: '535434587724',
    projectId: 'zamzam-erp-solution',
    authDomain: 'zamzam-erp-solution.firebaseapp.com',
    storageBucket: 'zamzam-erp-solution.firebasestorage.app',
    measurementId: 'G-07THJNHWDF',
  );
}
