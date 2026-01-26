import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen height for responsive spacing
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // === Blank space above everything ===
              SizedBox(height: screenHeight * 0.15), // <-- Adjust to raise/lower all content

              // === Logo + Text beside it ===
              Align(
                alignment: Alignment.centerLeft, // align the whole row to the left
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // vertically center the text with the logo
                  children: [
                    Image.asset(
                      'assets/images/nagabantay_logo.png',
                      height: 60, // logo size
                    ),
                    const SizedBox(width: 15), // space between logo and text
                    Text(
                      'Nagabantay',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF23552C),
                      ),
                    ),
                  ],
                ),
              ),


              // === Space between logo and welcome message ===
              SizedBox(height: screenHeight * 0.03), // adjust spacing

              // === Welcome Message ===
              const Align(
                alignment: Alignment.center, // horizontal alignment
                child: Text(
                  'Welcome to Nagabantay!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              // === Space between headline and instruction ===
              SizedBox(height: screenHeight * 0.015), // adjust spacing

              // === Instructional Message ===
              const Align(
                alignment: Alignment.center, // horizontal alignment
                child: Text(
                  'Sign up with your mobile number to continue.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

              // === Space between message and input box ===
              SizedBox(height: screenHeight * 0.03), // adjust spacing

              // === Phone Input Box ===
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('+63'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your phone number',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 7) {
                          return 'Invalid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // === Space between input box and continue button ===
              SizedBox(height: screenHeight * 0.03), // adjust spacing

              // === Continue Button ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Continue', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),

              // === Space between button and terms message ===
              SizedBox(height: screenHeight * 0.02), // adjust spacing

              // === Terms & Privacy ===
              Align(
                alignment: Alignment.center,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Optional: Extra space at the bottom for small screens
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
