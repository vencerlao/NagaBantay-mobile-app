import 'package:flutter/material.dart';
import 'package:nagabantay_mobile_app/pages/signup_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Make the entire screen white so the white background occupies the whole viewport
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          // Removed the inner decorated Container so the Scaffold's white fills the screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header: left image and right SIGN UP button
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Row(
                  children: [
                    // Left: nagabantay header image (constrained & fits)
                    Flexible(
                      flex: 0,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220, maxHeight: 56),
                        child: Image.asset(
                          'assets/images/nagabantay_header.png',
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Right: SIGN UP button that navigates to SignUpPage
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        minimumSize: const Size(100, 44),
                      ),
                      child: Text(
                        'SIGN UP',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // Fill rest of the screen for content
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}