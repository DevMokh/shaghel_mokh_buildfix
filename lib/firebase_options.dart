// Firebase configuration for the Android app registered in Firebase Console.
// This file currently configures Android only. Add platform-specific options
// through FlutterFire CLI after registering each additional platform.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase Web is not configured yet. Register a Web app in Firebase Console and run FlutterFire configuration.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase is configured for Android only. Configure this platform before running the app on it.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACf58Ag_Ima43ecAXNX57n__sU53hzqyU',
    appId: '1:55197254643:android:35a02175b705725ba30886',
    messagingSenderId: '55197254643',
    projectId: 'shaghel-mokh',
    storageBucket: 'shaghel-mokh.firebasestorage.app',
  );
}
