import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC), // Smooth Off-White
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 60.0,
        vertical: 80.0,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Header
              Text(
                'ABOUT US',
                style: TextStyle(
                  color: const Color(0xFFD4AF37), // Gold
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Our Foundation of Excellence',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: const Color(0xFF0A192F), // Deep Navy
                  fontWeight: FontWeight.w900,
                  fontSize: isMobile ? 28 : 36,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 80,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'AVM Global Consultants is a premier overseas manpower recruitment and educational consultancy. Fully licensed and certified, we connect top-tier Indian talent with leading global companies. We prioritize client satisfaction, transparency, and ethical recruitment practices above all else.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 60),

              // Pillars Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  if (isMobile) {
                    return Column(
                      children: _buildPillars(),
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildPillars()
                          .map((w) => Expanded(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12.0),
                                child: w,
                              )))
                          .toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 60),

              // Placements Statistics Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A192F), // Navy Blue
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (isMobile) {
                      return Column(
                        children: _buildStats(divider: true),
                      );
                    } else {
                      return Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: 32,
                        runSpacing: 24,
                        children: _buildStats(divider: false),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPillars() {
    return [
      _pillarCard(
        icon: Icons.gavel_rounded,
        title: 'Trust & Credibility',
        description:
            'Government approved recruitment process. We guarantee full legal compliance, background verifications, and legitimate work contracts.',
      ),
      _pillarCard(
        icon: Icons.remove_red_eye_outlined,
        title: 'Complete Transparency',
        description:
            'No hidden fees or misleading clauses. Candidates and employers receive detailed progress updates at every single stage of processing.',
      ),
      _pillarCard(
        icon: Icons.language_rounded,
        title: 'Global Reach',
        description:
            'Active partnerships in Germany, UK, Canada, UAE, Saudi Arabia, and Australia. We source and place roles across 10+ industries globally.',
      ),
    ];
  }

  Widget _pillarCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A192F),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStats({required bool divider}) {
    final items = [
      _statItem('5,000+', 'Placed Candidates'),
      _statItem('15+', 'Destination Countries'),
      _statItem('98%', 'Visa Success Rate'),
      _statItem('10+', 'Years Experience'),
    ];

    if (!divider) return items;

    List<Widget> columnList = [];
    for (int i = 0; i < items.length; i++) {
      columnList.add(items[i]);
      if (i < items.length - 1) {
        columnList.add(
          Divider(
            color: Colors.white.withOpacity(0.1),
            height: 32,
            thickness: 1,
          ),
        );
      }
    }
    return columnList;
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Color(0xFFD4AF37), // Gold
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
