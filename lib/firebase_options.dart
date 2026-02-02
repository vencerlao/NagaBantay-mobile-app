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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAVoghFOOiZwimjT48hG_Sp-GMLlhDgUAI',
    appId: '1:92668872053:web:a48bc62366aadb60dd7f3c',
    messagingSenderId: '92668872053',
    projectId: 'nagabantay',
    authDomain: 'nagabantay.firebaseapp.com',
    storageBucket: 'nagabantay.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDhvHgeH_nfCMO3d1KwDQGZeKhXa6bvT58',
    appId: '1:92668872053:android:517afa54c3e1713add7f3c',
    messagingSenderId: '92668872053',
    projectId: 'nagabantay',
    storageBucket: 'nagabantay.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAU2t95OvlGME4m1FKGb8Pdb8c2gBIoTPw',
    appId: '1:92668872053:ios:9211c4909742d3fedd7f3c',
    messagingSenderId: '92668872053',
    projectId: 'nagabantay',
    storageBucket: 'nagabantay.firebasestorage.app',
    iosBundleId: 'com.example.nagabantay_mobile_app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAU2t95OvlGME4m1FKGb8Pdb8c2gBIoTPw',
    appId: '1:92668872053:ios:9211c4909742d3fedd7f3c',
    messagingSenderId: '92668872053',
    projectId: 'nagabantay',
    storageBucket: 'nagabantay.firebasestorage.app',
    iosBundleId: 'com.example.nagabantay_mobile_app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAVoghFOOiZwimjT48hG_Sp-GMLlhDgUAI',
    appId: '1:92668872053:web:273c745e7478d4a6dd7f3c',
    messagingSenderId: '92668872053',
    projectId: 'nagabantay',
    authDomain: 'nagabantay.firebaseapp.com',
    storageBucket: 'nagabantay.firebasestorage.app',
  );
}
