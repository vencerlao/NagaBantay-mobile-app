import 'package:flutter/material.dart';
import 'package:nagabantay_mobile_app/pages/login_page.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

    // FILLED icons = Bold variants (v1.2.1 compatible)
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
                        backgroundColor:
                        Theme.of(context).colorScheme.primary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        minimumSize: const Size(110, 20),
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

              // Title
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

              // Grid (no green background)
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
            ],
          ),
        ),
      ),
    );
  }
}
