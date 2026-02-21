import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nagabantay_mobile_app/services/local_auth_store.dart';
import 'package:nagabantay_mobile_app/pages/splash_page.dart';
import 'package:nagabantay_mobile_app/pages/home_page.dart' show ReportsListPage;
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
  static const Color primaryGreen = Color(0xFF06370B);

  String _normalizePhone(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length > 10
        ? digitsOnly.substring(digitsOnly.length - 10)
        : digitsOnly;
  }

  String _getUserPhoneId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      return _normalizePhone(user.phoneNumber!);
    }
    final stored = LocalAuthStore.loggedPhone;
    if (stored != null && stored.isNotEmpty) {
      return _normalizePhone(stored);
    }
    return '';
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userDocStream() {
    return FirebaseAuth.instance.authStateChanges().asyncExpand((user) {
      String? docId;
      if (user != null && user.phoneNumber != null) {
        docId = _normalizePhone(user.phoneNumber!);
      }
      if (docId == null) {
        final stored = LocalAuthStore.loggedPhone;
        if (stored != null && stored.isNotEmpty) {
          docId = _normalizePhone(stored);
        }
      }
      if (docId == null || docId.isEmpty) return const Stream.empty();
      return FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .snapshots();
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
      '',
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
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
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _userDocStream(),
                    builder: (context, snapshot) {
                      String name = 'NAME PLACEHOLDER';
                      String barangay = 'Address Placeholder';
                      String joined = '-';
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() ?? {};
                        final firstName =
                        (data['firstName'] ?? '').toString();
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              children: [
                _buildTile(
                  context,
                  icon: PhosphorIcons.chartBarFill,
                  title: 'Report Status',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReportStatusPage(userPhoneId: _getUserPhoneId()),
                    ),
                  ),
                ),
                _buildTile(
                  context,
                  icon: PhosphorIcons.userCircle,
                  title: 'Personal Information',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PersonalInformationPage()),
                  ),
                ),
                _buildTile(
                  context,
                  icon: PhosphorIcons.handshake,
                  title: 'About Us',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsPage()),
                  ),
                ),
                _buildTile(
                  context,
                  icon: PhosphorIcons.fileText,
                  title: 'Terms and Conditions',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsPage()),
                  ),
                ),
                _buildTile(
                  context,
                  icon: PhosphorIcons.shieldWarning,
                  title: 'Privacy Policy',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage()),
                  ),
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
            color: isLogout ? Colors.red[400] : primaryGreen,
            size: 28,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: isLogout ? Colors.red[400] : primaryGreen,
              fontSize: 16,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          trailing: isLogout
              ? null
              : Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}

class ReportStatusPage extends StatelessWidget {
  final String userPhoneId;

  const ReportStatusPage({super.key, required this.userPhoneId});

  static const Color primaryGreen = Color(0xFF0F4A17);
  static const Color tileBg = Color(0xFFe6efe5);
  static const Color tileBorder = Color(0xFFB7D1BB);

  static const List<_StatusEntry> _entries = [
    _StatusEntry(
      icon: PhosphorIcons.checkCircleFill,
      label: 'Completed',
      subtitle: 'Reports resolved and closed',
      statusFilter: 'done',
      accent: Color(0xFF2E7D32),
    ),
    _StatusEntry(
      icon: PhosphorIcons.starFill,
      label: 'For Rating',
      subtitle: 'Reports awaiting your review',
      statusFilter: 'awaiting review',
      accent: Color(0xFFF9A825),
    ),
    _StatusEntry(
      icon: PhosphorIcons.fileTextFill,
      label: 'Submitted',
      subtitle: 'Reports not yet responded to',
      statusFilter: 'not yet responded',
      accent: Color(0xFF1565C0),
    ),
    _StatusEntry(
      icon: PhosphorIcons.hourglassFill,
      label: 'Pending',
      subtitle: 'Reports currently being processed',
      statusFilter: 'pending',
      accent: Color(0xFFE65100),
    ),
    _StatusEntry(
      icon: PhosphorIcons.xCircleFill,
      label: 'Cancelled',
      subtitle: 'Reports that were cancelled',
      statusFilter: 'cancelled',
      accent: Color(0xFF757575),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Report Status',
          style: TextStyle(
            color: primaryGreen,
            fontFamily: 'Montserrat',
            fontVariations: [FontVariation('wght', 700)],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userPhoneId.isEmpty
          ? _buildList(context,
          counts: {for (final e in _entries) e.statusFilter: 0})
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('phone', isEqualTo: userPhoneId)
            .snapshots(),
        builder: (context, snapshot) {
          final counts = <String, int>{
            for (final e in _entries) e.statusFilter: 0,
          };
          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final raw = (doc.data()['my_naga_status'] ?? '')
                  .toString()
                  .trim()
                  .toLowerCase();
              final String mapped;
              if (raw == 'done' || raw == 'completed') {
                mapped = 'done';
              } else if (raw == 'awaiting review' ||
                  raw == 'awaiting_review') {
                mapped = 'awaiting review';
              } else if (raw == 'not yet responded' ||
                  raw == 'not_yet_responded') {
                mapped = 'not yet responded';
              } else if (raw == 'pending') {
                mapped = 'pending';
              } else if (raw == 'cancelled' || raw == 'canceled') {
                mapped = 'cancelled';
              } else {
                continue;
              }
              counts[mapped] = (counts[mapped] ?? 0) + 1;
            }
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildList(context, counts: counts);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context,
      {required Map<String, int> counts}) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final entry = _entries[i];
        final count = counts[entry.statusFilter] ?? 0;
        return _statusTile(context, entry: entry, count: count);
      },
    );
  }

  Widget _statusTile(
      BuildContext context, {
        required _StatusEntry entry,
        required int count,
      }) {
    return GestureDetector(
      onTap: userPhoneId.isEmpty
          ? null
          : () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportsListPage(
            title: entry.label,
            userPhone: userPhoneId,
            statusFilter: entry.statusFilter,
          ),
        ),
      ),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tileBorder, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: entry.accent.withAlpha(28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(entry.icon, size: 26, color: entry.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontVariations: const [FontVariation('wght', 600)],
                      color: entry.accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.subtitle,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontVariations: [FontVariation('wght', 400)],
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 32),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: entry.accent.withAlpha(28),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: entry.accent.withAlpha(80), width: 1),
              ),
              child: Text(
                count.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontVariations: const [FontVariation('wght', 700)],
                  color: entry.accent,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                size: 22, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _StatusEntry {
  final IconData icon;
  final String label;
  final String subtitle;
  final String statusFilter;
  final Color accent;

  const _StatusEntry({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.statusFilter,
    required this.accent,
  });
}