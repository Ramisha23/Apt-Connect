import 'package:aptconnect/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aptconnect/splashScreen.dart'; 


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCBrn7eQzuxKp9WL4MhDtHDU51z0dT8zjE',
      appId: '1:336770537635:android:df03ac91d85617102bc716',
      messagingSenderId: '336770537635',
      projectId: 'aptconnect-15f20',
      storageBucket:'aptconnect-15f20.appspot.com',
    ),
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), 
    );
  }
}
