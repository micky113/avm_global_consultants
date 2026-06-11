import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avm_global_web/view/home_page/widgets/animated_card/animated_card.dart';

import 'package:avm_global_web/view/home_page/widgets/animated_underline_menu_item/animated_underline_menu_item.dart';
import 'package:avm_global_web/view/home_page/widgets/featured_card/featured_card.dart';
import 'package:avm_global_web/view/home_page/widgets/hover_clickable%20button/hover_clickable_button.dart';
import 'package:avm_global_web/view/home_page/widgets/hover_dropdown_button/hover_dropdown_button.dart';
import 'package:avm_global_web/view/home_page/widgets/hover_text/hover_text.dart';

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
  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    bool colorChange = false;
    return w < 1100
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1.0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Row(
                children: [
                  Image.asset(
                    'images/logo.png',
                    fit: BoxFit.fitHeight,
                    width: 60,
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AVM Global',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 20, 110, 184),
                        ),
                      ),
                      Text(
                        'Consultants',
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            endDrawer: Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 20, 110, 184),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'AVM Menu',
                          style: GoogleFonts.notoSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AVM Global Consultants',
                          style: GoogleFonts.notoSans(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
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
                      onTap: () => Navigator.pop(context),
                    )).toList(),
                  ),
                ],
              ),
            ),
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
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        top: 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fueled by Passion,\nMeasured by\nImpact',
                              style: GoogleFonts.notoSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Creating opportunities for tech talent and\ninnovative organizations',
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
                          'AVM is a global leader in technology services and talent, delivering transformative solutions at the speed of change.',
                          style: GoogleFonts.notoSans(
                            fontSize: 22,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'AVM empowers organizations to modernize tech infrastructure, streamline operations, and accelerate innovation through expert consulting services in cloud, AI, data and application. We deliver agile solutions and top-tier tech talent that reduce cost, mitigate risk, and simplify complexity. Acting as an extension of your team, we provide deep expertise and measurable results – at scale.',
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
                          'Services',
                          style: GoogleFonts.notoSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'We deliver flexible, scalable solutions that meet organizations where they are – helping clients accelerate outcomes, optimize operations and stay future-ready.',
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
                          height: 380,
                          imageName: 'images/faded_logo.png',
                          animatedImage: 'images/prof_logo.png',
                          text1: 'Professional Services',
                          text2: 'Driving value across the full technology life cycle.',
                        ),
                        const SizedBox(height: 20),
                        AnimatedCard(
                          defaultSize: 80,
                          hoverSize: 150,
                          width: w - 40,
                          height: 380,
                          imageName: 'images/faded_logo.png',
                          animatedImage: 'images/staff_logo.png',
                          text1: 'Staffing Services',
                          text2: 'Delivering success through our fast and flexible talent network.',
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
                          'Expertise',
                          style: GoogleFonts.notoSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Our business drives long-term customer success through six specialized areas – delivering measurable impact in technology, talent and digital transformation',
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
                          title: 'Strategy &\nTransformation',
                          firstText: 'Fueling Vision',
                          secondText: 'Delivering Value.',
                          image: 'images/logo1.png',
                          width: w - 40,
                          height: 450,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          baseColor: const Color(0xFF183a37),
                          icon: Icons.star_border,
                          title: 'Software & Cloud\nEngineering',
                          firstText: 'Robust Software',
                          secondText: 'Seamless Integration.',
                          image: 'images/logo2.png',
                          width: w - 40,
                          height: 450,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          baseColor: const Color(0xFF33507B),
                          icon: Icons.star_border,
                          title: 'Quality Assurance &\nEngineering',
                          firstText: 'Elevate Quality',
                          secondText: 'Accelerate Delivery.',
                          image: 'images/logo3.png',
                          width: w - 40,
                          height: 450,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          baseColor: const Color(0xFFdc2f02),
                          icon: Icons.star_border,
                          title: 'Data, Analytics & AI',
                          firstText: 'Smarter Data,',
                          secondText: 'Faster Decisions.',
                          image: 'images/logo4.png',
                          width: w - 40,
                          height: 450,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          baseColor: const Color(0xFF869882),
                          icon: Icons.star_border,
                          title: 'Service Management',
                          firstText: 'Streamline Services,',
                          secondText: 'Optimize Experience.',
                          image: 'images/logo5.png',
                          width: w - 40,
                          height: 450,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          baseColor: const Color(0xFF231942),
                          icon: Icons.star_border,
                          title: 'DevOps & DevSecOps',
                          firstText: 'Drive Innovation,',
                          secondText: 'Enhance Security.',
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
                          'AVM is a Global Leader in Tech Workforce Solutions',
                          style: GoogleFonts.notoSans(
                            fontSize: 22,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Recognized by Everest Group as a Leader on the PEAK Matrix® for the fourth consecutive year, we deliver unmatched expertise and real results. See how our solutions accelerate success',
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
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        top: 35,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Get In Touch',
                              style: GoogleFonts.notoSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'See how AVM can deliver the most powerful combination of professional and staffing services to drive business performance.',
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
                                onTap: () {},
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
          appBar: PreferredSize(
            // 1. Define the desired size
            preferredSize: const Size.fromHeight(
              110.0,
            ), // Set new height here (e.g., 100)
            // 2. Place the AppBar inside the child property
            child: AppBar(
              backgroundColor: Colors.white,
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
                          const HoverText(
                            dropdownItems: [
                              'Leadership',
                              'Social Responsibility',
                              'Corporate Careers',
                              'Locations',
                              'Contact Us',
                            ],

                            text: 'About Us',
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
                          HoverClickableButton(
                            text: 'Menu',
                            dropdownItems: ['Drawer Box'],
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

                          //       Builder(
                          //         builder: (BuildContext innerContext) {
                          //           return AnimatedUnderlineMenuItem(
                          //             text: 'Menu',
                          //             onTap: () {

                          // //  _showOverlay();
                          //               Scaffold.of(
                          //                 innerContext,
                          //               ).openEndDrawer();
                          //             },
                          //           );
                          //         },
                          //       ),
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
                    Positioned(
                      left: 70,
                      top: 50,
                      child: Text(
                        textAlign: TextAlign.left,
                        'Fueled by Passion, \nMeasured by\nImpact',
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
                        'Creating oppurtunities for tech talent and, \ninnovative organizations',
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

                          hoverColor:
                              _isHovering == true
                                  ? Colors.white
                                  : Colors.transparent,
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'FOR  BUSINESSES',
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

                          hoverColor:
                              _isHovering1 == true
                                  ? Colors.white
                                  : Colors.transparent,
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'FOR  JOB SEEKERS',
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
                          'AVM is a global leader in technology\nservices and talent, delivering\ntransformative solutions at the speed of\nchange.',
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
                          'AVM empowers organizations to modernize tech infrastructure,\nstreamline operations, and accelerate innovation through expert\nconsulting services in cloud, AI, data and application. We deliver agile\nsolutions and top-tier tech talent that reduce cost, mitigate risk, and\nsimplify complexity. Acting as an extension of your team, we provide\ndeep expertise and measurable results – at scale.',
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

                            hoverColor:
                                _isHovering1 == true
                                    ? Color.fromARGB(255, 20, 110, 184)
                                    : Colors.transparent,
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
                        'Services',
                        style: GoogleFonts.notoSans(
                          fontSize: 23,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 28),
                      Text(
                        'We deliver flexible, scalable solutions that meet organizations where they are – helping clients\n                       accelerate outcomes, optimize operations and stay future-ready.',
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
                            text1: 'Professional Services',
                            text2:
                                'Driving value across the full technology life cycle.',
                          ),
                          AnimatedCard(
                            defaultSize: 120,
                            hoverSize: 240,
                            imageName: 'images/faded_logo.png',
                            animatedImage: 'images/staff_logo.png',
                            text1: 'Staffing Services',
                            text2:
                                'Delivering success through our fast and flexible\n                            talent network.',
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
                        'Expertise',
                        style: GoogleFonts.notoSans(
                          fontSize: 23,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 28),
                      Text(
                        'Our business drives long-term customer success through six specialized areas – delivering\n            measurable impact in technology, talent and digital transformation',
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
                                title: 'Stratergy &\nTransformation',
                                firstText: 'Fueling Vision',
                                secondText: 'Delivering Value.',
                                image: 'images/logo1.png',
                              ),
                            ), // Card 1
                            SizedBox(width: 40),
                            Expanded(
                              child: FeatureCard(
                                baseColor: Color(0xFF183a37), // Dark Blue
                                icon: Icons.star_border,
                                title: 'Software & Cloud,\nEngineering',
                                firstText: 'Robust Software',
                                secondText: 'Seamless Integration.',
                                image: 'images/logo2.png',
                              ),
                            ), // Card 2
                            SizedBox(width: 40),
                            Expanded(
                              child: FeatureCard(
                                baseColor: Color(0xFF33507B), // Dark Blue
                                icon: Icons.star_border,
                                title: 'Quality Assurance &,\nEngineering',
                                firstText: 'Elevate Quality',
                                secondText: 'Accelerate Delivery.',
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
                                title: 'Data,Analytics & AI',
                                firstText: 'Smarter Data,',
                                secondText: 'Faster Decisions.',
                                image: 'images/logo4.png',
                              ),
                            ), // Card 1
                            SizedBox(width: 40),
                            Expanded(
                              child: FeatureCard(
                                baseColor: Color(0xFF869882), // Dark Blue
                                icon: Icons.star_border,
                                title: 'Service Management',
                                firstText: 'Streamline Services,',
                                secondText: 'Optimize Experience.',
                                image: 'images/logo5.png',
                              ),
                            ), // Card 2
                            SizedBox(width: 40),
                            Expanded(
                              child: FeatureCard(
                                baseColor: Color(0xFF231942), // Dark Blue
                                icon: Icons.star_border,
                                title: 'DevOps & DevSecOps',
                                firstText: 'Drive Innovation,',
                                secondText: 'Enhance Security.',
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
                          'AVM is a Global Leader in Tech \nWorkforce Solutions',
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
                          'Recognized by Everest Group as a Leader on the PEAK Matrix® for\nthe fourth consecutive year, we deliver unmatched expertise and real\nresults. See how our solutions accelerate success',
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

                            hoverColor:
                                _isHovering1 == true
                                    ? Color.fromARGB(255, 20, 110, 184)
                                    : Colors.transparent,
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
                Stack(
                  children: [
                    Image(
                      image: AssetImage('images/contact_image.png'),
                      fit: BoxFit.fitWidth,
                      width: w,
                      height: h / 2.5,
                    ),
                    Positioned(
                      top: 50,
                      left: 150,
                      child: Text(
                        'Get In Touch',
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
                        'See how AVM can deliver the most powerful combination of\nprofessional and staffing services to drive business\nperformance.',
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
                      child: Container(
                        // color: Colors.black,
                        decoration: BoxDecoration(
                          color:
                              _isHovering2 == true
                                  ? contact_button_color
                                  : Colors.white,
                          border: Border.all(
                            color: contact_button_color,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        height: 50,
                        width: 200,
                        child: InkWell(
                          onHover: (thirdvalue) {
                            setState(() {
                              _isHovering2 = thirdvalue;
                            });
                          },

                          hoverColor:
                              _isHovering2 == true
                                  ? Colors.white
                                  : Colors.transparent,
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CONTACT US',
                                style: GoogleFonts.notoSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                  color:
                                      _isHovering2 == true
                                          ? Colors.white
                                          : contact_button_color,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color:
                                    _isHovering2 == true
                                        ? Colors.white
                                        : contact_button_color,
                              ),
                            ],
                          ),
                        ),
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
}
