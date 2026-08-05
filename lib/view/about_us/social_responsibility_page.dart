import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_us_base_page.dart';

class SocialResponsibilityPage extends StatelessWidget {
  const SocialResponsibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 700;
    const themeColor = Color(0xFF146EB8);

    final List<Map<String, dynamic>> initiatives = [
      {
        'title': 'Ethical Recruitment & Zero-Exploitation Policy',
        'description': 'We adhere to the highest standard of international recruiting ethics. We guarantee absolute transparency, no hidden candidate charging fees, and zero tolerance for worker exploitation.',
        'icon': Icons.gavel_rounded,
      },
      {
        'title': 'AVM Global Academy & Skills Training',
        'description': 'We empower local job seekers with language courses, technical certification training, and cultural adaptation seminars to prepare them for global markets.',
        'icon': Icons.school_rounded,
      },
      {
        'title': 'Relocation & Settlement Integration',
        'description': 'Going abroad is more than just getting a job. We actively support placed candidates with relocation planning, community integration, and local support networks to help them adapt safely.',
        'icon': Icons.home_work_rounded,
      },
      {
        'title': 'Gender Diversity in Global Placement',
        'description': 'We lead programs specifically designed to support female professionals seeking opportunities in STEM and healthcare domains globally, promoting gender parity in international hiring.',
        'icon': Icons.people_outline_rounded,
      },
    ];

    return AboutUsBasePage(
      title: 'Social Responsibility',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Making a Positive Impact Across Borders',
            style: GoogleFonts.notoSans(
              fontSize: isMobile ? 20 : 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A192F),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'At AVM Global, we believe recruiting is a social service that transforms lives and communities. Our goal is not just to place talent, but to do so ethically, responsibly, and sustainably. We focus on candidate support, education, and community integration.',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: initiatives.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final item = initiatives[index];
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.black12.withOpacity(0.05)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: themeColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0A192F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['description'] as String,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.5,
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
