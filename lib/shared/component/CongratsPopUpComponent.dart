import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice1/shared/component/smallComponents/AnimatedButton.dart';
import 'dart:math' as math;

class Congratspopupcomponent extends StatefulWidget {
  const Congratspopupcomponent({super.key});

  @override
  State<Congratspopupcomponent> createState() => _CongratspopupcomponentState();
}

class _CongratspopupcomponentState extends State<Congratspopupcomponent>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _starsController;

  late List<FallingStar> _stars;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );



    // Generate random stars
    final random = math.Random();
    _stars = List.generate(20, (index) {
      return FallingStar(
        startX: random.nextDouble(),
        startY: -0.1 ,
        speed: 0.3 + random.nextDouble() * 0.5,
        size: 15 + random.nextDouble() * 25,
        rotation: random.nextDouble() * math.pi * 2,
        delay: random.nextDouble(),
      );
    });

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _starsController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          

        

          ScaleTransition(scale: _scaleAnimation, child: buildContent()),

        ],
      ),
    );
  }

  Widget buildContent() {
    return Container(

      // margin: EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.yellow.withOpacity(0.8),
            const Color.fromARGB(137, 247, 31, 237).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 61, 56, 56).withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [

          
            Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: buildFallingStars(),
            ),
          ),
          
          Container(
                  padding: const EdgeInsets.all(32),

            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTrophySticker(),
              SizedBox(height: 13),
                    
              Text(
                "Lesson Completed",
                style: GoogleFonts.fredoka(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  height: 1.25, //line text height
                ),
                textAlign: TextAlign.center,
              ),
                    
              SizedBox(height: 24),
                    
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Geography",
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "Great Job!!!",
                style: GoogleFonts.aBeeZee(
                  height: 1,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
                    
              SizedBox(height: 15),
                    
              Center(
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildCurrencyBadge("🪙", 10),
                      buildCurrencyBadge("💎", 20),
                    ],
                  ),
                ),
              ),
                    
              SizedBox(height: 30),
                    
              AnimatedButton(),
            ],
                    ),
          ), ]
      ),
    );
  }

  Widget buildCurrencyBadge(String currency, int value) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currency,
            style: GoogleFonts.abel(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Text(
            '+$value',
            style: GoogleFonts.abel(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildTrophySticker() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.rotate(
            angle: (1 - value) * math.pi * 2,
            child: // congrats icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.5),
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 64)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildFallingStars() {
    return AnimatedBuilder(animation: _starsController, builder: (context, child) {
      return CustomPaint(
        painter: FallingStarsCustomPainter(
          stars: _stars,
          animationValue: _starsController.value,
          color: Colors.white
        ),
        child: Container(),

      );
    });

}
}


    /// Data class for falling stars
class FallingStar {
  final double startX;
  final double startY;
  final double speed;
  final double size;
  final double rotation;
  final double delay;

  FallingStar({
    required this.startX,
    required this.startY,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.delay,
  });
}

class FallingStarsCustomPainter extends CustomPainter {

  final List<FallingStar> stars;
  final double animationValue;
  final Color color;


  FallingStarsCustomPainter({required this.stars, required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      //setup adjustedValue, x , y, rotation, size
      final adjustedValue = (animationValue + star.delay) % 1.0;
      final positionCurveValue = Curves.easeOutQuad.transform(adjustedValue);
      final x = (star.startX * size.width) % size.width;
      final y = star.startY * size.height + positionCurveValue * size.height * 1.4;

      final opacity = (1.0 - adjustedValue).clamp(0.0, 1.0);

      //draw
      canvas.save();

      canvas.translate( x, y);

      canvas.rotate((star.rotation + animationValue * math.pi * 2) * 6);

      final paint = Paint()
      ..color = const Color.fromARGB(255, 255, 0, 0).withOpacity(opacity * 0.9)
      ..style = PaintingStyle.fill;

      _drawStar(canvas, star.size, paint);
      canvas.restore();

    }

  }

  @override
  bool shouldRepaint( FallingStarsCustomPainter oldDelegate) {
    return (oldDelegate.animationValue != animationValue);
  }

    void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final outerX = radius * math.cos(angle);
      final outerY = radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      final innerAngle = angle + math.pi / 5;
      final innerX = innerRadius * math.cos(innerAngle);
      final innerY = innerRadius * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

}

