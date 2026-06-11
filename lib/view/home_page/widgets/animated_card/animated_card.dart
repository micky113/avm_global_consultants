// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedCard extends StatefulWidget {
  final String imageName;
  final String animatedImage;
  final String text1;
  final String text2;
  final double defaultSize;
  final double hoverSize;
  final double? width;
  final double? height;

  const AnimatedCard({
    super.key,
    required this.imageName,
    required this.animatedImage,
    required this.text1,
    required this.text2,
    required this.defaultSize,
    required this.hoverSize,
    this.width,
    this.height,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  // 1. State Variable: Tracks if the mouse is hovering
  bool _isHovering = false;

  // 2. Define Logo Sizes
  // final double _defaultSize = 240.0;
  // final double _hoverSize = 480.0; // The size it grows to

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // <--- Detects mouse entry/exit
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          // Background Container/Image (Unchanged)
          InkWell(
            onTap: () {},
            child: Container(
              height: widget.height ?? 480,
              width: widget.width ?? 600,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: const Color.fromARGB(255, 20, 110, 184),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset(widget.imageName).image,
                ),
              ),
            ),
          ),

          // 3. Animated Logo (The Fix)
          Positioned.fill(
            child: Center(
              child: AnimatedContainer(
                // <--- The animation widget
                duration: const Duration(
                  milliseconds: 300,
                ), // Duration of the animation
                curve: Curves.easeInOut, // Smooth animation type
                // Size changes based on the hover state
                width: _isHovering ? widget.hoverSize : widget.defaultSize,
                height: _isHovering ? widget.hoverSize : widget.defaultSize,

                child: Image.asset(
                  // The logo image
                  widget.animatedImage,
                  color: Colors.white,
                  // The Image widget will automatically scale to the AnimatedContainer's size
                ),
              ),
            ),
          ),
          Positioned(
            // Centering the text horizontally
            left: 0,
            right: 0,
            // Positioning the text from the bottom of the card
            bottom: 40,
            child: Column(
              mainAxisSize:
                  MainAxisSize
                      .min, // Ensures the column is only as tall as its children
              children: [
                Text(
                  widget.text1, // First line
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 25,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8), // Small vertical space between the lines
                Text(
                  widget.text2, // Second line
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () {},
                  child: Text(
                    '+ Find out more', // First line
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
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
}
