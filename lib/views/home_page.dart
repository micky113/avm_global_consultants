import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/jobs_board.dart';
import '../widgets/registration_form.dart';
import '../widgets/testimonials_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // GlobalKeys for scrolling sections
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _jobsKey = GlobalKey();
  final GlobalKey<RegistrationFormState> _registerKey = GlobalKey<RegistrationFormState>();
  final GlobalKey _testimonialsKey = GlobalKey();

  late final Map<String, GlobalKey> _sectionKeys;

  @override
  void initState() {
    super.initState();
    _sectionKeys = {
      'Home': _homeKey,
      'About': _aboutKey,
      'Jobs': _jobsKey,
      'Register': _registerKey,
      'Testimonials': _testimonialsKey,
    };
  }

  void _scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToSectionAndPrefill(String country, String jobTitle) {
    if (_registerKey.currentContext != null) {
      Scrollable.ensureVisible(
        _registerKey.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
    // Access the state to pre-fill Preferred Country
    _registerKey.currentState?.prefill(country, jobTitle);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      appBar: NavBar(
        sectionKeys: _sectionKeys,
        onRegisterClick: () => _scrollToSection(_registerKey),
      ),
      drawer: (isMobile || Responsive.isTablet(context)) ? _buildMobileDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero (Home) Section
            HeroSection(
              key: _homeKey,
              jobsKey: _jobsKey,
              registerKey: _registerKey,
            ),

            // 2. About Us Section
            AboutSection(key: _aboutKey),

            // 3. Jobs Board Section
            JobsBoard(
              key: _jobsKey,
              onApply: _scrollToSectionAndPrefill,
            ),

            // 4. Candidate Registration Form Section
            RegistrationForm(key: _registerKey),

            // 5. Testimonials & Rating Section
            TestimonialsSection(key: _testimonialsKey),

            // 6. Corporate Footer Section
            _buildFooter(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scrollToSection(_homeKey),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: const Color(0xFF0A192F),
        tooltip: 'Scroll to Top',
        mini: true,
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  // Mobile navigation Drawer
  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0A192F),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header Branding
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                    ),
                    child: const Icon(Icons.public, color: Color(0xFFD4AF37), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AVM GLOBAL WEB',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'CONSULTANTS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD4AF37),
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),

            // Nav links list
            _drawerTile('Home', _homeKey),
            _drawerTile('About Us', _aboutKey),
            _drawerTile('Job Openings', _jobsKey),
            _drawerTile('Registration', _registerKey),
            _drawerTile('Testimonials', _testimonialsKey),

            const Spacer(),
            
            // Onboarding disclaimer in drawer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '© 2026 AVM Global Consultants.\nMinistry of External Affairs Approved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 11, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(String title, GlobalKey key) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      leading: const Icon(Icons.chevron_right, color: Color(0xFFD4AF37), size: 18),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        _scrollToSection(key);
      },
    );
  }

  // Enterprise Footer
  Widget _buildFooter(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFF0A192F), // Slate/Navy 900
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 60.0,
        vertical: 60.0,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _footerColumns(),
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _footerColumns()
                          .map((col) => Expanded(child: col))
                          .toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 48),
              const Divider(color: Colors.white10),
              const SizedBox(height: 24),
              
              // Bottom Footer row
              if (isMobile || Responsive.isTablet(context))
                Column(
                  children: [
                    Text(
                      '© 2026 AVM Global Consultants. All rights reserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        _footerLink('Privacy Policy'),
                        _footerLink('Terms of Service'),
                        _footerLink('Licensing'),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© 2026 AVM Global Consultants. All rights reserved.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    Row(
                      children: [
                        _footerLink('Privacy Policy'),
                        const SizedBox(width: 20),
                        _footerLink('Terms of Service'),
                        const SizedBox(width: 20),
                        _footerLink('Licensing'),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _footerColumns() {
    return [
      // Column 1: Brand & Ministry Registration
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVM GLOBAL CONSULTANTS',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Government Approved Recruiting Agent\nMinistry of External Affairs License No:\nRC-XXXXXXXX/5/XXXX/2026',
            style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _socialButton(Icons.facebook),
              const SizedBox(width: 12),
              _socialButton(Icons.business_outlined), // LinkedIn style placeholder
              const SizedBox(width: 12),
              _socialButton(Icons.alternate_email),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
      // Column 2: Quick Links
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK LINKS',
            style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
          ),
          const SizedBox(height: 20),
          _footerNavButton('Home', _homeKey),
          _footerNavButton('About Us', _aboutKey),
          _footerNavButton('Job Openings', _jobsKey),
          _footerNavButton('Candidate Onboarding', _registerKey),
          _footerNavButton('Success Stories', _testimonialsKey),
          const SizedBox(height: 32),
        ],
      ),
      // Column 3: Global Offices
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OUR OFFICES',
            style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
          ),
          const SizedBox(height: 20),
          _officeLocation('Corporate Office (India)', 'Metro Heights, Bandra West, Mumbai, MH - 400050'),
          const SizedBox(height: 12),
          _officeLocation('Liaison Office (Dubai)', 'Executive Business Center, Sheikh Zayed Road, Dubai, UAE'),
          const SizedBox(height: 32),
        ],
      ),
      // Column 4: Contact info
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GET IN TOUCH',
            style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
          ),
          const SizedBox(height: 20),
          _contactItem(Icons.phone, '+91-22-XXXX-XXXX'),
          const SizedBox(height: 8),
          _contactItem(Icons.email, 'info@avmglobalconsultants.com'),
          const SizedBox(height: 8),
          _contactItem(Icons.support_agent, 'Mon - Sat: 9:30 AM to 6:30 PM'),
          const SizedBox(height: 32),
        ],
      ),
    ];
  }

  Widget _socialButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
        onPressed: () {},
      ),
    );
  }

  Widget _footerNavButton(String title, GlobalKey key) {
    return TextButton(
      onPressed: () => _scrollToSection(key),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ),
    );
  }

  Widget _officeLocation(String title, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Text(address, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
      ],
    );
  }

  Widget _contactItem(IconData icon, String detail) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            detail,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _footerLink(String title) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          title,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ),
    );
  }
}
