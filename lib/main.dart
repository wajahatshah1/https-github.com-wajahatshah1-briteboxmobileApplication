import 'dart:io';

import 'package:Britebox/AuthenticationPages/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Britebox/Splash%20Screen/SplashScreen.dart';

import 'MainPage/HomePage.dart';
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: Platform.isAndroid
        ? const FirebaseOptions(
      apiKey: 'AIzaSyC-Ncl64E8up7c0yaLvOhJ9pjWa9xQavGs',
      appId: '1:160047376958:android:cf88e43fc15d4aab493f6f',
      projectId: 'britebox-d4790',
      messagingSenderId: '160047376958',
    )
        : null, // Use default options for iOS if you have them
  );
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  if (Firebase.apps.isEmpty) {
    // Initialize Firebase for both Android and iOS
    await Firebase.initializeApp(
      options: Platform.isAndroid
          ? const FirebaseOptions(
        apiKey: 'AIzaSyC-Ncl64E8up7c0yaLvOhJ9pjWa9xQavGs',
        appId: '1:160047376958:android:cf88e43fc15d4aab493f6f',
        projectId: 'britebox-d4790',
        messagingSenderId: '160047376958',
      )
          : null, // Use default options for iOS if you have them
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      initialRoute: '/',
      routes: {
        "/authentication": (context) => AuthenticationPage(),
        "/homescreen": (context) => HomeScreen(),
      },
    );
  }
}
