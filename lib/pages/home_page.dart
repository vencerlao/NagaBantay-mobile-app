import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Theme Constants
  static const Color primaryGreen = Color(0xFF06370B);
  static const Color borderGreen = Color(0xFF669062);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildReportStatusSection(context),

              // This Spacer pushes all content above it to the top,
              // leaving the bottom area empty for your future map integration.
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with logic to prevent "Bad State" errors
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/images/nagabantay_header.png',
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.security, color: primaryGreen, size: 40),
        ),
        Flexible(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _userDocStream(),
            builder: (context, snapshot) {
              String greeting = 'Marhay na Aldaw!';
              if (snapshot.hasData && snapshot.data!.exists) {
                final name = snapshot.data!.get('firstName') ?? 'User';
                greeting = 'Marhay na Aldaw, $name!';
              }

              return Text(
                greeting,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: primaryGreen,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Main Status Section (Top-Aligned)
  Widget _buildReportStatusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Status',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 16),

        // TIER 1: Big Buttons (Completed & Ratings)
        Row(
          children: [
            Expanded(
              child: _bigStatusCard(
                icon: PhosphorIcons.checkCircleFill,
                label: 'Completed',
                count: 1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _bigStatusCard(
                icon: PhosphorIcons.starFill,
                label: 'Ratings',
                count: 0,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // TIER 2: Small Buttons (Submitted, Pending, Cancelled)
        Row(
          children: [
            _smallStatusChip(PhosphorIcons.fileTextFill, 'Submitted', 3),
            const SizedBox(width: 8),
            _smallStatusChip(PhosphorIcons.hourglassFill, 'Pending', 1),
            const SizedBox(width: 8),
            _smallStatusChip(PhosphorIcons.xCircleFill, 'Cancelled', 0),
          ],
        ),
      ],
    );
  }

  /// Large status card
  Widget _bigStatusCard({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primaryGreen,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  /// Small status chip with overflow protection
  Widget _smallStatusChip(IconData icon, String label, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: primaryGreen),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: primaryGreen,
                ),
              ),
            ),
            Text(
              count.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderGreen.withOpacity(0.4), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Stream<DocumentSnapshot> _userDocStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();
  }
}