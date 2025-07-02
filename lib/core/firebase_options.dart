// firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDyN04OHrIxzU0ie4WotIUhuvAbTBu1rBg',
    appId: '1:511512859233:web:ff8fe869e450f82ce0d020',
    messagingSenderId: '511512859233',
    projectId: 'pulmopulse-1fb57',
    authDomain: 'pulmopulse-1fb57.firebaseapp.com',
    storageBucket: 'pulmopulse-1fb57.appspot.com', // ✅ fix typo
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDyN04OHrIxzU0ie4WotIUhuvAbTBu1rBg',
    appId: '1:511512859233:web:7e27bfe4f1032235e0d020',
    messagingSenderId: '511512859233',
    projectId: 'pulmopulse-1fb57',
    authDomain: 'pulmopulse-1fb57.firebaseapp.com',
    storageBucket: 'pulmopulse-1fb57.appspot.com', // ✅ fix typo
  );
}
