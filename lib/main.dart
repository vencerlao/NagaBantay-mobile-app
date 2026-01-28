import 'package:flutter/material.dart';
import 'package:nagabantay_mobile_app/pages/signup_page.dart';
import 'package:nagabantay_mobile_app/pages/splash_page.dart';
import 'package:nagabantay_mobile_app/widgets/navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AppBar theme using local Montserrat font
    final appBarTheme = AppBarTheme(
      titleTextStyle: const TextStyle(
        fontFamily: 'Montserrat', // local font family
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
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/images/nagabantay_app_logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            // Using local Montserrat via theme
            Text(
              'Welcome to Nagabantay',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'You have pushed the button this many times:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                );
              },
              child: const Text(
                'Go to Sign Up',
                style: TextStyle(
                  fontFamily: 'Montserrat', // ensure local font
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}