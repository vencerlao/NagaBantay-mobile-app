import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:nagabantay_mobile_app/pages/splash_page.dart';
import 'package:nagabantay_mobile_app/auth_gate.dart';
import 'package:nagabantay_mobile_app/pages/signup_page.dart';
import 'package:nagabantay_mobile_app/pages/home_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appBarTheme = AppBarTheme(
      titleTextStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: Colors.white,
      ),
    );

    return MaterialApp(
      title: 'Nagabantay',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        appBarTheme: appBarTheme,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),

      // 👇 Splash decides where to go next
      home: const SplashPage(),

      // 👇 Centralized routing (prevents import errors later)
      routes: {
        '/auth': (context) => const AuthGate(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
