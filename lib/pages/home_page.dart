import 'package:flutter/material.dart';
import 'package:nagabantay_mobile_app/pages/signup_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // helper to build each dashboard tile
    Widget buildTile(String label, double fontSize) {
      return InkWell(
        onTap: () {
          // TODO: wire navigation when destination is decided
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF669062), width: 2),
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
              // Dark green square for icon placeholder
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF669062), // dark green
                  borderRadius: BorderRadius.circular(8),
                ),
                // placeholder for future icon
                child: const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),

              // Count and label (centered)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '0',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            color: const Color(0xFF06370B),
                            fontVariations: const [
                              FontVariation('wght', 700), // <-- this makes it bold
                            ],
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Montserrat',
                            fontSize: fontSize,
                            color: const Color(0xFF06370B),
                            fontVariations: const [
                              FontVariation('wght', 700), // <-- this makes it bold
                            ],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final tiles = [
      {'label': 'Submitted', 'size': 13.5},
      {'label': 'Under ''Review', 'size': 10.5}, // Smaller because it's a long word
      {'label': 'Pending', 'size': 13.0},
      {'label': 'Completed', 'size': 13.0},
      {'label': 'Cancelled', 'size': 13.0},
      {'label': 'Ratings', 'size': 13.0}, // Larger just for example
    ];

    return Scaffold(
      // Make the entire screen white so the white background occupies the whole viewport
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          // Removed the inner decorated Container so the Scaffold's white fills the screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header: left image and right SIGN UP button
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Row(
                  children: [
                    // Left: nagabantay header image (constrained & fits)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220, maxHeight: 56),
                      child: Image.asset(
                        'assets/images/nagabantay_header.png',
                        height: 42,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),

                    const Spacer(),

                    // Right: SIGN UP button that navigates to SignUpPage
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        minimumSize: const Size(110, 20),
                      ),
                      child: Text(
                        'SIGN UP',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              fontVariations: const [
                                FontVariation('wght', 700), // <-- this makes it bold
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // Report Status text beneath the header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Text(
                  'Report Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600, color: Color(0xFF06370B),
                        fontVariations: const [
                          FontVariation('wght', 700), // <-- this makes it bold
                        ],
                      ),
                ),
              ),

              // Dashboard grid (2 columns x 3 rows)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GridView.builder(
                    itemCount: tiles.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemBuilder: (context, index) {
                      final tile = tiles[index];
                      final label = tile['label'] as String;
                      final size = tile['size'] as double;
                      return buildTile(label, size);
                    },
                  ),
                ),
              ),

              // Fill rest of the screen for content
            ],
          ),
        ),
      ),
    );
  }
}

