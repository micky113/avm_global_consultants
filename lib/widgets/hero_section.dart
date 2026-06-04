import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class HeroSection extends StatefulWidget {
  final GlobalKey jobsKey;
  final GlobalKey registerKey;

  const HeroSection({
    super.key,
    required this.jobsKey,
    required this.registerKey,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  bool hover1 = false;
  bool hover2 = false;

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    // Dynamic padding and font sizes based on viewport
    final double horizontalPadding = isMobile
        ? 20.0
        : isTablet
            ? 50.0
            : screenWidth * 0.08;
    final double headingSize = isMobile
        ? 34.0
        : isTablet
            ? 48.0
            : 56.0;
    final double subHeadingSize = isMobile
        ? 16.0
        : isTablet
            ? 18.0
            : 20.0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 650),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate 900
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A192F), // Premium Deep Navy
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E293B), // Slate 800
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Decorative Blur Circle 1 (Gold glow)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4AF37).withOpacity(0.08),
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=600&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
                color: const Color(0xFF0F172A).withOpacity(0.9),
                colorBlendMode: BlendMode.srcOver,
              ),
            ),
          ),

          // Background Decorative Blur Circle 2 (Navy light glow)
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.06),
              ),
            ),
          ),

          // Content Layout
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isMobile ? 80.0 : 120.0,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  children: [
                    // Text Column
                    Expanded(
                      flex: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Color(0xFFD4AF37),
                                  size: 14,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'ISO 9001:2015 Certified Agency',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFFD4AF37),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Heading
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: headingSize,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                                color: Colors.white,
                              ),
                              children: const [
                                TextSpan(text: 'Connecting Indian\nTalent with '),
                                TextSpan(
                                  text: 'Global\nOpportunities',
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37), // Premium Gold
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Subtitle
                          Text(
                            'Your trusted government-approved gateway to careers in Europe, Middle East, Canada, and Australia. Seamless placements, transparent documentation, and end-to-end relocation support.',
                            style: TextStyle(
                              fontSize: subHeadingSize,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // CTA Buttons
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              MouseRegion(
                                onEnter: (_) => setState(() => hover1 = true),
                                onExit: (_) => setState(() => hover1 = false),
                                child: AnimatedScale(
                                  scale: hover1 ? 1.05 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: ElevatedButton(
                                    onPressed: () => scrollTo(widget.jobsKey),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD4AF37),
                                      foregroundColor: const Color(0xFF0A192F),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Explore Job Openings',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              MouseRegion(
                                onEnter: (_) => setState(() => hover2 = true),
                                onExit: (_) => setState(() => hover2 = false),
                                child: AnimatedScale(
                                  scale: hover2 ? 1.05 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: OutlinedButton(
                                    onPressed: () => scrollTo(widget.registerKey),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white38,
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ).copyWith(
                                      backgroundColor: WidgetStateProperty.resolveWith(
                                        (states) => states.contains(WidgetState.hovered)
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: const Text(
                                      'Register Candidate',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Illustrative Banner Image (Hidden on Mobile)
                    if (!isMobile)
                      Expanded(
                        flex: 8,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative Background Shape
                              Container(
                                width: 340,
                                height: 340,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              // Real Image representation with Gold Border
                              Transform.rotate(
                                angle: 0.05,
                                child: Container(
                                  width: 320,
                                  height: 320,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFD4AF37),
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 20,
                                        offset: const Offset(10, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1573164713988-8665fc963095?q=80&w=600&auto=format&fit=crop',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: const Color(0xFF1E293B),
                                        child: const Icon(
                                          Icons.business_center,
                                          color: Color(0xFFD4AF37),
                                          size: 80,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
