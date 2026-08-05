import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_us_base_page.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 700;
    const darkBlue = Color(0xFF0A192F);
    const themeColor = Color(0xFF146EB8);

    final List<Map<String, String>> locations = [
      {
        'country': 'India (Corporate HQ)',
        'city': 'Bhubaneswar, Odisha',
        'address': '113, BapujiNagar, Bhubaneswar',
        'phone': '+91-9668102226',
        'email': 'vishal@globalconsultants.com',
      },
      {
        'country': 'Germany (European Branch)',
        'city': 'Munich, Bavaria',
        'address': 'Leopoldstraße 244, 80807 München, Germany',
        'phone': '+49 89 2019 7543',
        'email': 'eu@avmglobalconsultants.com',
      },
      {
        'country': 'United Arab Emirates',
        'city': 'Dubai',
        'address': 'Office 405, Business Avenue Building, Port Saeed, Deira, Dubai, UAE',
        'phone': '+971 4 250 8899',
        'email': 'gulf@avmglobalconsultants.com',
      },
    ];

    return AboutUsBasePage(
      title: 'Our Locations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Globally Connected, Locally Grounded',
            style: GoogleFonts.notoSans(
              fontSize: isMobile ? 20 : 26,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We operate across multiple global hubs to ensure smooth candidate processing, seamless employer relations, and direct compliance checkups. Visit any of our international offices or reach out locally.',
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
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              mainAxisExtent: isMobile ? 250 : 280,
            ),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final loc = locations[index];
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: themeColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc['country']!,
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc['city']!,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        loc['address']!,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded, size: 14, color: Colors.black38),
                        const SizedBox(width: 8),
                        Text(
                          loc['phone']!,
                          style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.email_rounded, size: 14, color: Colors.black38),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc['email']!,
                            style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
