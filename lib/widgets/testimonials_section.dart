import 'package:flutter/material.dart';
import '../models/testimonial.dart';
import '../services/firebase_service.dart';
import '../utils/responsive.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  final _reviewFormKey = GlobalKey<FormState>();
  final TextEditingController _reviewNameController = TextEditingController();
  final TextEditingController _reviewRoleController = TextEditingController();
  final TextEditingController _reviewTextController = TextEditingController();

  double _selectedRating = 5.0;
  bool _isSubmittingReview = false;

  Future<void> _submitReview() async {
    if (!_reviewFormKey.currentState!.validate()) return;
    
    setState(() => _isSubmittingReview = true);

    final newReview = Testimonial(
      id: '',
      name: _reviewNameController.text.trim(),
      roleAndCountry: _reviewRoleController.text.trim(),
      reviewText: _reviewTextController.text.trim(),
      rating: _selectedRating,
      timestamp: DateTime.now(),
    );

    try {
      await FirebaseService.instance.submitTestimonial(newReview);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your testimonial has been posted successfully.'),
            backgroundColor: Color(0xFFD4AF37),
          ),
        );
        _resetReviewForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingReview = false);
      }
    }
  }

  void _resetReviewForm() {
    _reviewNameController.clear();
    _reviewRoleController.clear();
    _reviewTextController.clear();
    setState(() {
      _selectedRating = 5.0;
    });
  }

  @override
  void dispose() {
    _reviewNameController.dispose();
    _reviewRoleController.dispose();
    _reviewTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC), // Alternating background to Off-White
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
                'TESTIMONIALS',
                style: TextStyle(
                  color: const Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'What Successfully Placed Candidates Say',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: const Color(0xFF0A192F),
                  fontWeight: FontWeight.w900,
                  fontSize: isMobile ? 26 : 36,
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
              const SizedBox(height: 50),

              // Testimonials Stream Grid (Part A)
              StreamBuilder<List<Testimonial>>(
                stream: FirebaseService.instance.getTestimonialsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A192F)),
                      ),
                    );
                  }

                  final testimonials = snapshot.data ?? [];

                  if (testimonials.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'No testimonials yet. Be the first to leave one below!',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: testimonials.length > 3 ? 3 : testimonials.length, // Limit to top 3
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile
                          ? 1
                          : isTablet
                              ? 2
                              : 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      mainAxisExtent: 260, // Fixed height to prevent overflow
                    ),
                    itemBuilder: (context, index) {
                      final item = testimonials[index];
                      return _testimonialCard(item);
                    },
                  );
                },
              ),
              const SizedBox(height: 80),

              // Leave a Review Panel (Part B)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
                child: Form(
                  key: _reviewFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share Your Experience',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A192F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Help future candidates by sharing your placement journey with AVM Global.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),

                      // Name & Designation/Country
                      if (isMobile) ...[
                        _buildInputField(
                          label: 'Your Name',
                          controller: _reviewNameController,
                          validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: 'Job Designation / Country Placed (e.g. IT, Germany)',
                          controller: _reviewRoleController,
                          validator: (val) => val == null || val.isEmpty ? 'Designation/Country is required' : null,
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Your Name',
                                controller: _reviewNameController,
                                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildInputField(
                                label: 'Job / Country Placed (e.g. Nurse, Canada)',
                                controller: _reviewRoleController,
                                validator: (val) => val == null || val.isEmpty ? 'Designation/Country is required' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Star Selection Widget
                      Row(
                        children: [
                          const Text(
                            'Your Rating: ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0A192F),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: List.generate(5, (index) {
                              final int starVal = index + 1;
                              return IconButton(
                                icon: Icon(
                                  starVal <= _selectedRating ? Icons.star : Icons.star_border,
                                  color: const Color(0xFFD4AF37), // Gold star
                                  size: 28,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedRating = starVal.toDouble();
                                  });
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Review Text
                      _buildInputField(
                        label: 'Write your testimonial details...',
                        controller: _reviewTextController,
                        maxLines: 4,
                        validator: (val) => val == null || val.isEmpty ? 'Testimonial text is required' : null,
                      ),
                      const SizedBox(height: 32),

                      // Submit Review Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmittingReview ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A192F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBackgroundColor: const Color(0xFF0A192F).withOpacity(0.5),
                          ),
                          child: _isSubmittingReview
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Post Testimonial',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _testimonialCard(Testimonial review) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.12),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote Icon
          Icon(
            Icons.format_quote_rounded,
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            size: 32,
          ),
          const SizedBox(height: 8),

          // Review Body Text
          Expanded(
            child: Text(
              review.reviewText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),

          // Rating Stars
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: const Color(0xFFD4AF37),
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 12),

          // Reviewer Info
          Text(
            review.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A192F),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            review.roleAndCountry,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Color(0xFF0A192F), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF1F5F9), // Light slate gray background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
