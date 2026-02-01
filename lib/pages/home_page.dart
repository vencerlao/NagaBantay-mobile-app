import 'package:flutter/material.dart';
import 'package:nagabantay_mobile_app/pages/login_page.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nagabantay_mobile_app/pages/hazardmap_page.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nagabantay_mobile_app/services/flood_map_service.dart';
import 'dart:ui' as ui;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          padding: const EdgeInsets.all(12),
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
                ),
              ),

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

