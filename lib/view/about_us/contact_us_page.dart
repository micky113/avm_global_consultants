import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:js' as js;
import 'about_us_base_page.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
    });

    final name = _nameController.text;
    final email = _emailController.text;
    final subject = _subjectController.text;
    final message = _messageController.text;

    // Prefill mail details
    final mailtoUrl = Uri(
      scheme: 'mailto',
      path: 'vishal@avmglobalconsultants.com',
      queryParameters: {
        'subject': 'AVM Global Inquiry: $subject',
        'body': 'Name: $name\nEmail: $email\n\nMessage:\n$message',
      },
    ).toString();

    // Trigger email client redirect on web
    if (kIsWeb) {
      try {
        js.context.callMethod('open', [mailtoUrl]);
      } catch (e) {
        debugPrint('Error launching mail client: $e');
      }
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isSending = false;
          _showSuccess = true;
        });

        // Reset form
        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;
    const themeColor = Color(0xFF146EB8);
    const darkBlue = Color(0xFF0A192F);

    return AboutUsBasePage(
      title: 'Contact Us',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side info column
              if (!isMobile)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Get in Touch with AVM Global',
                          style: GoogleFonts.notoSans(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Have questions about working abroad, student visas, or licensing compliance? Fill out the contact form or reach out directly to our managing director.',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 36),
                        _buildContactInfoItem(
                          icon: Icons.email_rounded,
                          title: 'Primary Contact Email',
                          value: 'vishal@avmglobalconsultants.com',
                        ),
                        const SizedBox(height: 20),
                        _buildContactInfoItem(
                          icon: Icons.support_agent_rounded,
                          title: 'Response Time',
                          value: 'Within 24-48 business hours',
                        ),
                        const SizedBox(height: 20),
                        _buildContactInfoItem(
                          icon: Icons.access_time_filled_rounded,
                          title: 'Office Hours',
                          value: 'Mon - Sat: 9:30 AM - 6:30 PM (IST)',
                        ),
                      ],
                    ),
                  ),
                ),

              // Right side form column
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.black12.withOpacity(0.05)),
                  ),
                  child: _showSuccess
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Thank you!',
                              style: GoogleFonts.notoSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your message request has been sent to vishal@avmglobalconsultants.com. If your mail client did not open, please click the email address directly on the left.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showSuccess = false;
                                });
                              },
                              child: Text(
                                'Send another message',
                                style: GoogleFonts.notoSans(
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Send Message',
                                style: GoogleFonts.notoSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: darkBlue,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _subjectController,
                                decoration: const InputDecoration(
                                  labelText: 'Subject',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.title_rounded),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a subject';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _messageController,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  labelText: 'Message',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(bottom: 80.0),
                                    child: Icon(Icons.chat_bubble_outline),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your message';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isSending ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isSending
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Send Message via Email',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'AVM Global Contact Details',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactInfoItem(
              icon: Icons.email_rounded,
              title: 'Primary Contact Email',
              value: 'vishal@avmglobalconsultants.com',
            ),
            const SizedBox(height: 16),
            _buildContactInfoItem(
              icon: Icons.support_agent_rounded,
              title: 'Response Time',
              value: 'Within 24-48 business hours',
            ),
            const SizedBox(height: 16),
            _buildContactInfoItem(
              icon: Icons.access_time_filled_rounded,
              title: 'Office Hours',
              value: 'Mon - Sat: 9:30 AM - 6:30 PM (IST)',
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildContactInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    const themeColor = Color(0xFF146EB8);
    const darkBlue = Color(0xFF0A192F);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: themeColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
