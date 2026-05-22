import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'placeholder-web-api-key',
    appId: '1:000000000000:web:placeholder',
    messagingSenderId: '000000000000',
    projectId: 'giggl-placeholder',
    authDomain: 'giggl-placeholder.firebaseapp.com',
    storageBucket: 'giggl-placeholder.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'placeholder-android-api-key',
    appId: '1:000000000000:android:placeholder',
    messagingSenderId: '000000000000',
    projectId: 'giggl-placeholder',
    storageBucket: 'giggl-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder-ios-api-key',
    appId: '1:000000000000:ios:placeholder',
    messagingSenderId: '000000000000',
    projectId: 'giggl-placeholder',
    storageBucket: 'giggl-placeholder.appspot.com',
    iosBundleId: 'com.giggl.giggl',
  );
}
