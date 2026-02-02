import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'personal_information_page.dart';
import 'about_us_page.dart';
import 'terms_page.dart';
import 'privacy_policy_page.dart';
import 'package:nagabantay_mobile_app/pages/splash_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.redAccent,
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you logging out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 700)],
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You can always log back in at any time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 400)],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);

                      try {
                        await FirebaseAuth.instance.signOut();
                      } catch (_) {
                      }

                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const SplashPage(),
                        ),
                            (route) => false,
                      );

                    },
                    child: const Text(
                      'Log out',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontVariations: [FontVariation('wght', 500)],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF255e1f)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF255e1f),
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontVariations: [FontVariation('wght', 500)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 100, 25, 40),
            decoration: const BoxDecoration(
              color: Color(0xFF063B13),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'NAME PLACEHOLDER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontVariations: [FontVariation('wght', 600)],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Barangay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontVariations: [FontVariation('wght', 300)],
                        ),
                      ),
                      Text(
                        'Address Placeholder',
                        style: TextStyle(
                          color: Colors.white,
                          fontVariations: [FontVariation('wght', 700)],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Date Joined',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontVariations: [FontVariation('wght', 300)],
                        ),
                      ),
                      Text(
                        'January 25, 2026',
                        style: TextStyle(
                          color: Colors.white,
                          fontVariations: [FontVariation('wght', 700)],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/nagabantay_logo.png',
                  height: 50,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              children: [
                _buildTile(
                  context,
                  icon: PhosphorIcons.userCircle,
                  title: 'Personal Information',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalInformationPage(),
                      ),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: PhosphorIcons.handshake,
                  title: 'About Us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutUsPage(),
                      ),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: PhosphorIcons.fileText,
                  title: 'Terms and Conditions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsPage(),
                      ),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: PhosphorIcons.shieldWarning,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Log out',
                  isLogout: true,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        bool isLogout = false,
        VoidCallback? onTap,
      }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: Icon(
            icon,
            color: isLogout ? Colors.red[400] : const Color(0xFF06370b),
            size: 28,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isLogout ? Colors.red[400] : const Color(0xFF06370b),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing:
          isLogout ? null : Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}
