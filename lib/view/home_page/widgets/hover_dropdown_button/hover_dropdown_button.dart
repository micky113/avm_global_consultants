// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class HoverDropdownButton extends StatefulWidget {
  final Widget textButton;
  final List<String> dropdownItems;


  const HoverDropdownButton({
    super.key,
    required this.textButton,
    required this.dropdownItems,
  });

  @override
  State<HoverDropdownButton> createState() => _HoverDropdownButtonState();
}

class _HoverDropdownButtonState extends State<HoverDropdownButton> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;
  // Tracks the currently active overlay's state object
  static _HoverDropdownButtonState? _activeOverlay;

  // --- Function to remove the overlay ---
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
    final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 1. THE OFF-TAP CLOSER
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideOverlay,
              child: Container(
                color: Colors.transparent,
              ),
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
                Future.delayed(const Duration(milliseconds: 100), () {
                  // Only hide if THIS button is still the active one AND the mouse isn't back on the button.
                  if (_activeOverlay == this) {
                     _hideOverlay();
                  }
                });
              },
              child: Material(
                elevation: 8.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.dropdownItems.map((item) {
                    return InkWell(
                      onTap: () {
                        _hideOverlay();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        width: 150,
                        child: Text(item),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // --- Widget Lifecycle Methods ---
  @override
  void dispose() {
    if (_activeOverlay == this) {
      _activeOverlay = null;
    }
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 
    MouseRegion(
      key: _buttonKey,
      onEnter: (_) {
        // If the overlay is already created, don't recreate it, but ensure active lock is set.
        if (_overlayEntry == null) {
          _showOverlay();
        } else {
          // If we re-enter the button without the overlay closing, make sure the lock is held.
          _activeOverlay = this;
        }
      },
      onExit: (_) {
        // 🛑 FIX: Simplify. The primary closing logic is now in the dropdown's MouseRegion.
        // We do NOT need a delayed future here. We simply rely on the dropdown's MouseRegion to time out.
        // The quick horizontal move is handled by the *next* button's _showOverlay cleanup.
        // This button's MouseRegion is now just a simple tracker.
      },
      child: widget.textButton,
    );
  }
}