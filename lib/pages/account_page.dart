import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nagabantay_mobile_app/services/local_auth_store.dart';
import 'package:nagabantay_mobile_app/pages/splash_page.dart';

import 'personal_information_page.dart';
import 'about_us_page.dart';
import 'terms_page.dart';
import 'privacy_policy_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // Normalize phone: digits only, keep last 10 digits if longer
  String _normalizePhone(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length > 10 ? digitsOnly.substring(digitsOnly.length - 10) : digitsOnly;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userDocStream() {
    return FirebaseAuth.instance.authStateChanges().asyncExpand((user) {
      String? docId;

      if (user != null && user.phoneNumber != null) {
        docId = _normalizePhone(user.phoneNumber!);
        debugPrint('Account 🔥 DOC ID (auth): $docId');
      }

      if (docId == null) {
        final stored = LocalAuthStore.loggedPhone;
        if (stored != null && stored.isNotEmpty) {
          docId = _normalizePhone(stored);
          debugPrint('Account 🔥 DOC ID (local): $docId');
        }
      }

      if (docId == null || docId.isEmpty) return const Stream.empty();

      return FirebaseFirestore.instance.collection('users').doc(docId).snapshots();
    });
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    DateTime dt;
    if (value is Timestamp) {
      dt = value.toDate();
    } else if (value is DateTime) {
      dt = value;
    } else {
      return '-';
    }

    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// ================= HEADER =================
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
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _userDocStream(),
                    builder: (context, snapshot) {
                      String name = 'NAME PLACEHOLDER';
                      String barangay = 'Address Placeholder';
                      String joined = '-';

                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() ?? {};
                        final firstName = (data['firstName'] ?? '').toString();
                        final lastName = (data['lastName'] ?? '').toString();

                        name = (firstName.isNotEmpty || lastName.isNotEmpty)
                            ? '$firstName $lastName'.trim()
                            : 'NAME PLACEHOLDER';

                        barangay = (data['barangay'] ?? '').toString();
                        if (barangay.isEmpty) barangay = 'Address Placeholder';

                        joined = _formatDate(data['createdAt']);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 22,
                              fontVariations: [FontVariation('wght', 600)],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Barangay',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 14,
                              fontVariations: [FontVariation('wght', 300)],
                            ),
                          ),
                          Text(
                            barangay,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontVariations: [FontVariation('wght', 700)],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Date Joined',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 14,
                              fontVariations: [FontVariation('wght', 300)],
                            ),
                          ),
                          Text(
                            joined,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontVariations: [FontVariation('wght', 700)],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Image.asset(
                  'assets/images/nagabantay_logo.png',
                  height: 50,
                ),
              ],
            ),
          ),

          /// ================= MENU =================
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
                      MaterialPageRoute(builder: (_) => const PersonalInformationPage()),
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
                      MaterialPageRoute(builder: (_) => const AboutUsPage()),
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
                      MaterialPageRoute(builder: (_) => const TermsPage()),
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
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Log out',
                  isLogout: true,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 36,
                      fontVariations: [FontVariation('wght', 800)],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you logging out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
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
                    fontFamily: 'Montserrat',
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SplashPage()),
                            (route) => false,
                      );
                    },
                    child: const Text(
                      'Log out',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 16,
                        fontVariations: [FontVariation('wght', 600)],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: Icon(
            icon,
            color: isLogout ? Colors.red[400] : const Color(0xFF06370b),
            size: 28,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: isLogout ? Colors.red[400] : const Color(0xFF06370b),
              fontSize: 16,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          trailing: isLogout ? null : Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}