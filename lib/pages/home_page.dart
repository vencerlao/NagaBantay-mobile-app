import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nagabantay_mobile_app/pages/hazardmap_page.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nagabantay_mobile_app/services/flood_map_service.dart';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Theme Constants
  static const Color primaryGreen = Color(0xFF06370B);
  static const Color borderGreen = Color(0xFF669062);

  @override
  Widget build(BuildContext context) {
    Widget buildTile(String label, IconData iconData) {
      return LayoutBuilder(
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth * 0.15;
          fontSize = fontSize.clamp(10, 16);

          return InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF669062),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(76, 175, 80, 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Hollow box, FILLED icon
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF669062),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      iconData, // filled (bold) icon
                      color: const Color(0xFF669062),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '0',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontSize: fontSize + 4,
                            color: const Color(0xFF06370B),
                            fontVariations: const [
                              FontVariation('wght', 700)
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontFamily: 'Montserrat',
                              fontSize: fontSize,
                              color: const Color(0xFF06370B),
                              height: 1.1,
                              fontVariations: const [
                                FontVariation('wght', 700)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    final tiles = [
      {
        'label': 'Submitted',
        'icon': PhosphorIcons.fileTextFill,
      },
      {
        'label': 'Under Review',
        'icon': PhosphorIcons.magnifyingGlassFill,
      },
      {
        'label': 'Pending',
        'icon': PhosphorIcons.hourglassFill,
      },
      {
        'label': 'Completed',
        'icon': PhosphorIcons.checkCircleFill,
      },
      {
        'label': 'Cancelled',
        'icon': PhosphorIcons.xCircleFill,
      },
      {
        'label': 'Ratings',
        'icon': PhosphorIcons.starFill,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Row(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 220,
                        maxHeight: 56,
                      ),
                      child: Image.asset(
                        'assets/images/nagabantay_header.png',
                        height: 42,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                        const SizedBox.shrink(),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        fixedSize: ui.Size(110, 40),
                      ),
                      child: Text(
                        'SIGN UP',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontVariations: const [
                            FontVariation('wght', 700)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Text(
                  'Report Status',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    color: const Color(0xFF06370B),
                    fontVariations: const [
                      FontVariation('wght', 700)
                    ],
                  ),
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

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: tiles.length,
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                    MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                    MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 5),
                  ),
                  itemBuilder: (context, index) {
                    return buildTile(
                      tiles[index]['label'] as String,
                      tiles[index]['icon'] as IconData,
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Map Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        color: const Color(0xFF06370B),
                        fontVariations: const [FontVariation('wght', 700)],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HazardMapPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: ui.Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View Map',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontVariations: [
                            FontVariation('wght', 500),
                          ],
                          color: Color(0xFF06370B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: MapOverviewCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapOverviewCard extends StatelessWidget {
  const MapOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HazardMapPage(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF669062),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
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

                await mapboxMap.style.addSource(
                  GeoJsonSource(
                    id: "flood-source-preview",
                    data: FloodMapService.instance.geoJsonString!,
                  ),
                );

                await mapboxMap.style.addLayer(
                  FillLayer(
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
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
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
