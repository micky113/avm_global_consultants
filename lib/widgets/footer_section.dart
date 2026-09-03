import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class FooterSection extends StatelessWidget {
  final VoidCallback? onContactTap;

  const FooterSection({
    super.key,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 768;
    final bool isTablet = width >= 768 && width < 1100;

    return Container(
      width: double.infinity,
      color: const Color(0xFF071120),
      child: Column(
        children: [
          // 1. Trust & Impact Highlights Banner
          _buildTrustHighlights(isMobile, isTablet),

          const Divider(height: 1, color: Colors.white12),

          // 2. Main Footer Columns
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20.0 : (isTablet ? 40.0 : 80.0),
              vertical: isMobile ? 40.0 : 60.0,
            ),
            child: isMobile
                ? _buildMobileFooter(context)
                : _buildDesktopFooter(context, isTablet),
          ),

          // 3. Ethical Recruitment Warning Banner
          _buildFraudAdvisoryBanner(isMobile),

          const Divider(height: 1, color: Colors.white10),

          // 4. Bottom Copyright Bar
          _buildCopyrightBar(context, isMobile),
        ],
      ),
    );
  }

  // 1. Trust & Impact Highlights
  Widget _buildTrustHighlights(bool isMobile, bool isTablet) {
    final List<Map<String, dynamic>> highlights = [
      {
        'icon': Icons.public_rounded,
        'title': '30+ Countries',
        'subtitle': 'Germany, UK, Canada, Poland & Gulf',
      },
      {
        'icon': Icons.verified_user_rounded,
        'title': 'Govt. Approved & Compliant',
        'subtitle': '100% Legal & Ethical Recruitment',
      },
      {
        'icon': Icons.people_alt_rounded,
        'title': '5,000+ Placed',
        'subtitle': 'Healthcare, Tech, Hospitality & Engg',
      },
      {
        'icon': Icons.flight_takeoff_rounded,
        'title': 'End-to-End Support',
        'subtitle': 'Interviews, Visas & Relocation',
      },
    ];

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        color: const Color(0xFF0A192F),
        child: Column(
          children: highlights
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF146EB8).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item['icon'] as IconData,
                              color: const Color(0xFF38BDF8), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: GoogleFonts.notoSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                item['subtitle'] as String,
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 30,
        horizontal: isTablet ? 30 : 60,
      ),
      color: const Color(0xFF0A192F),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: highlights.map((item) {
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF146EB8).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item['icon'] as IconData,
                      color: const Color(0xFF38BDF8), size: 28),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['title'] as String,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['subtitle'] as String,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 2. Desktop Footer Grid
  Widget _buildDesktopFooter(BuildContext context, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column 1: Brand & Bio
        Expanded(
          flex: isTablet ? 3 : 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'images/logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AVM Global',
                        style: GoogleFonts.notoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Consultants',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Premier Overseas Human Resource & Global Career Consultancy. Empowering healthcare professionals, engineers, IT specialists, and skilled workers to achieve international career success.',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Govt. Approved Overseas Placement Partner',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Column 2: Career Destinations
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterHeading('Top Destinations'),
              const SizedBox(height: 16),
              _buildFooterLink(context, '🇩🇪 Jobs in Germany', '/jobs?location=Germany'),
              _buildFooterLink(context, '🇬🇧 Jobs in United Kingdom', '/jobs?location=United Kingdom'),
              _buildFooterLink(context, '🇨🇦 Jobs in Canada', '/jobs?location=Canada'),
              _buildFooterLink(context, '🇵🇱 Jobs in Poland & EU', '/jobs?location=Poland'),
              _buildFooterLink(context, '🇦🇪 Jobs in Dubai & UAE', '/jobs?location=Dubai'),
              _buildFooterLink(context, '🇦🇺 Jobs in Australia', '/jobs?location=Australia'),
            ],
          ),
        ),

        const SizedBox(width: 30),

        // Column 3: Quick Links
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterHeading('Quick Links'),
              const SizedBox(height: 16),
              _buildFooterLink(context, 'Browse All Jobs', '/jobs'),
              _buildFooterLink(context, 'Candidate Registration', '/register'),
              _buildFooterLink(context, 'About Our Story', '/about/vision-mission'),
              _buildFooterLink(context, 'Meet Our Team', '/about/our-team'),
              _buildFooterLink(context, 'Employer Portal', '/login'),
              _buildActionLink('Contact Support', onContactTap),
            ],
          ),
        ),

        const SizedBox(width: 30),

        // Column 4: Contact & Office
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterHeading('Helpdesk'),
              const SizedBox(height: 16),
              _buildContactItem(
                Icons.phone_in_talk_outlined,
                '+91 9668102226',
              ),
              const SizedBox(height: 12),
              _buildContactItem(
                Icons.email_outlined,
                'vishal@avmglobalconsultants.com',
              ),
              const SizedBox(height: 12),
              _buildContactItem(
                Icons.access_time_rounded,
                'Mon – Sat: 9:30 AM – 6:30 PM (IST)',
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onContactTap,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send an Inquiry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF146EB8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2b. Mobile Footer Layout
  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'images/logo.png',
                  width: 46,
                  height: 46,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVM Global',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Consultants',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Premier Overseas Human Resource & Global Career Placement Consultancy.',
          style: GoogleFonts.notoSans(
            fontSize: 13,
            height: 1.5,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 28),

        // Quick Links Accordion/Section
        _buildFooterHeading('Quick Links'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _buildMobileChip(context, 'All Jobs', '/jobs'),
            _buildMobileChip(context, 'Register', '/register'),
            _buildMobileChip(context, 'About Us', '/about/vision-mission'),
            _buildMobileChip(context, 'Our Team', '/about/our-team'),
            _buildMobileChip(context, 'Employer Login', '/login'),
          ],
        ),
        const SizedBox(height: 28),

        // Top Destinations
        _buildFooterHeading('Top Destinations'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _buildMobileChip(context, '🇩🇪 Germany', '/jobs?location=Germany'),
            _buildMobileChip(context, '🇬🇧 UK', '/jobs?location=United Kingdom'),
            _buildMobileChip(context, '🇨🇦 Canada', '/jobs?location=Canada'),
            _buildMobileChip(context, '🇵🇱 Poland', '/jobs?location=Poland'),
            _buildMobileChip(context, '🇦🇪 Dubai', '/jobs?location=Dubai'),
            _buildMobileChip(context, '🇦🇺 Australia', '/jobs?location=Australia'),
          ],
        ),
        const SizedBox(height: 28),

        // Contact Info
        _buildFooterHeading('Helpdesk'),
        const SizedBox(height: 12),
        _buildContactItem(
          Icons.phone_in_talk_outlined,
          '+91 9668102226',
        ),
        const SizedBox(height: 10),
        _buildContactItem(
          Icons.email_outlined,
          'vishal@avmglobalconsultants.com',
        ),
        const SizedBox(height: 10),
        _buildContactItem(
          Icons.access_time_rounded,
          'Mon – Sat: 9:30 AM – 6:30 PM (IST)',
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onContactTap,
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Send an Inquiry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF146EB8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 3. Ethical Recruitment Advisory
  Widget _buildFraudAdvisoryBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F233D),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 16,
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFFFBBF24), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Candidate Advisory: AVM Global strictly adheres to ethical recruitment practices. We never demand unauthorized deposits or unofficial bank transfers. Always communicate through verified channels.',
              style: GoogleFonts.notoSans(
                fontSize: isMobile ? 11 : 12,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Copyright Bar
  Widget _buildCopyrightBar(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 60.0,
        vertical: 18.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '© ${DateTime.now().year} AVM Global Consultants. All rights reserved.',
              style: GoogleFonts.notoSans(
                fontSize: isMobile ? 11 : 12,
                color: Colors.white54,
              ),
            ),
          ),
          InkWell(
            onTap: onContactTap,
            child: Text(
              'Privacy & Terms',
              style: GoogleFonts.notoSans(
                fontSize: isMobile ? 11 : 12,
                color: const Color(0xFF38BDF8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper UI methods
  Widget _buildFooterHeading(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.go(route),
        hoverColor: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chevron_right_rounded, size: 15, color: Colors.white38),
            const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionLink(String text, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chevron_right_rounded, size: 15, color: Colors.white38),
            const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF38BDF8)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 12.5,
              height: 1.4,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileChip(BuildContext context, String text, String route) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
