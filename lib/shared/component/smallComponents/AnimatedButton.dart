import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({super.key});

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    super.dispose();

    _pulseController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,

      builder: (context, child) {

        final pulseValue = _pulseController.value;
        final scale = pulseValue * 0.05 + 1; 
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.white, blurRadius: 30)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Continue", style: GoogleFonts.aBeeZee(fontSize: 27)),
                Container(
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(
                      255,
                      255,
                      62,
                      62,
                    ).withOpacity(0.2),
                  ),
                  child: Icon(Icons.arrow_forward, size: 24),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
