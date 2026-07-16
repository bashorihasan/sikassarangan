import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVrZZUY5vfo1DKbQlSIPiM_P3EXOBgpkk',
    appId: '1:81038195391:android:0f2394bcdfce6f48eda40a',
    messagingSenderId: '81038195391',
    projectId: 'sikas-sarangan',
    storageBucket: 'sikas-sarangan.firebasestorage.app',
  );
}