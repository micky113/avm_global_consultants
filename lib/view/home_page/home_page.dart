import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avm_global_web/services/firebase_service.dart';
import 'package:avm_global_web/view/admin/admin_dashboard.dart';
import 'package:avm_global_web/view/home_page/widgets/animated_card/animated_card.dart';

import 'package:avm_global_web/view/home_page/widgets/animated_underline_menu_item/animated_underline_menu_item.dart';
import 'package:avm_global_web/view/home_page/widgets/featured_card/featured_card.dart';
import 'package:avm_global_web/view/home_page/widgets/hover_clickable%20button/hover_clickable_button.dart';
import 'package:avm_global_web/view/home_page/widgets/hover_dropdown_button/hover_dropdown_button.dart';
import 'package:avm_global_web/view/home_page/widgets/hover_text/hover_text.dart';
import 'package:avm_global_web/widgets/testimonials_section.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title, required this.dropdownItems});

  final String title;
  bool colorCh = false;
  final List<String> dropdownItems;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color contact_button_color = const Color(0xFF1c6196);
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  static _MyHomePageState? _activeOverlay;
  // Variable to track the hover state
  bool _isHovering = false;
  bool _isHovering1 = false;
  bool _isHovering2 = false;

  final GlobalKey _testimonialsKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final Color contact_button_color = const Color.fromARGB(255, 20, 110, 184);
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF146EB8),
                  Color(0xFF0A192F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'images/logo.png',
                          width: 45,
                          height: 45,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AVM Global',
                            style: GoogleFonts.notoSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Consultants',
                            style: GoogleFonts.notoSans(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: Text('For Businesses', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
            children: [
              'Professional Services',
              'Staffing Services',
              'Expertise',
              'Stratergy & Transformation',
              'Software & Cloud Engineering',
              'Quality Assurance & Engineering',
              'Data Analytics & AI',
              'Service Management',
              'DevOps & DevSecOps',
            ].map((item) => ListTile(
              title: Text(item, style: GoogleFonts.notoSans(fontSize: 14)),
              onTap: () => Navigator.pop(context),
            )).toList(),
          ),
          ExpansionTile(
            title: Text('For Job Seekers', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
            children: [
              'Search IT Jobs',
              'Working with AVM Global',
              'AVM Global Academy',
              'International Programs',
            ].map((item) => ListTile(
              title: Text(item, style: GoogleFonts.notoSans(fontSize: 14)),
              onTap: () => Navigator.pop(context),
            )).toList(),
          ),
          ExpansionTile(
            title: Text('Industries', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
            children: [
              'Healthcare',
              'Technology',
              'Life Sciences',
              'Financial Services & Insurance',
              'Retail & Consumer Packaged Goods',
              'Public Sector',
              'Video Games',
            ].map((item) => ListTile(
              title: Text(item, style: GoogleFonts.notoSans(fontSize: 14)),
              onTap: () => Navigator.pop(context),
            )).toList(),
          ),
          ListTile(
            title: Text('Insights', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: Text('Testimonials', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              _scrollToSection(_testimonialsKey);
            },
          ),
          ExpansionTile(
            title: Text('About Us', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
            children: [
              'Leadership',
              'Social Responsibility',
              'Corporate Careers',
              'Locations',
              'Contact Us',
            ].map((item) => ListTile(
              title: Text(item, style: GoogleFonts.notoSans(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                if (item == 'Contact Us') {
                  _showContactDialog(context);
                }
              },
            )).toList(),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.admin_panel_settings_rounded, color: contact_button_color),
            title: Text(
              'Admin Panel',
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.bold,
                color: contact_button_color,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showAdminDashboard(context);
            },
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    bool colorChange = false;
    return w < 1100
        ? Scaffold(
            appBar: AppBar(
              toolbarHeight: w < 600 ? 65.0 : null,
              backgroundColor: Colors.white,
              titleSpacing: w < 600 ? 16.0 : 8.0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              elevation: 1.0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Row(
                children: [
                  Image.asset(
                    'images/logo.png',
                    fit: BoxFit.contain,
                    width: w < 600 ? null : 60,
                    height: w < 600 ? 52 : 40,
                  ),
                  SizedBox(width: w < 600 ? 10 : 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AVM Global',
                        style: GoogleFonts.notoSans(
                          fontSize: w < 600 ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 20, 110, 184),
                        ),
                      ),
                      Text(
                        'Consultants',
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.w500,
                          fontSize: w < 600 ? 12 : 11,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            endDrawer: _buildDrawer(context),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Hero Banner
                  Stack(
                    children: [
                      Container(
                        height: 380,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/background_image.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 380,
                        color: const Color(0xFF0A192F).withValues(alpha: 0.65),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        top: 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connecting Indian\nTalent with\nGlobal Opportunities',
                              style: GoogleFonts.notoSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Your trusted government-approved gateway to careers in Europe, Middle East, Canada, and Australia.',
                              style: GoogleFonts.notoSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: const BorderRadius.all(Radius.circular(21)),
                              ),
                              height: 50,
                              width: double.infinity,
                              child: InkWell(
                                onTap: () {},
                                child: Center(
                                  child: Text(
                                    'FOR BUSINESSES',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: const BorderRadius.all(Radius.circular(21)),
                              ),
                              height: 50,
                              width: double.infinity,
                              child: InkWell(
                                onTap: () {},
                                child: Center(
                                  child: Text(
                                    'FOR JOB SEEKERS',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 2. SVC Intro Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AVM Global Consultants is a premier overseas manpower recruitment and educational consultancy.',
                          style: GoogleFonts.notoSans(
                            fontSize: 22,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Fully licensed and certified (ISO 9001:2015), we connect top-tier Indian talent with leading global companies. We prioritize candidate satisfaction, transparency, and ethical recruitment practices above all else. Acting as your gateway to international careers, we handle visa processing, background verification, and end-to-end relocation support.',
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 20, 110, 184),
                              width: 2,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                          ),
                          height: 50,
                          width: 200,
                          child: InkWell(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'GET IN TOUCH',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromARGB(255, 20, 110, 184),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color.fromARGB(255, 20, 110, 184),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'images/side_image.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Services Section
                  Container(
                    color: Colors.grey[50],
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Our Core Pillars',
                          style: GoogleFonts.notoSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'We operate on a foundation of trust, transparency, and global reach – helping candidates secure their dream careers and global employers find top-tier talent.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),
                        AnimatedCard(
                          defaultSize: 120,
                          hoverSize: 200,
                          width: w - 40,
                          height: 450,
                          imageName: 'images/faded_logo.png',
                          animatedImage: 'images/prof_logo.png',
                          text1: 'Recruitment Services',
                          text2: 'Connecting Indian talent with leading global companies across Europe, UK, Canada, and the Gulf.',
                        ),
                        const SizedBox(height: 20),
                        AnimatedCard(
                          defaultSize: 80,
                          hoverSize: 150,
                          width: w - 40,
                          height: 450,
                          imageName: 'images/faded_logo.png',
                          animatedImage: 'images/staff_logo.png',
                          text1: 'Visa & Relocation Support',
                          text2: 'Handling full documentation, licensing, background verifications, and end-to-end relocation support.',
                        ),
                      ],
                    ),
                  ),

                  // 4. Expertise Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Sectors We Recruit For',
                          style: GoogleFonts.notoSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'We source and place top-tier talent across six major global industries, ensuring matches that align skills with international requirements.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),
                        FeatureCard(
                          baseColor: const Color(0xFF9e2a2b),
                          icon: Icons.star_border,
                          title: 'Information\nTechnology',
                          firstText: 'Software & Development',
                          secondText: 'Sourcing senior developers & architects.',
                          image: 'images/logo1.png',
                          width: w - 40,
                          height: 450,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          baseColor: const Color(0xFF183a37),
                          icon: Icons.star_border,
                          title: 'Healthcare &\nMedicine',
                          firstText: 'Nursing & General Medicine',
                          secondText: 'Placing registered nurses & doctors.',
                          image: 'images/logo2.png',
                          width: w - 40,
                          height: 450,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          baseColor: const Color(0xFF33507B),
                          icon: Icons.star_border,
                          title: 'Engineering &\nConstruction',
                          firstText: 'Structural & Civil Engineering',
                          secondText: 'Recruiting civil & structural engineers.',
                          image: 'images/logo3.png',
                          width: w - 40,
                          height: 450,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          baseColor: const Color(0xFFdc2f02),
                          icon: Icons.star_border,
                          title: 'Manufacturing &\nIndustrial',
                          firstText: 'Precision & Machinery',
                          secondText: 'CNC machinists, welders & technicians.',
                          image: 'images/logo4.png',
                          width: w - 40,
                          height: 450,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          baseColor: const Color(0xFF869882),
                          icon: Icons.star_border,
                          title: 'Hospitality &\nCulinary',
                          firstText: 'Management & Culinary Arts',
                          secondText: 'Placing operations managers & chefs.',
                          image: 'images/logo5.png',
                          width: w - 40,
                          height: 450,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          baseColor: const Color(0xFF231942),
                          icon: Icons.star_border,
                          title: 'Automotive &\nRepairs',
                          firstText: 'Diagnostics & Repair',
                          secondText: 'Placing automotive engineers & technicians.',
                          image: 'images/logo6.png',
                          width: w - 40,
                          height: 450,
                        ),
                      ],
                    ),
                  ),

                  // 5. Leader Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'images/bottom_image.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'AVM is a Government Approved Recruiting Agency',
                          style: GoogleFonts.notoSans(
                            fontSize: 22,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Licensed by the Ministry of External Affairs, Government of India, we guarantee complete legal compliance, background verifications, and legitimate work contracts for all international job placements.',
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 20, 110, 184),
                              width: 2,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                          ),
                          height: 50,
                          width: 200,
                          child: InkWell(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'LEARN MORE',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromARGB(255, 20, 110, 184),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color.fromARGB(255, 20, 110, 184),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Testimonials Section
                  TestimonialsSection(key: _testimonialsKey),

                  // 6. Contact Footer Section
                  Stack(
                    children: [
                      Image.asset(
                        'images/contact_image.png',
                        fit: BoxFit.cover,
                        width: w,
                        height: 260,
                      ),
                      Container(
                        height: 260,
                        color: const Color(0xFF0A192F).withValues(alpha: 0.55),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        top: 35,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ready to Work Abroad?',
                              style: GoogleFonts.notoSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Register with AVM Global Consultants today and take the first step towards a rewarding global career in your field of expertise.',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                height: 1.3,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: contact_button_color,
                                  width: 2,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                              ),
                              height: 48,
                              width: 180,
                              child: InkWell(
                                onTap: () => _showContactDialog(context),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'CONTACT US',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                          color: contact_button_color,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: contact_button_color,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        : Scaffold(
            endDrawer: _buildDrawer(context),
            appBar: PreferredSize(
            // 1. Define the desired size
            preferredSize: const Size.fromHeight(
              110.0,
            ), // Set new height here (e.g., 100)
            // 2. Place the AppBar inside the child property
            child: AppBar(
              backgroundColor: Colors.white,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                // titlePadding: EdgeInsets.zero, // Remove default title padding
                // centerTitle:
                //     false, // Ensure we don't interfere with our manual positioning
                // The background is the canvas where we use Stack for positioning
                background: Stack(
                  children: [
                    // The logo is positioned explicitly on the left edge and centered vertically
                    Positioned(
                      width: 1800,
                      left: 20.0, // A small margin from the extreme left edge
                      top: 0,
                      bottom: 0,

                      // Wrap the logo in a Center or Align to help with vertical alignment
                      // within the Positioned bounds.
                      child: Stack(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Image.asset(
                            'images/logo.png',
                            fit: BoxFit.fitHeight,
                            width: 160,
                            height: 100, // Logo size
                          ),

                          Positioned(
                            width: 150,
                            left: 95,
                            top: 23,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 3),
                                Text(
                                  'AVM Global',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 20, 110, 184),
                                  ),
                                ),
                                // const SizedBox(height: 55),
                                Text(
                                  'Consultants',
                                  style: GoogleFonts.notoSans(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // You can add other widgets here using Positioned for the center
                    // or right side of the AppBar.
                  ],
                ),
              ),

              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          HoverText(
                            dropdownItems: const [
                              'Professional Services',
                              'Staffing Services',
                              'Expertise',
                              'Stratergy & Transformation',
                              'Software & Cloud Engineering',
                              'Quality Assurance & Engineering',
                              'Data Analytics & AI',
                              'Service Management',
                              'DevOps & DevSecOps',
                            ],
                            // <--- Replace the original Text widget here
                            text: 'For Businesses',
                            // Define your colors clearly
                            defaultStyle: GoogleFonts.notoSans(
                              fontSize: 23,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            hoverStyle: const TextStyle(
                              color: Color.fromARGB(255, 20, 110, 184),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 50),
                          const HoverText(
                            dropdownItems: [
                              'Search IT Jobs',
                              'Working with AVM Global',
                              'AVM Global Academy',
                              'International Programs',
                            ],

                            text: 'For Job Seekers',
                            // Define your colors clearly
                            defaultStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            hoverStyle: TextStyle(
                              color: Color.fromARGB(255, 20, 110, 184),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 50),
                          const HoverText(
                            dropdownItems: [
                              'Healthcare',
                              'Technology',
                              'Life Sciences',
                              'Financial Services & Insurance',
                              'Retail & Consumer Packaged Goods',
                              'Public Sector',
                              'Video Games',
                            ],
                            text: 'Industries',
                            // Define your colors clearly
                            defaultStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            hoverStyle: TextStyle(
                              color: Color.fromARGB(255, 20, 110, 184),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 50),
                          const HoverText(
                            dropdownItems: [],
                            text: 'Insights',
                            // Define your colors clearly
                            defaultStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            hoverStyle: TextStyle(
                              color: Color.fromARGB(255, 20, 110, 184),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 50),
                          HoverText(
                            dropdownItems: const [],
                            text: 'Testimonials',
                            onTap: () => _scrollToSection(_testimonialsKey),
                            defaultStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            hoverStyle: const TextStyle(
                              color: Color.fromARGB(255, 20, 110, 184),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 50),
                          HoverText(
                            dropdownItems: const [
                              'Leadership',
                              'Social Responsibility',
                              'Corporate Careers',
                              'Locations',
                              'Contact Us',
                            ],
                            text: 'About Us',
                            onDropdownItemSelected: (item) {
                              if (item == 'Contact Us') {
                                _showContactDialog(context);
                              }
                            },
                            // Define your colors clearly
                            defaultStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            hoverStyle: const TextStyle(
                              color: Color.fromARGB(255, 20, 110, 184),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 50),
                          Builder(
                            builder: (BuildContext innerContext) {
                              return HoverText(
                                dropdownItems: const [],
                                text: 'Menu',
                                onTap: () {
                                  Scaffold.of(innerContext).openEndDrawer();
                                },
                                defaultStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                hoverStyle: const TextStyle(
                                  color: Color.fromARGB(255, 20, 110, 184),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                          // IconButton(
                          //   icon: const Icon(Icons.menu),
                          //   onPressed: () {
                          //     // Handle settings action
                          //     print('Settings pressed!');
                          //   },
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 600,
                      // Use BoxDecoration to fill the entire container with the image
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'images/background_image.png',
                          ), // Replace with your image path
                          fit:
                              BoxFit
                                  .cover, // Ensures the image covers the entire screen, cropping if necessary
                        ),
                      ),

                      // Set the container to fill the entire screen space
                    ),
                    Container(
                      height: 600,
                      color: const Color(0xFF0A192F).withValues(alpha: 0.65),
                    ),
                    Positioned(
                      left: 70,
                      top: 50,
                      child: Text(
                        textAlign: TextAlign.left,
                        'Connecting Indian \nTalent with\nGlobal Opportunities',
                        style: GoogleFonts.notoSans(
                          fontSize: 47,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 70,
                      top: 290,
                      child: Text(
                        textAlign: TextAlign.left,
                        'Your trusted government-approved gateway to careers in Europe, Middle East, Canada, and Australia.',
                        style: GoogleFonts.notoSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 70,
                      top: 400,
                      child: Container(
                        // color: Colors.black,
                        decoration: BoxDecoration(
                          color:
                              _isHovering == true
                                  ? Colors.white
                                  : Colors.transparent,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(21)),
                        ),
                        height: 60,
                        width: 200,
                        child: InkWell(
                          onHover: (value) {
                            setState(() {
                              _isHovering = value;
                            });
                          },

                          hoverColor: Colors.transparent,
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'EXPLORE JOBS',
                                style: GoogleFonts.notoSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _isHovering == true
                                          ? Color.fromARGB(255, 20, 110, 184)
                                          : Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color:
                                    _isHovering == true
                                        ? Color.fromARGB(255, 20, 110, 184)
                                        : Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 300,
                      top: 400,
                      child: Container(
                        // color: Colors.black,
                        decoration: BoxDecoration(
                          color:
                              _isHovering1 == true
                                  ? Colors.white
                                  : Colors.transparent,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(21)),
                        ),
                        height: 60,
                        width: 200,
                        child: InkWell(
                          onHover: (secondvalue) {
                            setState(() {
                              _isHovering1 = secondvalue;
                            });
                          },

                          hoverColor: Colors.transparent,
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'REGISTER NOW',
                                style: GoogleFonts.notoSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _isHovering1 == true
                                          ? Color.fromARGB(255, 20, 110, 184)
                                          : Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color:
                                    _isHovering1 == true
                                        ? Color.fromARGB(255, 20, 110, 184)
                                        : Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 500,
                  width: 1100,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 50,
                        top: 70,
                        child: Text(
                          'AVM Global Consultants is a premier\noverseas manpower recruitment and\neducational consultancy.',
                          style: GoogleFonts.notoSans(
                            fontSize: 25,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 50,
                        top: 220,
                        child: Text(
                          'Fully licensed and certified (ISO 9001:2015), we connect top-tier Indian\ntalent with leading global companies. We prioritize candidate satisfaction,\ntransparency, and ethical recruitment practices above all else. Acting as\nyour gateway to international careers, we handle visa processing,\nbackground verification, and end-to-end relocation support.',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 50,
                        top: 380,
                        child: Container(
                          // color: Colors.black,
                          decoration: BoxDecoration(
                            color:
                                _isHovering1 == true
                                    ? Color.fromARGB(255, 20, 110, 184)
                                    : Colors.transparent,
                            border: Border.all(
                              color: Color.fromARGB(255, 20, 110, 184),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          height: 50,
                          width: 200,
                          child: InkWell(
                            onHover: (secondvalue) {
                              setState(() {
                                _isHovering1 = secondvalue;
                              });
                            },

                            hoverColor: Colors.transparent,
                            onTap: () {},
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,

                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'GET IN TOUCH',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _isHovering1 == true
                                            ? Colors.white
                                            : Color.fromARGB(255, 20, 110, 184),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color:
                                      _isHovering1 == true
                                          ? Colors.white
                                          : Color.fromARGB(255, 20, 110, 184),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 710,
                        top: 80,

                        child: Container(
                          color: Colors.grey,
                          width: 320,
                          height: 330,
                        ),
                      ),
                      Positioned(
                        left: 700,
                        top: 90,
                        child: Image.asset(
                          'images/side_image.png',
                          fit: BoxFit.cover,
                          width: 320,
                          height: 330,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Our Core Pillars',
                        style: GoogleFonts.notoSans(
                          fontSize: 23,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 28),
                      Text(
                        'We operate on a foundation of trust, transparency, and global reach – helping candidates\n                       secure their dream careers and global employers find top-tier talent.',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AnimatedCard(
                            defaultSize: 240,
                            hoverSize: 480,
                            imageName: 'images/faded_logo.png',
                            animatedImage: 'images/prof_logo.png',
                            text1: 'Recruitment Services',
                            text2:
                                'Connecting Indian talent with leading global companies across Europe, UK, Canada, and the Gulf.',
                          ),
                          AnimatedCard(
                            defaultSize: 120,
                            hoverSize: 240,
                            imageName: 'images/faded_logo.png',
                            animatedImage: 'images/staff_logo.png',
                            text1: 'Visa & Relocation Support',
                            text2:
                                'Handling full documentation, licensing, background verifications, and end-to-end relocation support.',
                          ),
                          /*
                          Stack(
                            children: [
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  height: 480,
                                  width: 600,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    color: Color.fromARGB(255, 20, 110, 184),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image:
                                          Image.asset(
                                            'images/faded_logo.png',
                                          ).image,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: Image.asset(
                                    'images/prof_logo.png',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          */
                          // InkWell(
                          //   onTap: () {},
                          //   child: Container(
                          //     height: 480,
                          //     width: 600,
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.all(
                          //         Radius.circular(20),
                          //       ),
                          //       color: Color.fromARGB(255, 20, 110, 184),
                          //       image: DecorationImage(
                          //         fit: BoxFit.cover,
                          //         image:
                          //             Image.asset(
                          //               'images/faded_logo.png',
                          //             ).image,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      // Row(children: [
                      //   // InkWell(
                      //   //   onTap: (){},
                      //   //   child: Container(
                      //   //     height: 100,
                      //   //     width: 100,
                      //   //     decoration: BoxDecoration(
                      //   //       color: Colors.blue
                      //   //     ),
                      //   //   ),
                      //   // ),
                      //   InkWell(
                      //     onTap: (){},
                      //   )
                      // ],)
                    ],
                  ),
                ),
                SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Sectors We Recruit For',
                        style: GoogleFonts.notoSans(
                          fontSize: 23,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 28),
                      Text(
                        'We source and place top-tier talent across six major global industries, ensuring matches that align skills with international requirements.',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      // Simplified structure for the three cards on a large screen:
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: FeatureCard(
                                baseColor: Color(0xFF9e2a2b), // Dark Blue
                                icon: Icons.star_border,
                                title: 'Information\nTechnology',
                                firstText: 'Software & Development',
                                secondText: 'Sourcing senior developers & architects.',
                                image: 'images/logo1.png',
                              ),
                            ), // Card 1
                            SizedBox(width: 40),
                            Expanded(
                              child: FeatureCard(
                                baseColor: Color(0xFF183a37), // Dark Blue
                                icon: Icons.star_border,
                                title: 'Healthcare &\nMedicine',
                                firstText: 'Nursing & General Medicine',
                                secondText: 'Placing registered nurses & doctors.',
                                image: 'images/logo2.png',
                              ),
                            ), // Card 2
                            SizedBox(width: 40),
                            Expanded(
                              child: FeatureCard(
                                baseColor: Color(0xFF33507B), // Dark Blue
                                icon: Icons.star_border,
                                title: 'Engineering &\nConstruction',
                                firstText: 'Structural & Civil Engineering',
                                secondText: 'Recruiting civil & structural engineers.',
                                image: 'images/logo3.png',
                              ),
                            ), // Card 3
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: FeatureCard(
                                baseColor: Color(0xFFdc2f02), // Dark Blue
                                icon: Icons.star_border,
                                title: 'Manufacturing &\nIndustrial',
                                firstText: 'Precision & Machinery',
                                secondText: 'CNC machinists, welders & technicians.',
                                image: 'images/logo4.png',
                              ),
                            ), // Card 1
                            SizedBox(width: 40),
                            Expanded(
                              child: FeatureCard(
                                baseColor: Color(0xFF869882), // Dark Blue
                                icon: Icons.star_border,
                                title: 'Hospitality &\nCulinary',
                                firstText: 'Management & Culinary Arts',
                                secondText: 'Placing operations managers & chefs.',
                                image: 'images/logo5.png',
                              ),
                            ), // Card 2
                            SizedBox(width: 40),
                            Expanded(
                              child: FeatureCard(
                                baseColor: Color(0xFF231942), // Dark Blue
                                icon: Icons.star_border,
                                title: 'Automotive &\nRepairs',
                                firstText: 'Diagnostics & Repair',
                                secondText: 'Placing automotive engineers & technicians.',
                                image: 'images/logo6.png',
                              ),
                            ), // Card 3
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 500,
                  width: 1100,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 140,
                        top: 80,

                        child: Container(
                          color: Colors.grey,
                          width: 320,
                          height: 330,
                        ),
                      ),
                      Positioned(
                        left: 130,
                        top: 90,
                        child: Image.asset(
                          'images/bottom_image.png',
                          fit: BoxFit.cover,
                          width: 320,
                          height: 330,
                        ),
                      ),
                      Positioned(
                        left: 500,
                        top: 130,
                        child: Text(
                          'AVM is a Government Approved \nRecruiting Agency',
                          style: GoogleFonts.notoSans(
                            fontSize: 25,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 500,
                        top: 220,
                        child: Text(
                          'Licensed by the Ministry of External Affairs, Government of India, we guarantee\ncomplete legal compliance, background verifications, and legitimate work\ncontracts for all international job placements.',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 500,
                        top: 320,
                        child: Container(
                          // color: Colors.black,
                          decoration: BoxDecoration(
                            color:
                                _isHovering1 == true
                                    ? Color.fromARGB(255, 20, 110, 184)
                                    : Colors.transparent,
                            border: Border.all(
                              color: Color.fromARGB(255, 20, 110, 184),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          height: 50,
                          width: 200,
                          child: InkWell(
                            onHover: (secondvalue) {
                              setState(() {
                                _isHovering1 = secondvalue;
                              });
                            },

                            hoverColor: Colors.transparent,
                            onTap: () {},
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,

                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'LEARN MORE',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _isHovering1 == true
                                            ? Colors.white
                                            : Color.fromARGB(255, 20, 110, 184),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color:
                                      _isHovering1 == true
                                          ? Colors.white
                                          : Color.fromARGB(255, 20, 110, 184),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Testimonials Section
                TestimonialsSection(key: _testimonialsKey),
                Stack(
                  children: [
                    Image(
                      image: AssetImage('images/contact_image.png'),
                      fit: BoxFit.fitWidth,
                      width: w,
                      height: h / 2.5,
                    ),
                    Container(
                      width: w,
                      height: h / 2.5,
                      color: const Color(0xFF0A192F).withValues(alpha: 0.55),
                    ),
                    Positioned(
                      top: 50,
                      left: 150,
                      child: Text(
                        'Ready to Work Abroad?',
                        style: GoogleFonts.notoSans(
                          fontSize: 25,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 95,
                      left: 150,
                      child: Text(
                        'Register with AVM Global Consultants today and take the first step\ntowards a rewarding global career in your field of expertise.',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    //****thin Line*****/
                    Positioned(
                      top: 165,
                      right: 430,
                      child: Container(
                        height: 2,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: contact_button_color,
                        ),
                      ),
                    ),
                    //****Fat Line *****/
                    Positioned(
                      top: 162,
                      right: 580,
                      child: Container(
                        height: 8,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: contact_button_color,
                        ),
                      ),
                    ),
                    //****CONTACT US button*****/
                    Positioned(
                      right: 260,
                      top: 140,
                      child: _HoverButton(
                        text: 'CONTACT US',
                        onTap: () => _showContactDialog(context),
                        primaryColor: Colors.white,
                        textColor: contact_button_color,
                        hoverColor: contact_button_color,
                        hoverTextColor: Colors.white,
                        borderColor: contact_button_color,
                        icon: Icons.arrow_forward_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h / 2),
              ],
            ),
          ),
        );
  }

  Future<List<String>> getFirebaseImageUrls(List<String> filePaths) async {
    List<String> imageUrlsFuture = [];
    final storageRef = FirebaseStorage.instance.ref();

    for (String path in filePaths) {
      try {
        // Create a reference to the image file
        final imageRef = storageRef.child(path);
        // Get the download URL
        final url = await imageRef.getDownloadURL();
        imageUrlsFuture.add(url);
      } catch (e) {
        print("Error fetching URL for $path: $e");
      }
    }
    return imageUrlsFuture;
  }

  // Usage Example
  final List<String> imagePaths = [
    'images/photo_1.jpg',
    'images/photo_2.jpg',
    'images/photo_3.jpg',
    'images/photo_4.jpg',
  ];

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
                                      _hideOverlay();
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

  // This list of URLs will be used in the widget
  // List<String> imageUrls = await getFirebaseImageUrls(imagePaths);

  // Fetch the list of image URLs from a single Firestore document
  /*
  Future<List<String>> getFirestoreImageUrls() async {
    final docRef = FirebaseFirestore.instance
        .collection('settings')
        .doc('carousel_images');
    final snapshot = await docRef.get();

    if (snapshot.exists && snapshot.data()!.containsKey('urls')) {
      // Cast the list from dynamic to String
      return List<String>.from(snapshot.data()!['urls'] as List);
    }
    return []; // Return an empty list if data is missing
  }

  // This list of URLs will be used in the widget
  // List<String> imageUrls = await getFirestoreImageUrls();
  void _show80PercentDialog(BuildContext context) {
  // Get the total screen size
  final screenSize = MediaQuery.of(context).size;

  // Calculate 80% of the screen size
  final dialogWidth = screenSize.width * 0.8;
  final dialogHeight = screenSize.height * 0.8;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center( // Center is essential for the custom sized dialog
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          
          // Use a Dialog or AlertDialog as the actual content container
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Keep column size minimal
                children: [
                  const Text(
                    '80% Dialog Content',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: Center(
                      child: Text(
                        'This dialog covers ${dialogWidth.toInt()}x${dialogHeight.toInt()} pixels of the screen.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
*/

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: _ContactDialog(themeColor: contact_button_color),
            ),
          ),
        );
      },
    );
  }

  void _showAdminDashboard(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AdminDashboardDialog(themeColor: contact_button_color);
      },
    );
  }
}

class _HoverButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color textColor;
  final Color hoverColor;
  final Color hoverTextColor;
  final Color borderColor;
  final double width;
  final double height;
  final double fontSize;
  final IconData? icon;

  const _HoverButton({
    required this.text,
    required this.onTap,
    required this.primaryColor,
    required this.textColor,
    required this.hoverColor,
    required this.hoverTextColor,
    required this.borderColor,
    this.width = 200,
    this.height = 50,
    this.fontSize = 17,
    this.icon,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverColor : widget.primaryColor,
            border: Border.all(
              color: widget.borderColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: GoogleFonts.notoSans(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: _isHovered ? widget.hoverTextColor : widget.textColor,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 10),
                Icon(
                  widget.icon,
                  color: _isHovered ? widget.hoverTextColor : widget.textColor,
                  size: widget.fontSize + 1,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactDialog extends StatefulWidget {
  final Color themeColor;

  const _ContactDialog({required this.themeColor});

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _jobFieldController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;

  Uint8List? _resumeBytes;
  String? _resumeName;
  bool _isPickingFile = false;

  @override
  void dispose() {
    _nameController.dispose();
    _jobFieldController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _resumeBytes = result.files.single.bytes;
          _resumeName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  void _clearResume() {
    setState(() {
      _resumeBytes = null;
      _resumeName = null;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService.instance.submitContactInquiry(
        name: _nameController.text.trim(),
        jobField: _jobFieldController.text.trim(),
        resumeFileName: _resumeName,
        resumeFileBytes: _resumeBytes,
      );
      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: 'vishal@avmglobalconsultats.com'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Email address copied to clipboard!',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.themeColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildSuccessView();
    }

    return _buildFormView();
  }

  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: 72,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Thank You!',
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "We'll get back to you.",
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Close',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Get in Touch',
                  style: GoogleFonts.notoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  splashRadius: 20,
                  color: Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Fill out the form below or reach us directly via email. We look forward to connecting with you!',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            Text(
              'Your Name',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                hintStyle: GoogleFonts.notoSans(color: Colors.black38, fontSize: 14),
                prefixIcon: Icon(Icons.person_outline_rounded, color: widget.themeColor.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.themeColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Job Search Field
            Text(
              'Interested Line of Job Search',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _jobFieldController,
              decoration: InputDecoration(
                hintText: 'e.g., Software Dev, Nursing, Finance',
                hintStyle: GoogleFonts.notoSans(color: Colors.black38, fontSize: 14),
                prefixIcon: Icon(Icons.work_outline_rounded, color: widget.themeColor.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.themeColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please specify your job field';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Resume Upload Field
            Text(
              'Upload Resume (Optional)',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _isPickingFile ? null : _pickResume,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _resumeName != null ? widget.themeColor : Colors.grey[300]!,
                    width: _resumeName != null ? 2 : 1,
                  ),
                ),
                child: _resumeName != null
                    ? Row(
                        children: [
                          Icon(
                            _resumeName!.endsWith('.pdf')
                                ? Icons.picture_as_pdf_rounded
                                : Icons.description_rounded,
                            color: widget.themeColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _resumeName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Ready to upload',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 11,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _clearResume,
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            splashRadius: 20,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isPickingFile
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1c6196)),
                                  ),
                                )
                              : Icon(
                                  Icons.cloud_upload_outlined,
                                  color: widget.themeColor.withOpacity(0.7),
                                  size: 22,
                                ),
                          const SizedBox(width: 10),
                          Text(
                            _isPickingFile ? 'Selecting file...' : 'Choose PDF, DOC, or DOCX',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Email Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.themeColor.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.alternate_email_rounded,
                    color: widget.themeColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Direct Contact Email',
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          'vishal@avmglobalconsultats.com',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _copyEmail,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.copy_rounded,
                        color: widget.themeColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Application',
                        style: GoogleFonts.notoSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

