import 'package:flutter/material.dart';

class AnimatedUnderlineMenuItem extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const AnimatedUnderlineMenuItem({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<AnimatedUnderlineMenuItem> createState() => _AnimatedUnderlineMenuItemState();
}

class _AnimatedUnderlineMenuItemState extends State<AnimatedUnderlineMenuItem> {
  // 1. State variable to track hover
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      // 3. GestureDetector handles the tap action
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(
            //   widget.text,
            //   style: TextStyle(
            //     color: _isHovering ? Colors.black : Colors.grey,
            //     fontSize: 16,
            //   ),
            // ),
            // const SizedBox(height: 4),
            // 4. AnimatedContainer for the animating underline
            AnimatedContainer(
              duration: const Duration(milliseconds: 300), // Smooth animation time
              curve: Curves.easeOut,
              // The width animates between 0 (not hovering) and 100% (hovering)
              width: _isHovering ? widget.text.length * 10.0 : 45, 
              height: 2.0,
              color: Colors.black,
            ),
            SizedBox(height: 5,),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300), // Smooth animation time
              curve: Curves.easeOut,
              // The width animates between 0 (not hovering) and 100% (hovering)
              width: _isHovering ? widget.text.length * 10.0 : 30, 
              height: 2.0,
              color: Colors.black,
            ),
            SizedBox(height: 5,),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300), // Smooth animation time
              curve: Curves.easeOut,
              // The width animates between 0 (not hovering) and 100% (hovering)
              width: _isHovering ? widget.text.length * 10.0 : 15, 
              height: 2.0,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}