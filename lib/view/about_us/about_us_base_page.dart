import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsBasePage extends StatelessWidget {
  final String title;
  final Widget child;

  const AboutUsBasePage({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 700;
    const themeColor = Color(0xFF146EB8);
    const darkBlue = Color(0xFF0A192F);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            titleSpacing: isMobile ? 8.0 : 20.0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: IconButton(
                tooltip: 'Back to Home',
                icon: const Icon(Icons.arrow_back_rounded, color: darkBlue, size: 24),
                onPressed: () => context.go('/'),
              ),
            ),
            title: Row(
              children: [
                Image.asset(
                  'images/logo.png',
                  fit: BoxFit.contain,
                  width: isMobile ? 48 : 64,
                  height: isMobile ? 48 : 64,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.business,
                    color: themeColor,
                    size: 38,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AVM Global',
                      style: GoogleFonts.notoSans(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w800,
                        color: themeColor,
                      ),
                    ),
                    Text(
                      'Consultants',
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 12 : 13.5,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              if (!isMobile)
                Padding(
                  padding: const EdgeInsets.only(right: 40.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        title,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Page Header Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20.0 : 80.0,
                  vertical: isMobile ? 30.0 : 60.0,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF8FAFC),
                      Color(0xFFEFF6FF),
                      Color(0xFFF1F5F9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMobile)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          title,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      ),
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        fontSize: isMobile ? 28 : 40,
                        fontWeight: FontWeight.w800,
                        color: darkBlue,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: 60,
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              // Main content
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16.0 : 80.0,
                  vertical: 40.0,
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
