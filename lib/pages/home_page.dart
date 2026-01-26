import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Make the entire screen white so the white background occupies the whole viewport
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/nagabantay_app_logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'NagaBantay',
              style: TextStyle(
                color: Color(0xFF2E7D32), // green color
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          // Removed the inner decorated Container so the Scaffold's white fills the screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top spacing and title (kept for backward compatibility)
              const SizedBox(height: 8),
              // Fill rest of the screen for content
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}