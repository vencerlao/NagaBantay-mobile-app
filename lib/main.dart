import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nagabantay_mobile_app/pages/signup_page.dart';
import 'package:nagabantay_mobile_app/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);
    final appBarTheme = AppBarTheme(
      titleTextStyle: GoogleFonts.montserrat(
        textStyle: Theme.of(context).textTheme.titleLarge,
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
        textTheme: textTheme,
        appBarTheme: appBarTheme,
        scaffoldBackgroundColor: Colors.white,
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
      // Ensure the white background fills the full screen
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple placeholder content for the homepage
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
            Text(
              'Welcome to Nagabantay',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text('You have pushed the button this many times:'),
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
              child: const Text('Go to Sign Up'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      // Removed invalid `home:` parameter that caused analyzer errors
    );
  }
}
