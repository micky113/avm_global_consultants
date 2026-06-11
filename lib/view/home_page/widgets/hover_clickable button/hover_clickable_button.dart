import 'package:flutter/material.dart';
import 'package:avm_global_web/view/home_page/widgets/center_line_animation/center_line_animation.dart';

class HoverClickableButton extends StatefulWidget {
  final String text;
  final TextStyle defaultStyle;
  final TextStyle hoverStyle;
  final List<String> dropdownItems;

  const HoverClickableButton({
    super.key,
    required this.text,
    // Set explicit default and hover colors for clarity
    this.defaultStyle = const TextStyle(color: Colors.black),
    this.hoverStyle = const TextStyle(color: Colors.red),
    required this.dropdownItems,
  });

  @override
  State<HoverClickableButton> createState() => _HoverClickableButtonState();
}

class _HoverClickableButtonState extends State<HoverClickableButton> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  static _HoverClickableButtonState? _activeOverlay;
  // Variable to track the hover state
  bool _isHovering = false;
  bool _isClicked = false;

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    // IMPORTANT: Clear the global tracker
    if (_activeOverlay == this) {
      _activeOverlay = null;
    }
    setState(() => _isHovering = false);
  }

  // --- Function to create and show the overlay (REVISED) ---
// --- Function to create and show the overlay (FIXED AND SCROLLABLE) ---
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

  // 🌟 Mega-Menu Dimensions 🌟
  // Use a sensible MAX height based on your design.
  const double menuMaxHeight = 800.0; 
  const double menuTotalWidth = 1200.0;
  
  // Calculate the position of the menu start (under the button)
  final double menuLeft = 10;
  final double menuTop = offset.dy + size.height;
  final double w = MediaQuery.of(context).size.width;

  _overlayEntry = OverlayEntry(
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(0, 47, 0, 0),
      child: Stack(
        children: [
          // 1. THE OFF-TAP CLOSER (Transparent for hit area)
          Positioned.fill(
            child: SizedBox(
              width: w,
              child: GestureDetector(
                onTap: () {
                  _hideOverlay();
                  _isClicked = false;
                },
                child: Container(
                  width: w,
                  color: Colors.transparent), 
              ),
            ),
          ),

          // 2. POSITIONED DROPDOWN MENU
          Positioned(
            left: menuLeft, 
            top: menuTop,  
            width: menuTotalWidth, 
            // 🛑 CRITICAL FIX: DO NOT set a fixed 'height' here. 
            // Let the ConstrainedBox manage the max height.
            
            child: ConstrainedBox(
              // ✅ Step 1: Set the maximum height for the entire menu.
              constraints: const BoxConstraints(
                maxHeight: menuMaxHeight,
                minHeight: 0,
              ),
              child: MouseRegion(
                onExit: (_) {
                   if (_activeOverlay == this) {
                      // Add your timed hide logic here if needed
                   }
                },
                child: Material(
                  elevation: 10.0,
                  color: Colors.white,

                  // ✅ Step 2: Wrap the entire Row in SingleChildScrollView
                  // This allows the entire multi-column structure to scroll vertically.
                  child: SingleChildScrollView( 
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // The Row's vertical size will now be governed by its children
                      children: [
                        
                        // --- COLUMN 1 ---
                        Expanded(
                          flex: 2, 
                          child: Container(
                            color: Colors.grey.shade100,
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // ✅ Use mainAxisSize.min to prevent height overflow issues
                              mainAxisSize: MainAxisSize.min, 
                              children: [
                                const Text('CATEGORY 1', style: TextStyle(fontWeight: FontWeight.bold)),
                                const Divider(),
                                _buildDropdownItem('Item 1.1'),
                                _buildDropdownItem('Item 1.2'),
                                _buildDropdownItem('Item 1.3'),
                                _buildDropdownItem('Item 1.4'),
                                const SizedBox(height: 50),
                                const Text('More Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                                const Divider(),
                                _buildDropdownItem('Sub Item A'),
                                _buildDropdownItem('Sub Item B'),
                                _buildDropdownItem('Sub Item C'),
                                _buildDropdownItem('Sub Item D'),
                                _buildDropdownItem('Sub Item E'),
                                _buildDropdownItem('Sub Item F'),
                                // Add more items to force content height
                                // ...
                              ],
                            ),
                          ),
                        ),

                        // --- COLUMN 2 (Main Content) ---
                        Expanded(
                          flex: 4, 
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min, // ✅ Use mainAxisSize.min
                              children: [
                                const Text('SERVICES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const Divider(),
                                // Inject many items to ensure height exceeds the max
                                ...List.generate(30, (index) => _buildDropdownItem('Service ${index + 1}')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

  // Helper method definition (add outside of _showOverlay)
  Widget _buildDropdownItem(String itemText) {
    return InkWell(
      onTap: (){},
      child: Container(
        width: 200, // Fixed width for easier Row layout
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(itemText),
      ),
    );
  }
  /*
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
            padding: const EdgeInsets.all(45.0),
            child: Stack(
              children: [
                // 1. THE OFF-TAP CLOSER
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      _hideOverlay();
                      _isClicked = false;
                    },
                    child: Container(width: 500, color: Colors.black),
                  ),
                ),

                // 2. POSITIONED DROPDOWN MENU
                Positioned(
                  width: 1150,
                  height: 500,
                  // left: offset.dx + size.width - 400,
                  // top: 50,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 2500,
                      maxWidth: 2500,
                      ),
                    child: MouseRegion(
                      // 🛑 FIX: Add a short delay (e.g., 100ms) here.
                      // This is the window for the mouse to move to the next button/menu.
                      onExit: (_) {
                        // Future.delayed(const Duration(milliseconds: 100), () {
                        //   // Only hide if THIS button is still the active one AND the mouse isn't back on the button.
                        // if (_activeOverlay == this) {
                        //   _hideOverlay();
                        // }
                        // });
                      },
                      child: Material(
                        elevation: 4.0,
                        child: SingleChildScrollView(
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                child: Text('Business Stratergies'),
                                onTap: () {},
                              ),
                              SizedBox(height: 50),
                              InkWell(child: Text('Business')),
                              SizedBox(height: 50),
                              InkWell(child: Text('Stratergies')),
                              SizedBox(height: 50),
                              InkWell(child: Text('Business')),
                              SizedBox(height: 50),
                              InkWell(child: Text('Stratergies')),
                              SizedBox(height: 50),
                              InkWell(child: Text('Business')),
                              SizedBox(height: 50),
                              InkWell(child: Text('Stratergies')),
                              SizedBox(height: 50),
                              InkWell(child: Text('Business')),
                              SizedBox(height: 50),
                              InkWell(child: Text('Stratergies')),
                            ],
                            // widget.dropdownItems.map((item) {
                            //   return InkWell(
                            //     onTap: () {
                            //       // _hideOverlay();
                            //     },
                            //     child: Container(
                            //       // width: 300,
                            //       // height: 300,
                            //       color: Colors.amber,
                            //       padding: const EdgeInsets.symmetric(
                            //         horizontal: 16.0,
                            //         vertical: 10.0,
                            //       ),

                            //       child: Text(item),
                            //     ),
                            //   );
                            // }).toList(),
                          ),
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
*/

  @override
  Widget build(BuildContext context) {
    // Determine the current style based on the hover state
    final TextStyle finalStyle =
        _isHovering ? widget.hoverStyle : widget.defaultStyle;

    return GestureDetector(
      onTap: () {
        _isClicked = true;
        // 1. You should define what happens on a click here.
        // For this widget, a click should likely trigger the dropdown to show/hide.
        if (_overlayEntry == null) {
          _showOverlay(); // Show the overlay on tap
        } else {
          _hideOverlay(); // Hide the overlay on tap
        }

        // Optional: Add any other action for the button click
        print('${widget.text} was tapped!');
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        key: _buttonKey,
        // 1. Detect when the mouse enters the text boundary
        onEnter: (event) {
          setState(() => _isHovering = true);
        },
        onExit: (event) {
          setState(() => _isHovering = false);
        },
        // 2. Detect when the mouse exits the text boundary
        // onExit: (_) {
        //    Future.delayed(const Duration(milliseconds: 100), () {
        //                 // Only hide if THIS button is still the active one AND the mouse isn't back on the button.
        //                 if (_activeOverlay == this) {
        //                   _hideOverlay();
        //                 }
        //               });
        //   setState(() {
        //     _isHovering = false;
        //   });
        // },
        child:
            _isClicked == false
                ? Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 300,
                      ), // Smooth animation time
                      curve: Curves.easeOut,
                      // The width animates between 0 (not hovering) and 100% (hovering)
                      width: _isHovering ? widget.text.length * 10.0 : 45,
                      height: 2.0,
                      color: Colors.black,
                    ),
                    SizedBox(height: 5),

                    AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 300,
                      ), // Smooth animation time
                      curve: Curves.easeOut,
                      // The width animates between 0 (not hovering) and 100% (hovering)
                      width: _isHovering ? widget.text.length * 10.0 : 30,
                      height: 2.0,
                      color: Colors.black,
                    ),
                    SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 300,
                      ), // Smooth animation time
                      curve: Curves.easeOut,
                      // The width animates between 0 (not hovering) and 100% (hovering)
                      width: _isHovering ? widget.text.length * 10.0 : 15,
                      height: 2.0,
                      color: Colors.black,
                    ),
                  ],
                )
                : Column(
                  children: [
                    SizedBox(height: 10),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isClicked = false;
                        });
                        _hideOverlay();
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
      ),
    );
  }
}
