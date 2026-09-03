import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HoverText extends StatefulWidget {
  final String text;
  final TextStyle defaultStyle;
  final TextStyle hoverStyle;
  final List<String> dropdownItems;
  final VoidCallback? onTap;
  final ValueChanged<String>? onDropdownItemSelected;

  const HoverText({
    super.key,
    required this.text,
    // Set explicit default and hover colors for clarity
    this.defaultStyle = const TextStyle(color: Colors.black),
    this.hoverStyle = const TextStyle(color: Colors.red),
    required this.dropdownItems,
    this.onTap,
    this.onDropdownItemSelected,
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
                    child: Material(
                      elevation: 8.0,
                      shadowColor: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.dropdownItems.map((item) {
                            return _DropdownItemWidget(
                              text: item,
                              onTap: () {
                                _hideOverlay();
                                if (widget.onDropdownItemSelected != null) {
                                  widget.onDropdownItemSelected!(item);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
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
    final TextStyle finalStyle = GoogleFonts.notoSans(
      fontSize: 16,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: _isHovering
          ? const Color.fromARGB(255, 20, 110, 184)
          : const Color(0xFF1E293B),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      key: _buttonKey,
      onEnter: (_) {
        setState(() => _isHovering = true);
        if (_overlayEntry == null) {
          if (widget.dropdownItems.isNotEmpty) {
            _showOverlay();
          }
        } else {
          _activeOverlay = this;
        }
      },
      onExit: (_) {
        setState(() => _isHovering = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          } else {
            if (_overlayEntry == null && widget.dropdownItems.isNotEmpty) {
              _showOverlay();
            } else {
              _hideOverlay();
            }
          }
        },
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
          child: Text(
            widget.text,
            style: finalStyle,
          ),
        ),
      ),
    );
  }
}

class _DropdownItemWidget extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _DropdownItemWidget({
    required this.text,
    required this.onTap,
  });

  @override
  State<_DropdownItemWidget> createState() => _DropdownItemWidgetState();
}

class _DropdownItemWidgetState extends State<_DropdownItemWidget> {
  bool _isItemHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isItemHovered = true),
      onExit: (_) => setState(() => _isItemHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
          decoration: BoxDecoration(
            color: _isItemHovered
                ? const Color(0xFF146EB8).withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: _isItemHovered ? FontWeight.w600 : FontWeight.w500,
                    color: _isItemHovered
                        ? const Color(0xFF146EB8)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: _isItemHovered
                    ? const Color(0xFF146EB8)
                    : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

