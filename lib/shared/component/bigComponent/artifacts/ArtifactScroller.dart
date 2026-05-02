import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArtifactScroller extends StatefulWidget {
  final int itemCount;
  final int currentIndex;
  final List<String> countryNames;
  final Function(int) onIndexChanged;
  final PageController pageController;

  const ArtifactScroller({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    required this.countryNames,
    required this.onIndexChanged,
    required this.pageController,
  });

  @override
  State<ArtifactScroller> createState() => _ArtifactScrollerState();
}

class _ArtifactScrollerState extends State<ArtifactScroller>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  int? _hoverIndex;
  late AnimationController _bubbleController;
  late Animation<double> _bubbleAnimation;
  double _bubblePositionX = 0;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _bubbleAnimation = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(double dx, double scrollBarWidth) {
    final double position = dx.clamp(0.0, scrollBarWidth);
    final double percentage = position / scrollBarWidth;
    final int targetIndex = (percentage * (widget.itemCount - 1)).round();

    if (targetIndex != _hoverIndex) {
      setState(() {
        _hoverIndex = targetIndex;
        _bubblePositionX = position;
      });

      // Haptic feedback could be added here
      widget.pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleDragStart() {
    setState(() {
      _isDragging = true;
    });
    _bubbleController.forward();
  }

  void _handleDragEnd() {
    setState(() {
      _isDragging = false;
      _hoverIndex = null;
    });
    _bubbleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Preview bubble above the scrollbar
        if (_isDragging && _hoverIndex != null)
          Positioned(
            left: _bubblePositionX.clamp(80.0, screenWidth - 160),
            bottom: 100,
            child: ScaleTransition(
              scale: _bubbleAnimation,
              child: _CountryPreviewBubble(
                countryName: widget.countryNames[_hoverIndex!],
                index: _hoverIndex!,
                totalCount: widget.itemCount,
              ),
            ),
          ),

        // Horizontal scrollbar at the bottom
        Positioned(
          left: 20,
          right: 20,
          bottom: 30,
          child: GestureDetector(
            onHorizontalDragStart: (details) => _handleDragStart(),
            onHorizontalDragUpdate: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              _handleDragUpdate(localPosition.dx, box.size.width);
            },
            onHorizontalDragEnd: (details) => _handleDragEnd(),
            onTapDown: (details) {
              _handleDragStart();
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              _handleDragUpdate(localPosition.dx, box.size.width);
            },
            onTapUp: (details) => _handleDragEnd(),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(_isDragging ? 0.3 : 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomPaint(
                painter: _ScrollBarPainter(
                  currentIndex: widget.currentIndex,
                  itemCount: widget.itemCount,
                  isDragging: _isDragging,
                  hoverIndex: _hoverIndex,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScrollBarPainter extends CustomPainter {
  final int currentIndex;
  final int itemCount;
  final bool isDragging;
  final int? hoverIndex;

  _ScrollBarPainter({
    required this.currentIndex,
    required this.itemCount,
    required this.isDragging,
    this.hoverIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final displayIndex = isDragging && hoverIndex != null ? hoverIndex! : currentIndex;

    // Calculate how many squares we can fit
    final squareSize = 8.0;
    final spacing = 6.0;
    final totalSquareWidth = squareSize + spacing;
    final maxVisibleSquares = (size.width / totalSquareWidth).floor();

    // Determine which squares to show (centered around current position)
    int startIndex = 0;
    int endIndex = itemCount;

    if (itemCount > maxVisibleSquares) {
      // Show a window of squares centered on the current position
      final halfWindow = maxVisibleSquares ~/ 2;
      startIndex = (displayIndex - halfWindow).clamp(0, itemCount - maxVisibleSquares);
      endIndex = startIndex + maxVisibleSquares;
    }

    // Draw squares
    for (int i = startIndex; i < endIndex; i++) {
      final isActive = i == displayIndex;
      final localIndex = i - startIndex;
      final x = localIndex * totalSquareWidth + spacing / 2;
      final y = size.height / 2;

      // Draw glow for active square
      if (isActive) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFF6B9D).withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x + squareSize / 2, y),
              width: squareSize + 8,
              height: squareSize + 8,
            ),
            const Radius.circular(4),
          ),
          glowPaint,
        );
      }

      // Main square
      final squarePaint = Paint()
        ..style = PaintingStyle.fill;

      if (isActive) {
        // Active square with gradient
        squarePaint.shader = const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFFC371)],
        ).createShader(
          Rect.fromCenter(
            center: Offset(x + squareSize / 2, y),
            width: squareSize * 1.5,
            height: squareSize * 1.5,
          ),
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x + squareSize / 2, y),
              width: isActive && isDragging ? squareSize * 1.5 : squareSize * 1.3,
              height: isActive && isDragging ? squareSize * 1.5 : squareSize * 1.3,
            ),
            Radius.circular(isActive ? 6 : 3),
          ),
          squarePaint,
        );

        // Inner highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x + squareSize / 2 - 1, y - 2),
              width: 4,
              height: 4,
            ),
            const Radius.circular(2),
          ),
          highlightPaint,
        );
      } else {
        // Inactive square
        // Highlight every 10th country with a slightly different color
        if (i % 10 == 0) {
          squarePaint.color = const Color(0xFF6B4CE6).withOpacity(0.4);
        } else {
          squarePaint.color = const Color(0xFF6B4CE6).withOpacity(0.2);
        }

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x + squareSize / 2, y),
              width: squareSize,
              height: squareSize,
            ),
            const Radius.circular(3),
          ),
          squarePaint,
        );
      }
    }

    // Draw position indicator text if we're showing a subset
    if (itemCount > maxVisibleSquares) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${displayIndex + 1}',
          style: TextStyle(
            color: const Color(0xFF6B4CE6).withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width - textPainter.width - 5, size.height / 2 - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_ScrollBarPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.hoverIndex != hoverIndex;
  }
}

class _CountryPreviewBubble extends StatelessWidget {
  final String countryName;
  final int index;
  final int totalCount;

  const _CountryPreviewBubble({
    required this.countryName,
    required this.index,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-100, 0), // Center the bubble
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B4CE6), Color(0xFF8B7CE6)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4CE6).withOpacity(0.5),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Country name
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                countryName,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            // Index indicator
            Text(
              '${index + 1} / $totalCount',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
