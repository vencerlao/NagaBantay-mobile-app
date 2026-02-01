import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nagabantay_mobile_app/pages/hazardmap_page.dart';
import 'package:nagabantay_mobile_app/services/flood_map_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color primaryGreen = Color(0xFF06370B);
  static const Color borderGreen = Color(0xFF669062);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildReportStatusSection(),
                const SizedBox(height: 14),
                _buildStatusButtons(),
                const SizedBox(height: 26),
                _buildMapHeader(context),
                const SizedBox(height: 10),
                const MapOverviewCard(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget _buildHeader() {
    return Row(
      children: [
        Image.asset(
          'assets/images/nagabantay_header.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontVariations: [FontVariation('wght', 500)],
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

  /// ================= REPORT STATUS (TOP TIER) =================
  Widget _buildReportStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Status',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontVariations: [FontVariation('wght', 700)],
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _bigStatusCard(
                icon: PhosphorIcons.checkCircleFill,
                label: 'Completed',
                count: 0,
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
      ],
    );
  }

  /// ================= STATUS BUTTONS (LOWER TIER - RESTORED) =================
  Widget _buildStatusButtons() {
    return Row(
      children: [
        _smallStatusChip(PhosphorIcons.fileTextFill, 'Submitted', 0, primaryGreen),
        const SizedBox(width: 8),
        _smallStatusChip(PhosphorIcons.hourglassFill, 'Pending', 0, primaryGreen),
        const SizedBox(width: 8),
        _smallStatusChip(PhosphorIcons.xCircleFill, 'Cancelled', 0, primaryGreen),
      ],
    );
  }

  /// RESTORED: Generation-friendly small chip with Icon, Label, and Count
  Widget _smallStatusChip(IconData icon, String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Color(0xFF669062), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: color,
                ),
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= MAP HEADER =================
  Widget _buildMapHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Map Overview',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontVariations: [FontVariation('wght', 700)],
            color: primaryGreen,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HazardMapPage()),
          ),
          child: const Text(
            'View Full Map >',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  /// ================= CARDS =================
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
            radius: 26,
            backgroundColor: primaryGreen,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              color: primaryGreen,
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderGreen, width: 2.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Stream<DocumentSnapshot> _userDocStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }
}

/// ================= MAP OVERVIEW CARD =================
class MapOverviewCard extends StatelessWidget {
  const MapOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HazardMapPage()),
        );
      },
      borderRadius: BorderRadius.circular(14),
      // AspectRatio makes the height adapt based on the width of the device
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF669062), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            // Tip: Set this 2px smaller than the Container radius to prevent
            // the map from "bleeding" through the border on some screens.
            borderRadius: BorderRadius.circular(12),
            child: IgnorePointer(
              child: MapWidget(
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(123.2, 13.63)),
                  zoom: 12.0,
                  pitch: 0.0,
                ),
                styleUri: "mapbox://styles/mapbox/streets-v12",
                onMapCreated: (mapboxMap) async {
                  await FloodMapService.instance.loadFloodDataOnce();
                  await mapboxMap.style.addSource(GeoJsonSource(
                    id: "flood-source-preview",
                    data: FloodMapService.instance.geoJsonString!,
                  ));
                  await mapboxMap.style.addLayer(FillLayer(
                    id: "flood-layer-preview",
                    sourceId: "flood-source-preview",
                    fillColorExpression: [
                      "match",
                      ["get", "Var"],
                      1, "#FFFF00",
                      2, "#FFA500",
                      3, "#FF0000",
                      "#000000",
                    ],
                    fillOpacity: 0.35,
                  ));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}