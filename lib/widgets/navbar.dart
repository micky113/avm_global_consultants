import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class NavBar extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, GlobalKey> sectionKeys;
  final VoidCallback? onRegisterClick;

  const NavBar({
    super.key,
    required this.sectionKeys,
    this.onRegisterClick,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String? hoveredLink;

  void scrollTo(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool useDrawer = isMobile || Responsive.isTablet(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F), // Premium Deep Navy
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Brand Logo
            GestureDetector(
              onTap: () => scrollTo(widget.sectionKeys['Home']!),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4AF37), // Gold
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.public,
                        color: Color(0xFFD4AF37),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'AVM GLOBAL',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w900,
                            fontSize: isMobile ? 16 : 20,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'CONSULTANTS',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: isMobile ? 9 : 11,
                            letterSpacing: 3.5,
                            color: const Color(0xFFD4AF37), // Champagne Gold
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Links / Mobile Drawer Button
            if (useDrawer)
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              )
            else
              Row(
                children: [
                  _navLink('Home', widget.sectionKeys['Home']!),
                  _navLink('About Us', widget.sectionKeys['About']!),
                  _navLink('Job Openings', widget.sectionKeys['Jobs']!),
                  _navLink('Registration', widget.sectionKeys['Register']!),
                  _navLink('Testimonials', widget.sectionKeys['Testimonials']!),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.onRegisterClick != null) {
                        widget.onRegisterClick!();
                      } else {
                        scrollTo(widget.sectionKeys['Register']!);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0A192F),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ).copyWith(
                      overlayColor: WidgetStateProperty.all(
                        Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(String title, GlobalKey key) {
    final bool isHovered = hoveredLink == title;
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredLink = title),
      onExit: (_) => setState(() => hoveredLink = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => scrollTo(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isHovered ? const Color(0xFFD4AF37) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isHovered ? const Color(0xFFD4AF37) : Colors.white70,
              fontSize: 15,
              fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
