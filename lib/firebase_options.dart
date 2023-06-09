// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD2Cq7sBYV_GcP7QkOxSCUmCMSNXRb7Om8',
    appId: '1:660629417133:web:d1d60a74659cbf85692a24',
    messagingSenderId: '660629417133',
    projectId: 'fbla-22',
    authDomain: 'fbla-22.firebaseapp.com',
    storageBucket: 'fbla-22.appspot.com',
    measurementId: 'G-WSHF91GG7K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAL5KibX55Cx4A_3uKaJGqH8EGBcWZjTy8',
    appId: '1:660629417133:android:2dde4d75fb0ae854692a24',
    messagingSenderId: '660629417133',
    projectId: 'fbla-22',
    storageBucket: 'fbla-22.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAiBq2mLZtKYujY3xzlK2INdwhdO4IZPk4',
    appId: '1:660629417133:ios:84aa2baa27580441692a24',
    messagingSenderId: '660629417133',
    projectId: 'fbla-22',
    storageBucket: 'fbla-22.appspot.com',
    iosClientId: '660629417133-qs67odth498qjpb25ikgkv0709mpafe5.apps.googleusercontent.com',
    iosBundleId: 'com.example.fblaApp22',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAiBq2mLZtKYujY3xzlK2INdwhdO4IZPk4',
    appId: '1:660629417133:ios:84aa2baa27580441692a24',
    messagingSenderId: '660629417133',
    projectId: 'fbla-22',
    storageBucket: 'fbla-22.appspot.com',
    iosClientId: '660629417133-qs67odth498qjpb25ikgkv0709mpafe5.apps.googleusercontent.com',
    iosBundleId: 'com.example.fblaApp22',
  );
}
