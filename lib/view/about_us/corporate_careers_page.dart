import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_us_base_page.dart';

class CorporateCareersPage extends StatelessWidget {
  const CorporateCareersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 700;
    const themeColor = Color(0xFF146EB8);
    const darkBlue = Color(0xFF0A192F);

    final List<Map<String, String>> benefits = [
      {
        'title': 'Global Exposure',
        'desc': 'Interact with international clients, candidates, and immigration bodies regularly.',
        'icon': '🌍',
      },
      {
        'title': 'Continuous Learning',
        'desc': 'Get sponsored training on international laws, visa processes, and language development.',
        'icon': '📚',
      },
      {
        'title': 'Exciting Incentives',
        'desc': 'Competitive base salaries along with lucrative bonuses based on placements.',
        'icon': '🏆',
      },
      {
        'title': 'Collaborative Culture',
        'desc': 'Enjoy a flat hierarchy, supportive teammates, and regular engagement activities.',
        'icon': '🤝',
      },
    ];

    return AboutUsBasePage(
      title: 'Corporate Careers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grow Your Career with AVM Global',
            style: GoogleFonts.notoSans(
              fontSize: isMobile ? 20 : 26,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Are you passionate about helping people build their dream careers abroad? Do you want to build a career in global mobility, HR tech, or immigration law? Join AVM Global Consultants. We are a team of ethical, fast-paced professionals working together to enable global connections.',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Why Work With Us?',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              mainAxisExtent: isMobile ? 140 : 120,
            ),
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              final benefit = benefits[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.black12.withOpacity(0.04)),
                ),
                child: Row(
                  children: [
                    Text(
                      benefit['icon']!,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            benefit['title']!,
                            style: GoogleFonts.notoSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            benefit['desc']!,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: Colors.black54,
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
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: themeColor.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Our Talent Community',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We are always looking for recruiters, client relationship managers, visa compliance executives, and tech developers. Even if you do not see an immediate opening, we would love to hear from you.',
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Contact Us or open mail
                    context.go('/about/contact-us');
                  },
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Send Your Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
