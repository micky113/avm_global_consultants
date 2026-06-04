import 'package:flutter/material.dart';
import '../models/job_opening.dart';
import '../utils/responsive.dart';

class JobsBoard extends StatefulWidget {
  final Function(String country, String jobTitle) onApply;

  const JobsBoard({
    super.key,
    required this.onApply,
  });

  @override
  State<JobsBoard> createState() => _JobsBoardState();
}

class _JobsBoardState extends State<JobsBoard> {
  final List<JobOpening> _jobs = const [
    JobOpening(
      id: 'job1',
      title: 'Senior Software Engineer (Flutter/Go)',
      country: 'Germany',
      industry: 'Information Technology',
      salaryRange: '€65,000 - €85,000 / year',
      requirements: [
        '5+ years experience with Flutter/Dart or Golang',
        'Strong communication skills in English (C1)',
        'Degree in Computer Science or equivalent experience'
      ],
    ),
    JobOpening(
      id: 'job2',
      title: 'Registered General Nurse (ICU/ER)',
      country: 'Canada',
      industry: 'Healthcare & Medicine',
      salaryRange: '\$72,000 - \$95,000 / year',
      requirements: [
        'BSc in Nursing with active license',
        'Clear NCLEX-RN passing certificate',
        'IELTS score of 7.0 or equivalent'
      ],
    ),
    JobOpening(
      id: 'job3',
      title: 'Restaurant Operations Manager',
      country: 'United Arab Emirates (UAE)',
      industry: 'Hospitality & Culinary',
      salaryRange: 'AED 12,000 - 16,000 / month',
      requirements: [
        'Degree in Hospitality or Business Admin',
        '3+ years experience in 5-star hotel/luxury resorts',
        'Strong leadership and budgeting skills'
      ],
    ),
    JobOpening(
      id: 'job4',
      title: 'CNC Precision Machinist',
      country: 'Poland',
      industry: 'Manufacturing & Industrial',
      salaryRange: 'PLN 6,000 - 8,000 / month',
      requirements: [
        'Vocational training in machining',
        '2+ years operating 3-axis / 5-axis CNC machines',
        'Ability to read blueprints and technical specifications'
      ],
    ),
    JobOpening(
      id: 'job5',
      title: 'Senior Structural Design Engineer',
      country: 'Australia',
      industry: 'Engineering & Construction',
      salaryRange: 'AUD 95,000 - \$120,000 / year',
      requirements: [
        'Bachelor of Civil/Structural Engineering',
        'Chartered status (Engineers Australia) preferred',
        'Proficiency in SpaceGass, ETABS, or RAM'
      ],
    ),
    JobOpening(
      id: 'job6',
      title: 'Automotive Mechanical Specialist',
      country: 'United Kingdom (UK)',
      industry: 'Automotive & Repairs',
      salaryRange: '£32,000 - £42,000 / year',
      requirements: [
        'NVQ Level 3 in Light Vehicle Repair or equivalent',
        '4+ years diagnostic experience at a franchise dealer',
        'Valid clean driving license'
      ],
    ),
  ];

  String? hoveredJobId;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    return Container(
      width: double.infinity,
      color: Colors.white,
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
              // Header
              Text(
                'ACTIVE OPPORTUNITIES',
                style: TextStyle(
                  color: const Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Explore Global Job Openings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: const Color(0xFF0A192F),
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
              const SizedBox(height: 16),
              Text(
                'We are actively hiring for the following verified positions. Click Apply to begin your registration.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 60),

              // Grid list
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _jobs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile
                      ? 1
                      : isTablet
                          ? 2
                          : 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  mainAxisExtent: 420, // Increased height to prevent vertical overflows
                ),
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  return _jobCard(job);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jobCard(JobOpening job) {
    final bool isHovered = hoveredJobId == job.id;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredJobId = job.id),
      onExit: (_) => setState(() => hoveredJobId = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHovered ? const Color(0xFFD4AF37) : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? const Color(0xFF0A192F).withOpacity(0.08)
                  : Colors.black.withOpacity(0.02),
              blurRadius: isHovered ? 20 : 10,
              offset: isHovered ? const Offset(0, 10) : const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country and Industry Tags
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A192F).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF0A192F)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          job.country,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A192F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  job.industry,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Job Title
            Text(
              job.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A192F),
              ),
            ),
            const SizedBox(height: 8),

            // Salary Range
            Text(
              job.salaryRange,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 24, thickness: 1),

            // Requirements List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: job.requirements.take(2).map((req) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFFD4AF37),
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            req,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Apply Button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(job.country, job.title);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHovered ? const Color(0xFFD4AF37) : const Color(0xFF0A192F),
                  foregroundColor: isHovered ? const Color(0xFF0A192F) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
