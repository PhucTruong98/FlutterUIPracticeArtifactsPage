import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice1/shared/component/smallComponents/AnimatedButton.dart';
import 'dart:math' as math;

class Congratspopupcomponent extends StatefulWidget {
  const Congratspopupcomponent({super.key});

  @override
  State<Congratspopupcomponent> createState() => _CongratspopupcomponentState();
}

class _CongratspopupcomponentState extends State<Congratspopupcomponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          margin: EdgeInsets.fromLTRB(12, 0, 12, 0),

          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.yellow, const Color.fromARGB(137, 247, 31, 237)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 61, 56, 56),
                blurRadius: 13,
                offset: const Offset(0, 12),
              ),
            ],
          ),
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
        ),
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
        return
        Transform.scale(
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
}
