import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_us_base_page.dart';

class LeadershipPage extends StatelessWidget {
  const LeadershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 700;

    final List<Map<String, String>> leaders = [
      {
        'name': 'Vishal Mohapatra',
        'role': 'Founder & Managing Director',
        'bio': 'Vishal founded AVM Global with a vision to streamline international employment and recruitment. With over 15 years of industry experience, he guides the strategic expansion of the firm across Europe and the Gulf.',
        'image': 'VM',
      },
      {
        'name': 'Arunav Mohanty',
        'role': 'Chief Technology Officer (CTO)',
        'bio': 'Arunav oversees the technological vision of AVM Global. He leads the development of our global recruitment platform, automated job-matching systems, and secure portal integrations.',
        'image': 'AM',
      },
      {
        'name': 'Sarah Jenkins',
        'role': 'Director of European Operations',
        'bio': 'Sarah leads client partnerships and placement strategy across Germany, Poland, and the UK. She specializes in global immigration compliance and labor market integration.',
        'image': 'SJ',
      },
      {
        'name': 'Rajesh Kumar',
        'role': 'Head of Recruitment & Sourcing',
        'bio': 'Rajesh oversees candidate screening and assessment processes. He ensures matches that align skills with international requirements across healthcare, tech, and engineering.',
        'image': 'RK',
      },
      {
        'name': 'Elena Rostova',
        'role': 'Chief Legal Compliance Officer',
        'bio': 'Elena ensures end-to-end legal compliance with government regulations and international work permits, assuring candidates of secure contracts.',
        'image': 'ER',
      },
    ];

    return AboutUsBasePage(
      title: 'Our Leadership',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meet the Visionaries Driving Global Talent Success',
            style: GoogleFonts.notoSans(
              fontSize: isMobile ? 20 : 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A192F),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Our leadership team brings together decades of cumulative experience in international recruitment, immigration law, and corporate consulting. We are dedicated to bridging the gap between top-tier talent and global career milestones.',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
              mainAxisExtent: isMobile ? 280 : 240,
            ),
            itemCount: leaders.length,
            itemBuilder: (context, index) {
              final leader = leaders[index];
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.black12.withOpacity(0.05)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFF146EB8).withOpacity(0.1),
                      child: Text(
                        leader['image']!,
                        style: GoogleFonts.notoSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF146EB8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leader['name']!,
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0A192F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            leader['role']!,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF146EB8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                leader['bio']!,
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
