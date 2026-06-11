// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CenterLineAnimation extends StatelessWidget {
  const CenterLineAnimation({
    super.key,
    required this.finalWidth,
  });

  // final double finalWidth = 120.0;
  final double finalWidth;
  final double lineHeight = 2.0;
  final Duration animationDuration = const Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        // Animate the 'width' value from 0.0 to the finalWidth
        tween: Tween<double>(begin: 0.0, end: finalWidth),
        duration: animationDuration,
        curve: Curves.easeInOut, // Optional: for a smoother effect
        builder: (context, width, child) {
          return Container(
            // Use the animated 'width' value
            width: width,
            height: lineHeight,
            color: Colors.blue,
          );
        },
      ),
    );
  }
}
