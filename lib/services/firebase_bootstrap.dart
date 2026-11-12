import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Initializes Firebase without preventing the offline game from opening
/// when Firebase configuration or network services are temporarily unavailable.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool isInitialized = false;
  static Object? initializationError;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      isInitialized = true;
      initializationError = null;
    } catch (error, stackTrace) {
      initializationError = error;
      isInitialized = false;
      debugPrint('Firebase initialization failed; continuing offline: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
