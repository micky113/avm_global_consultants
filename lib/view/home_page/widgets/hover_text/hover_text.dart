import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avm_global_web/view/home_page/widgets/center_line_animation/center_line_animation.dart';

class HoverText extends StatefulWidget {
  final String text;
  final TextStyle defaultStyle;
  final TextStyle hoverStyle;
  final List<String> dropdownItems;

  const HoverText({
    super.key,
    required this.text,
    // Set explicit default and hover colors for clarity
    this.defaultStyle = const TextStyle(color: Colors.black),
    this.hoverStyle = const TextStyle(color: Colors.red),
    required this.dropdownItems,
  });

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  static _HoverTextState? _activeOverlay;
  // Variable to track the hover state
  bool _isHovering = false;

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    // IMPORTANT: Clear the global tracker
    if (_activeOverlay == this) {
      _activeOverlay = null;
    }
    setState(() => _isHovering = false);
  }

  // --- Function to create and show the overlay ---
  void _showOverlay() {
    // 1. GLOBAL CLEANUP: Close any other active overlay immediately.
    if (_activeOverlay != null && _activeOverlay != this) {
      _activeOverlay!._hideOverlay();
    }

    // 2. SELF-CHECK: If this overlay is already created, stop.
    if (_overlayEntry != null) {
      return;
    }

    // 3. SET LOCK: Designate THIS widget as the currently active overlay.
    _activeOverlay = this;
    setState(() => _isHovering = true); // Set local hover state

    // 4. GET POSITION:
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(44.0),
            child: Stack(
              children: [
                // 1. THE OFF-TAP CLOSER
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _hideOverlay,
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // 2. POSITIONED DROPDOWN MENU
                Positioned(
                  left: offset.dx + size.width - 150,
                  top: offset.dy + size.height,
                  child: MouseRegion(
                    // 🛑 FIX: Add a short delay (e.g., 100ms) here.
                    // This is the window for the mouse to move to the next button/menu.
                    onExit: (_) {
                      // Future.delayed(const Duration(milliseconds: 100), () {
                      //   // Only hide if THIS button is still the active one AND the mouse isn't back on the button.
                      if (_activeOverlay == this) {
                        _hideOverlay();
                      }
                      // });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Material(
                          elevation: 4.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:
                                widget.dropdownItems.map((item) {
                                  return InkWell(
                                    onTap: () {
                                      // _hideOverlay();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 10.0,
                                      ),
                                      width: 250,
                                      child: Text(item),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current style based on the hover state
    final TextStyle finalStyle =
        _isHovering
            ? GoogleFonts.notoSans(
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 20, 110, 184),
            )
            : GoogleFonts.notoSans(
              fontSize: 17,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            );

    return GestureDetector(
      onTap: () {
        // 1. You should define what happens on a click here.
        // For this widget, a click should likely trigger the dropdown to show/hide.
        if (_overlayEntry == null) {
          _showOverlay(); // Show the overlay on tap
        } else {
          _hideOverlay(); // Hide the overlay on tap
        }

        // Optional: Add any other action for the button click
        print('${widget.text.length.toDouble()} was tapped!');
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        key: _buttonKey,
        // 1. Detect when the mouse enters the text boundary
        onEnter: (_) {
          // If the overlay is already created, don't recreate it, but ensure active lock is set.
          if (_overlayEntry == null) {
            _showOverlay();
          } else {
            // If we re-enter the button without the overlay closing, make sure the lock is held.
            _activeOverlay = this;
          }
        },
        child: Column(
          children: [
            Text(
              widget.text,
              style: finalStyle, // 3. Apply the dynamic style directly
            ),
            _isHovering
                ? CenterLineAnimation(
                  finalWidth: widget.text.length.toDouble() * 8,
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
