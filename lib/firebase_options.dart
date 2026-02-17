// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDPSER5P4IJLV8zewCibG3IOU-__-HCYdk',
      appId: '1:298905967790:android:0a17e3e8a7a10f88d8e13f',
      messagingSenderId: '298905967790',
      projectId: 'smart-helmet-fb2cf',
      storageBucket: 'smart-helmet-fb2cf.appspot.com',
      databaseURL: 'https://smart-helmet-fb2cf-default-rtdb.europe-west1.firebasedatabase.app',
    );
  }
}