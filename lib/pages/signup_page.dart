import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


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

              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // align column with top of logo
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/nagabantay_logo.png',
                      height: 60,
                    ),
                    const SizedBox(width: 15), // space between logo and text
                    // Column for text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // align text to the left
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // First line
                        Text(
                          'Nagabantay',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 28,
                            color: const Color(0xFF23552C),
                            fontVariations: const [
                              FontVariation('wght', 700), // bold
                            ],
                          ),
                        ),
                        // Second line
                        Text(
                          'Parabantay nin gabos na barangay', // change to whatever you want
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: const Color(0xFF23552C),
                            fontVariations: const [
                              FontVariation('wght', 400), // normal weight
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // === Space between logo and welcome message ===
              SizedBox(height: screenHeight * 0.08), // adjust spacing

              // === Welcome Message ===
              const Align(
                alignment: Alignment.centerLeft, // horizontal alignment
                child: Text(
                  'Welcome to Nagabantay!',
                  style: TextStyle(fontFamily: 'Montserrat',
                    fontSize: 18,
                    color: const Color(0xFF23552C),
                    fontVariations: const [
                      FontVariation('wght', 700), // normal weight
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // === Space between headline and instruction ===
              SizedBox(height: screenHeight * 0.015), // adjust spacing

              // === Instructional Message ===
              const Align(
                alignment: Alignment.center, // horizontal alignment
                child: Text(
                  'Enter your phone number to log-in to an existing account or instantly set up your new account.',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 12,
                    color: const Color(0xFF23552C),
                    fontVariations: const [
                      FontVariation('wght', 400), // normal weight
                    ],),
                  textAlign: TextAlign.left,
                ),
              ),

              // === Space between message and input box ===
              SizedBox(height: screenHeight * 0.05), // adjust spacing

              // === Instructional Message ===
              const Align(
                alignment: Alignment.centerLeft, // horizontal alignment
                child: Text(
                  'Phone Number',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 16,
                    color: const Color(0xFF23552C),
                    fontVariations: const [
                      FontVariation('wght', 400), // normal weight
                    ],),
                  textAlign: TextAlign.left,
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
                      color: const Color(0xFFB0CEAC),
                      border: Border.all(color: const Color(0xFF23552C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+63', // no const here
                      style: TextStyle(
                        fontFamily: 'Montserrat',          // your installed font
                        fontSize: 14,                       // change to whatever size you want
                        fontVariations: const [
                          FontVariation('wght', 400),       // bold or normal
                        ],
                        color: const Color(0xFF23552C),    // your desired color
                      ),
                    ),

                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '9xx xxx xxxx',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',               // your installed font
                          fontSize: 14,                           // size of the hint
                          fontVariations: const [FontVariation('wght', 400)], // normal weight
                          color: const Color(0xFF23552C).withOpacity(0.5),   // hint color (semi-transparent)
                        ),
                        filled: true,
                        fillColor: Color(0xFFB0CEAC),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF23552C)), // border color when not focused
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF23552C), width: 2), // border color when focused
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(
                          PhosphorIcons.eye, // Phosphor icon
                          size: 28.0,
                          color: Color(0xFF06370B),
                        ),
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
              SizedBox(height: screenHeight * 0.05), // adjust spacing

              // === Continue Button ===
              SizedBox(
                width: double.infinity,
                height: 35,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF255E1F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), // optional: rounded corners
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,          // smaller font to fit
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  ),
                ),

              // === Space between button and terms message ===
              SizedBox(height: screenHeight * 0.2), // adjust spacing

              // === Terms & Privacy ===
              Align(
                alignment: Alignment.center,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: const TextStyle(
                      fontFamily: 'Montserrat', // your installed font
                      fontSize: 11,             // change font size
                      color: Color(0xFF23552C),
                      fontVariations: [FontVariation('wght', 400)],
                    ),
                    children: const [
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          color: Colors.blue,
                          fontVariations: [FontVariation('wght', 400)],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: ' and verify that you have read our',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          color: Color(0xFF23552C),
                          fontVariations: [FontVariation('wght', 400)],
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          color: Colors.blue,
                          fontVariations: [FontVariation('wght', 400)],
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
