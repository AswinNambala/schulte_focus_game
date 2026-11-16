// File generated for Schulte Focus Android project
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDonyB5ILx-qPoRTAYsD3F2cXKKYlyIP04',
    appId: '1:2533456476:android:fc2543d687aae6fead4499',
    messagingSenderId: '2533456476',
    projectId: 'schulte-focus-2026',
    storageBucket: 'schulte-focus-2026.firebasestorage.app',
  );
}
