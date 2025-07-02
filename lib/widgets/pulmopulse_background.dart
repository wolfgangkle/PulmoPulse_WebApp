import 'dart:ui';
import 'package:flutter/material.dart';

class PulmoPulseBackground extends StatelessWidget {
  final Widget child;

  const PulmoPulseBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 📸 Background image
        Positioned.fill(
          child: Image.asset(
            'assets/pulmopulse_bg.png',
            fit: BoxFit.cover,
          ),
        ),

        // 💎 Optional additional blur overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0), // optional
            child: Container(color: Colors.black.withOpacity(0.1)), // optional tint
          ),
        ),

        // 👶 Content goes here
        child,
      ],
    );
  }
}
