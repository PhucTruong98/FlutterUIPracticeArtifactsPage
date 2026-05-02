import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice1/shared/component/bigComponent/artifacts/model/Artifacts.dart';

class ArtifactsPageView extends StatefulWidget {
  final List<Artifact> artifacts;
  final String countryName;

  const ArtifactsPageView({
    super.key,
    required this.artifacts,
    required this.countryName,
  });

  @override
  State<ArtifactsPageView> createState() => _ArtifactsPageViewState();
}

class _ArtifactsPageViewState extends State<ArtifactsPageView> {
  int totalArtCount = 0;
  int ownedArtCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    totalArtCount = widget.artifacts.length;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF9), // Off-white paper color
      body: CustomScrollView(
        slivers: [
          // Full-page notebook background that scrolls
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth > 0
                    ? constraints.maxWidth
                    : MediaQuery.of(context).size.width;

                // Calculate grid dimensions
                const crossAxisCount = 3;
                const crossAxisSpacing = 20.0;
                const mainAxisSpacing = 30.0;
                const childAspectRatio = 0.75;
                const horizontalPadding = 16.0;

                // Calculate item width and height
                final availableWidth = screenWidth - (horizontalPadding * 2);
                final itemWidth = (availableWidth - (crossAxisSpacing * (crossAxisCount - 1))) / crossAxisCount;
                final itemHeight = itemWidth / childAspectRatio;

                // Calculate number of rows
                final rowCount = (widget.artifacts.length / crossAxisCount).ceil();

                // Calculate total height needed
                const headerHeight = 200.0;
                final gridHeight = (rowCount * itemHeight) + ((rowCount - 1) * mainAxisSpacing);
                const bottomPadding = 100.0;

                final totalHeight = headerHeight + gridHeight + bottomPadding;

                return SizedBox(
                  height: totalHeight,
                  width: screenWidth,
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _NotebookBackgroundPainter(totalHeight),
                        size: Size(screenWidth, totalHeight),
                      ),
                      // Place header and content on top
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildHeader(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: crossAxisSpacing,
                                mainAxisSpacing: mainAxisSpacing,
                                childAspectRatio: childAspectRatio,
                              ),
                              itemCount: widget.artifacts.length,
                              itemBuilder: (context, index) {
                                return buildArtifactCard(widget.artifacts[index]);
                              },
                            ),
                          ),
                          const SizedBox(height: bottomPadding),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  height: 70,
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    wrapWords: false,
                    maxLines: 2,
                    minFontSize: 16,
                    maxFontSize: 48,
                    overflow: TextOverflow.ellipsis,
                    widget.countryName,
                    style: GoogleFonts.fredoka(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6B4CE6),
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFFD93D).withOpacity(0.5),
                          offset: const Offset(3, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFFFC371)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ))
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Container(
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE0C3FC).withOpacity(0.3),
                  const Color(0xFF8EC5FC).withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: 3 / 5,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B4CE6), Color(0xFF8B7CE6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B4CE6).withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "3/5",
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget buildArtifactsGrid() {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 30,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final artifact = widget.artifacts[index];
            return buildArtifactCard(artifact);
          },
          childCount: widget.artifacts.length,
        ),
      );
 }


Widget buildArtifactCard(Artifact artifact) {
    final isOwned = true; // artifact.obtained
    final rarity = artifact.rarity;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Legendary animated light ray background
              if (isOwned && rarity == ArtifactRarity.legendary)
                Positioned.fill(
                  child: _LegendaryLightRayBackground(),
                ),

              // Rare glow effect
              if (isOwned && rarity == ArtifactRarity.rare)
                Positioned.fill(
                  child: _RareGlowEffect(),
                ),

              // The artifact image or mystery icon
              Center(
                child: isOwned
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          "assets/souvenirsImages/sushiBoat.png",
                          fit: BoxFit.contain,
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E9E9E),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Artifact name at the bottom
        Text(
          isOwned ? artifact.name : "???",
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.fredoka(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isOwned ? const Color(0xFF2D2D2D) : const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}

class _NotebookBackgroundPainter extends CustomPainter {
  final double pageHeight;

  _NotebookBackgroundPainter(this.pageHeight);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw horizontal ruled lines
    final linePaint = Paint()
      ..color = const Color(0xFFCCE5FF).withOpacity(0.5) // Light blue lines like notebook paper
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Line spacing (typical notebook spacing is about 24-32px)
    final lineSpacing = 32.0;
    final startY = 100.0; // Start below the header
    final maxHeight = pageHeight; // Use calculated height

    // Draw parallel horizontal lines extending to content height
    for (double y = startY; y < maxHeight; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width > 0 ? size.width : 1000, y),
        linePaint,
      );
    }

//no longer needed holes and red line
    // // Draw left margin line (red vertical line)
    // final marginPaint = Paint()
    //   ..color = const Color(0xFFFFB6C1).withOpacity(0.6) // Light red/pink margin
    //   ..strokeWidth = 2.0
    //   ..style = PaintingStyle.stroke;

    // final marginX = 50.0; // Distance from left edge
    // canvas.drawLine(
    //   Offset(marginX, 0),
    //   Offset(marginX, maxHeight),
    //   marginPaint,
    // );

    // // Draw binder holes
    // final holePaint = Paint()
    //   ..color = const Color(0xFFE0E0E0)
    //   ..style = PaintingStyle.fill;

    // final holeOutlinePaint = Paint()
    //   ..color = const Color(0xFFB0B0B0)
    //   ..strokeWidth = 1.5
    //   ..style = PaintingStyle.stroke;

    // final holeRadius = 8.0;
    // final holeX = 25.0; // Center of holes
    // final holeSpacing = 350.0; // Space between holes

    // // Draw holes repeating down the page
    // for (double holeY = 150.0; holeY < maxHeight; holeY += holeSpacing) {
    //   // Outer ring (shadow effect)
    //   canvas.drawCircle(
    //     Offset(holeX, holeY),
    //     holeRadius + 2,
    //     Paint()
    //       ..color = const Color(0xFFD0D0D0).withOpacity(0.3)
    //       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    //   );

    //   // Main hole
    //   canvas.drawCircle(
    //     Offset(holeX, holeY),
    //     holeRadius,
    //     holePaint,
    //   );

    //   // Hole outline
    //   canvas.drawCircle(
    //     Offset(holeX, holeY),
    //     holeRadius,
    //     holeOutlinePaint,
    //   );

    //   // Inner shadow for depth
    //   canvas.drawCircle(
    //     Offset(holeX - 1, holeY - 1),
    //     holeRadius - 3,
    //     Paint()
    //       ..color = const Color(0xFF909090).withOpacity(0.3)
    //       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    //   );
    // }

    // Add subtle paper texture with random dots
    final texturePaint = Paint()
      ..color = const Color(0xFFE8E8E8).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final dotSize = random.nextDouble() * 0.5 + 0.3;

      canvas.drawCircle(
        Offset(x, y),
        dotSize,
        texturePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_NotebookBackgroundPainter oldDelegate) =>
    oldDelegate.pageHeight != pageHeight;
}

// Legendary Light Ray Background with rainbow colors
class _LegendaryLightRayBackground extends StatefulWidget {
  @override
  State<_LegendaryLightRayBackground> createState() =>
      _LegendaryLightRayBackgroundState();
}

class _LegendaryLightRayBackgroundState
    extends State<_LegendaryLightRayBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _LightRayPainter(_controller.value),
        );
      },
    );
  }
}

class _LightRayPainter extends CustomPainter {
  final double animationValue;

  _LightRayPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rayCount = 12;
    final rotationAngle = animationValue * 2 * pi;

    final rainbowColors = [
      const Color(0xFFFF6B9D),
      const Color(0xFFFFD93D),
      const Color(0xFF6BCF7C),
      const Color(0xFF4ECDC4),
      const Color(0xFF6B4CE6),
      const Color(0xFFFF6B9D),
    ];

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * pi / rayCount) + rotationAngle;
      final color = rainbowColors[i % rainbowColors.length];

      final gradient = RadialGradient(
        colors: [
          color.withOpacity(0.6),
          color.withOpacity(0.3),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: size.width),
        );

      final path = Path();
      path.moveTo(center.dx, center.dy);

      final rayWidth = pi / 24;
      final rayLength = max(size.width, size.height);

      path.lineTo(
        center.dx + rayLength * cos(angle - rayWidth),
        center.dy + rayLength * sin(angle - rayWidth),
      );
      path.lineTo(
        center.dx + rayLength * cos(angle + rayWidth),
        center.dy + rayLength * sin(angle + rayWidth),
      );
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LightRayPainter oldDelegate) => true;
}

// Rare Glow Effect
class _RareGlowEffect extends StatefulWidget {
  @override
  State<_RareGlowEffect> createState() => _RareGlowEffectState();
}

class _RareGlowEffectState extends State<_RareGlowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4).withOpacity(0.4 + _controller.value * 0.3),
                blurRadius: 20 + _controller.value * 10,
                spreadRadius: 5 + _controller.value * 5,
              ),
              BoxShadow(
                color: const Color(0xFF6B4CE6).withOpacity(0.3 + _controller.value * 0.2),
                blurRadius: 30 + _controller.value * 15,
                spreadRadius: 3 + _controller.value * 3,
              ),
            ],
          ),
        );
      },
    );
  }
}
