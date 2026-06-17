import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
  String _activeTab = 'job_seeker'; // 'job_seeker' or 'business'
  String _submissionCategory = 'job_seeker'; // 'job_seeker' or 'business'

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _pickedImageBytes = result.files.single.bytes;
          _pickedImageName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

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
      category: _submissionCategory,
    );

    try {
      await FirebaseService.instance.submitTestimonial(
        newReview,
        imageBytes: _pickedImageBytes,
        imageName: _pickedImageName,
      );
      
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
      _submissionCategory = 'job_seeker';
      _pickedImageBytes = null;
      _pickedImageName = null;
    });
  }

  @override
  void dispose() {
    _reviewNameController.dispose();
    _reviewRoleController.dispose();
    _reviewTextController.dispose();
    super.dispose();
  }

  Widget _buildCategoryTabs() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton(
            title: 'Job Seekers',
            icon: Icons.person_search_rounded,
            isSelected: _activeTab == 'job_seeker',
            onTap: () => setState(() => _activeTab = 'job_seeker'),
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            title: 'Businesses / Employers',
            icon: Icons.business_center_rounded,
            isSelected: _activeTab == 'business',
            onTap: () => setState(() => _activeTab = 'business'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0A192F) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0A192F).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF0A192F).withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0A192F).withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCategoryOption({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _submissionCategory = value;
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? const Color(0xFF0A192F) : Colors.transparent,
            side: BorderSide(
              color: isSelected ? const Color(0xFF0A192F) : Colors.grey.withValues(alpha: 0.3),
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF0A192F),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
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
                _activeTab == 'job_seeker'
                    ? 'What Successfully Placed Candidates Say'
                    : 'What Our Global Hiring Partners Say',
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
              const SizedBox(height: 35),
              _buildCategoryTabs(),
              const SizedBox(height: 40),

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
                  final filteredTestimonials = testimonials
                      .where((t) => t.category == _activeTab)
                      .toList();

                  if (filteredTestimonials.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        children: [
                          Icon(
                            _activeTab == 'job_seeker'
                                ? Icons.people_outline_rounded
                                : Icons.business_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _activeTab == 'job_seeker'
                                ? 'No candidate testimonials yet. Be the first to leave one below!'
                                : 'No business partner testimonials yet. Be the first to leave one below!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  if (isMobile) {
                    return Column(
                      children: filteredTestimonials
                          .take(3)
                          .map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: _testimonialCard(item, isConstrained: false),
                              ))
                          .toList(),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTestimonials.length > 3 ? 3 : filteredTestimonials.length, // Limit to top 3
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 2 : 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      mainAxisExtent: 280, // Fixed height to prevent overflow (increased from 260 for avatar row)
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredTestimonials[index];
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
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
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
                        _submissionCategory == 'job_seeker'
                            ? 'Help future candidates by sharing your placement journey with AVM Global.'
                            : 'Help other businesses learn how AVM Global facilitates outstanding recruitment pipelines.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),

                      // Category selection in form
                      const Text(
                        'I am writing this as a:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A192F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildFormCategoryOption(
                            label: 'Job Seeker',
                            value: 'job_seeker',
                            isSelected: _submissionCategory == 'job_seeker',
                          ),
                          const SizedBox(width: 16),
                          _buildFormCategoryOption(
                            label: 'Business / Employer',
                            value: 'business',
                            isSelected: _submissionCategory == 'business',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Name & Designation/Country
                      if (isMobile) ...[
                        _buildInputField(
                          label: _submissionCategory == 'job_seeker'
                              ? 'Your Name'
                              : 'Your Name / Contact Person',
                          controller: _reviewNameController,
                          validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: _submissionCategory == 'job_seeker'
                              ? 'Job Designation / Country Placed (e.g. IT, Germany)'
                              : 'Your Title & Company (e.g. HR Director, TechCorp)',
                          controller: _reviewRoleController,
                          validator: (val) => val == null || val.isEmpty
                              ? (_submissionCategory == 'job_seeker' ? 'Designation/Country is required' : 'Title/Company is required')
                              : null,
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: _submissionCategory == 'job_seeker'
                                    ? 'Your Name'
                                    : 'Your Name / Contact Person',
                                controller: _reviewNameController,
                                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildInputField(
                                label: _submissionCategory == 'job_seeker'
                                    ? 'Job / Country Placed (e.g. Nurse, Canada)'
                                    : 'Your Title & Company (e.g. HR Manager, TechCorp)',
                                controller: _reviewRoleController,
                                validator: (val) => val == null || val.isEmpty
                                    ? (_submissionCategory == 'job_seeker' ? 'Designation/Country is required' : 'Title/Company is required')
                                    : null,
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

                      // Photo Upload Row / Wrap
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          const Text(
                            'Your Photo: ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0A192F),
                            ),
                          ),
                          if (_pickedImageBytes != null) ...[
                            // Thumbnail Preview
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: MemoryImage(_pickedImageBytes!),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            Text(
                              _pickedImageName ?? 'photo.jpg',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 24),
                              tooltip: 'Remove Photo',
                              onPressed: () {
                                setState(() {
                                  _pickedImageBytes = null;
                                  _pickedImageName = null;
                                });
                              },
                            ),
                          ] else ...[
                            // Pick button
                            OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                              label: const Text('Choose Photo'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0A192F),
                                side: BorderSide(
                                  color: const Color(0xFF0A192F).withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            Text(
                              '(Optional, JPG/PNG format)',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

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
                            disabledBackgroundColor: const Color(0xFF0A192F).withValues(alpha: 0.5),
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

  Widget _buildAvatar(Testimonial review) {
    if (review.imageUrl != null && review.imageUrl!.isNotEmpty) {
      if (review.imageUrl!.startsWith('data:image')) {
        try {
          final base64Str = review.imageUrl!.split(',').last;
          final bytes = base64Decode(base64Str);
          return Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.memory(
                bytes,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(review.name),
              ),
            ),
          );
        } catch (_) {
          // Fallback if parsing fails
        }
      } else {
        return Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              review.imageUrl!,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // If it fails to load (e.g. CORS block), fall back to default initials
                return _buildDefaultAvatar(review.name);
              },
            ),
          ),
        );
      }
    }
    return _buildDefaultAvatar(review.name);
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xFF0A192F),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _testimonialCard(Testimonial review, {bool isConstrained = true}) {
    final textWidget = Text(
      review.reviewText,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
        height: 1.5,
      ),
      maxLines: isConstrained ? 4 : null,
      overflow: isConstrained ? TextOverflow.ellipsis : null,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.12),
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
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            size: 32,
          ),
          const SizedBox(height: 8),

          // Review Body Text
          isConstrained ? Expanded(child: textWidget) : textWidget,
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

          // Reviewer Info Row with Avatar
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(review),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
              ),
            ],
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
