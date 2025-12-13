// lib/src/core/firebase_init.dart
// Initialize Firebase with default options
// Firebase settings will use native config files (google-services.json / GoogleService-Info.plist)

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> initFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NOTE: This assumes native config files are added for Android & iOS.
  // If using web, configure Firebase options for web separately.
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
}
