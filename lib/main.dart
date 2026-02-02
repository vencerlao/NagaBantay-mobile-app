import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'pages/splash_page.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (_) {}

  final mapboxToken = dotenv.env['MAPBOX_API_KEY'];
  if (mapboxToken != null && mapboxToken.isNotEmpty) {
    MapboxOptions.setAccessToken(mapboxToken);
    debugPrint('Mapbox token initialized');
  } else {
    debugPrint('⚠️ Mapbox token NOT found');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

      home: const SplashPage(),
      routes: {
        '/auth': (context) => const AuthGate(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => HomePage(phoneNumber: 'default-number'),
      },
    );
  }
}
