import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avm_global_web/services/firebase_service.dart';
import 'package:avm_global_web/models/testimonial.dart';
import 'package:avm_global_web/models/job.dart';
import 'package:avm_global_web/models/job_application.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;

class AdminDashboardDialog extends StatefulWidget {
  final Color themeColor;

  const AdminDashboardDialog({super.key, required this.themeColor});

  @override
  State<AdminDashboardDialog> createState() => _AdminDashboardDialogState();
}

class _AdminDashboardDialogState extends State<AdminDashboardDialog> {
  bool _isAuthenticated = false;
  bool _isLoggingIn = false;
  String? _loginError;
  String _activeTab = 'inquiries'; // 'inquiries' or 'testimonials'

  @override
  void initState() {
    super.initState();
    // Pre-authenticate if the user is already signed in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final email = currentUser.email;
      final authorizedEmails = [
        'mohanty747@gmail.com',
        'vishalmohapatra1928@gmail.com',
      ];
      if (email != null && authorizedEmails.contains(email.toLowerCase())) {
        _isAuthenticated = true;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    try {
      if (!kIsWeb) {
        throw UnsupportedError('Google Sign-In is only supported on Web. Please run this app in a Web Browser (e.g. Chrome).');
      }

      final googleProvider = GoogleAuthProvider();
      final userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      final email = userCredential.user?.email;

      final authorizedEmails = [
        'mohanty747@gmail.com',
        'vishalmohapatra1928@gmail.com',
      ];

      if (email != null && authorizedEmails.contains(email.toLowerCase())) {
        setState(() {
          _isAuthenticated = true;
          _isLoggingIn = false;
        });
      } else {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _isLoggingIn = false;
          _loginError = 'Access Denied: ${email ?? "Unknown email"} is not an authorized administrator.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoggingIn = false;
        _loginError = 'Sign in failed: ${e.toString()}';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 800;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isLargeScreen ? screenSize.width * 0.85 : screenSize.width * 0.95,
          height: screenSize.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: _isAuthenticated
              ? _buildDashboardView(isLargeScreen)
              : _buildLoginView(),
        ),
      ),
    );
  }

  // Google Sign-In Admin Authentication UI
  Widget _buildLoginView() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    color: widget.themeColor,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Admin Authentication',
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in with Google to access AVM Global administrative dashboard.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                if (_loginError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Text(
                      _loginError!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (_isLoggingIn) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Authenticating via Google...',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: _signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      elevation: 1,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/512px-Google_%22G%22_Logo.svg.png',
                          height: 20,
                          width: 20,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.login_rounded, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sign in with Google',
                          style: GoogleFonts.notoSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Cancel',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dashboard Main View
  Widget _buildDashboardView(bool isLargeScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      children: [
        // App Bar Header
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 12 : 18,
          ),
          decoration: BoxDecoration(
            color: widget.themeColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.dashboard_customize_rounded,
                      color: Colors.white,
                      size: isMobile ? 24 : 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isMobile ? 'Management Console' : 'AVM Global - Management Console',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSans(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Sign Out',
                    icon: Icon(Icons.logout_rounded, color: Colors.white, size: isMobile ? 20 : 24),
                    onPressed: _signOut,
                  ),
                  IconButton(
                    tooltip: 'Close Management Console',
                    icon: Icon(Icons.close_rounded, color: Colors.white, size: isMobile ? 20 : 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Body Content
        Expanded(
          child: Row(
            children: [
              if (!isMobile)
                // Sidebar Navigation
                Container(
                  width: isLargeScreen ? 240 : 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      right: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      _buildSidebarItem(
                        id: 'inquiries',
                        title: 'Candidate Inquiries',
                        icon: Icons.contact_page_rounded,
                        isLargeScreen: isLargeScreen,
                      ),
                      _buildSidebarItem(
                        id: 'jobs',
                        title: 'Manage Jobs',
                        icon: Icons.work_rounded,
                        isLargeScreen: isLargeScreen,
                      ),
                      _buildSidebarItem(
                        id: 'job_applications',
                        title: 'Job Applications',
                        icon: Icons.assignment_turned_in_rounded,
                        isLargeScreen: isLargeScreen,
                      ),
                      _buildSidebarItem(
                        id: 'registered_users',
                        title: 'Registered Users',
                        icon: Icons.people_rounded,
                        isLargeScreen: isLargeScreen,
                      ),
                      _buildSidebarItem(
                        id: 'testimonials',
                        title: 'Manage Testimonials',
                        icon: Icons.reviews_rounded,
                        isLargeScreen: isLargeScreen,
                      ),
                      _buildSidebarItem(
                        id: 'searches',
                        title: 'User Searches',
                        icon: Icons.search_rounded,
                        isLargeScreen: isLargeScreen,
                      ),
                    ],
                  ),
                ),
              
              // Panel Display Area
              Expanded(
                child: Container(
                  child: _activeTab == 'inquiries'
                      ? _buildInquiriesPanel()
                      : _activeTab == 'jobs'
                          ? _buildJobsPanel()
                          : _activeTab == 'job_applications'
                              ? _buildJobApplicationsPanel()
                              : _activeTab == 'registered_users'
                                  ? _buildRegisteredUsersPanel()
                                  : _activeTab == 'testimonials'
                                      ? _buildTestimonialsPanel()
                                      : _buildRecentSearchesPanel(),
                ),
              ),
            ],
          ),
        ),
        if (isMobile)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _activeTab == 'inquiries'
                  ? 0
                  : _activeTab == 'jobs'
                      ? 1
                      : _activeTab == 'job_applications'
                          ? 2
                          : _activeTab == 'registered_users'
                              ? 3
                              : _activeTab == 'testimonials'
                                  ? 4
                                  : 5,
              onTap: (index) {
                setState(() {
                  _activeTab = index == 0
                      ? 'inquiries'
                      : index == 1
                          ? 'jobs'
                          : index == 2
                              ? 'job_applications'
                              : index == 3
                                  ? 'registered_users'
                                  : index == 4
                                      ? 'testimonials'
                                      : 'searches';
                });
              },
              selectedItemColor: widget.themeColor,
              unselectedItemColor: Colors.black38,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 10),
              unselectedLabelStyle: GoogleFonts.notoSans(fontWeight: FontWeight.w500, fontSize: 10),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.contact_page_rounded),
                  label: 'Inquiries',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.work_rounded),
                  label: 'Jobs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_turned_in_rounded),
                  label: 'Apps',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_rounded),
                  label: 'Users',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.reviews_rounded),
                  label: 'Reviews',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  label: 'Searches',
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSidebarItem({
    required String id,
    required String title,
    required IconData icon,
    required bool isLargeScreen,
  }) {
    final isSelected = _activeTab == id;
    final itemColor = isSelected ? widget.themeColor : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _activeTab = id),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? widget.themeColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: isLargeScreen ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, color: itemColor, size: 22),
              if (isLargeScreen) ...[
                const SizedBox(width: 14),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: itemColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Tab 1: Inquiries Management
  Widget _buildInquiriesPanel() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService.instance.getInquiriesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading inquiries: ${snapshot.error}'));
        }
        final inquiries = snapshot.data ?? [];
        if (inquiries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No inquiries available',
                  style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final isMobilePanel = MediaQuery.of(context).size.width < 600;

        return ListView.builder(
          padding: EdgeInsets.all(isMobilePanel ? 12 : 24),
          itemCount: inquiries.length,
          itemBuilder: (context, index) {
            final item = inquiries[index];
            final name = item['name'] ?? 'Anonymous';
            final jobField = item['jobField'] ?? 'Not Specified';
            final resumeUrl = item['resumeUrl'] ?? '';
            final resumeFileName = item['resumeFileName'] ?? '';
            final docId = item['id'] ?? '';
            
            // Format Timestamp
            String formattedDate = '';
            if (item['submittedAt'] != null) {
              try {
                final date = item['submittedAt'] is DateTime
                    ? item['submittedAt']
                    : (item['submittedAt'] as dynamic).toDate();
                formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              } catch (_) {}
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobilePanel ? 14 : 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobileCard = MediaQuery.of(context).size.width < 600;
                    if (isMobileCard) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: widget.themeColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person_pin_rounded, color: widget.themeColor, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (formattedDate.isNotEmpty)
                                      Text(
                                        formattedDate,
                                        style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black38),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Line of Job Search: $jobField',
                            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black54),
                          ),
                          if (resumeFileName.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.attach_file_rounded, size: 16, color: Colors.black45),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      if (resumeUrl.isNotEmpty) {
                                        _openResume(resumeUrl);
                                      }
                                    },
                                    child: Text(
                                      resumeFileName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: widget.themeColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              if (resumeUrl.isNotEmpty)
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                                  label: const Text('View Resume'),
                                  style: TextButton.styleFrom(foregroundColor: widget.themeColor),
                                  onPressed: () {
                                    _openResume(resumeUrl);
                                  },
                                ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                label: const Text('Delete'),
                                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                onPressed: () => _confirmDeleteInquiry(docId),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.themeColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.person_pin_rounded, color: widget.themeColor, size: 32),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.notoSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (formattedDate.isNotEmpty) ...[
                                    const SizedBox(width: 12),
                                    Text(
                                      '•  $formattedDate',
                                      style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black38),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Line of Job Search: $jobField',
                                style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black54),
                              ),
                              if (resumeFileName.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.attach_file_rounded, size: 16, color: Colors.black45),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () {
                                        if (resumeUrl.isNotEmpty) {
                                          _openResume(resumeUrl);
                                        }
                                      },
                                      child: Text(
                                        resumeFileName,
                                        style: GoogleFonts.notoSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: widget.themeColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            if (resumeUrl.isNotEmpty) ...[
                              IconButton(
                                icon: const Icon(Icons.open_in_new_rounded),
                                color: widget.themeColor,
                                tooltip: 'View Resume',
                                onPressed: () {
                                  _openResume(resumeUrl);
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: Colors.redAccent,
                              tooltip: 'Delete Inquiry',
                              onPressed: () => _confirmDeleteInquiry(docId),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteInquiry(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Inquiry?'),
        content: const Text('Are you sure you want to permanently delete this candidate inquiry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseService.instance.deleteInquiry(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inquiry deleted successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Tab 2: Testimonials Management
  Widget _buildTestimonialsPanel() {
    return StreamBuilder<List<Testimonial>>(
      stream: FirebaseService.instance.getTestimonialsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading testimonials: ${snapshot.error}'));
        }
        final testimonials = snapshot.data ?? [];
        if (testimonials.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No testimonials found',
                  style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final isMobilePanel = MediaQuery.of(context).size.width < 600;

        return ListView.builder(
          padding: EdgeInsets.all(isMobilePanel ? 12 : 24),
          itemCount: testimonials.length,
          itemBuilder: (context, index) {
            final item = testimonials[index];
            final displayCategory = item.category == 'business' ? 'Business Review' : 'Job Seeker Review';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobilePanel ? 14 : 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobileCard = MediaQuery.of(context).size.width < 600;
                    if (isMobileCard) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: widget.themeColor.withOpacity(0.1),
                                backgroundImage: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                    ? NetworkImage(item.imageUrl!)
                                    : null,
                                child: item.imageUrl == null || item.imageUrl!.isEmpty
                                    ? Text(
                                        item.name.substring(0, 1).toUpperCase(),
                                        style: GoogleFonts.notoSans(
                                          fontWeight: FontWeight.bold,
                                          color: widget.themeColor,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      item.roleAndCountry,
                                      style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black45),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.category == 'business'
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  displayCategory,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: item.category == 'business'
                                        ? Colors.orange[800]
                                        : Colors.blue[800],
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(5, (starIdx) {
                                  return Icon(
                                    starIdx < item.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.reviewText,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Edit'),
                                style: TextButton.styleFrom(foregroundColor: widget.themeColor),
                                onPressed: () => _editTestimonialDialog(item),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                label: const Text('Delete'),
                                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                onPressed: () => _confirmDeleteTestimonial(item.id),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: widget.themeColor.withOpacity(0.1),
                          backgroundImage: item.imageUrl != null && item.imageUrl!.isNotEmpty
                              ? NetworkImage(item.imageUrl!)
                              : null,
                          child: item.imageUrl == null || item.imageUrl!.isEmpty
                              ? Text(
                                  item.name.substring(0, 1).toUpperCase(),
                                  style: GoogleFonts.notoSans(
                                    fontWeight: FontWeight.bold,
                                    color: widget.themeColor,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.name,
                                    style: GoogleFonts.notoSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: item.category == 'business'
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      displayCategory,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: item.category == 'business'
                                            ? Colors.orange[800]
                                            : Colors.blue[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.roleAndCountry,
                                style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black45),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: List.generate(5, (starIdx) {
                                  return Icon(
                                    starIdx < item.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.reviewText,
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              color: widget.themeColor,
                              tooltip: 'Edit Testimonial',
                              onPressed: () => _editTestimonialDialog(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: Colors.redAccent,
                              tooltip: 'Delete Testimonial',
                              onPressed: () => _confirmDeleteTestimonial(item.id),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTestimonial(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Testimonial?'),
        content: const Text('Are you sure you want to permanently delete this testimonial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseService.instance.deleteTestimonial(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Testimonial deleted successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  // Edit Testimonial Sub-Dialog Form
  void _editTestimonialDialog(Testimonial testimonial) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: testimonial.name);
    final roleCtrl = TextEditingController(text: testimonial.roleAndCountry);
    final textCtrl = TextEditingController(text: testimonial.reviewText);
    double ratingVal = testimonial.rating;
    String categoryVal = testimonial.category;

    Uint8List? editImageBytes;
    String? editImageName;
    String? currentImageUrl = testimonial.imageUrl;
    bool removeCurrentImage = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickNewImage() async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                );
                if (result != null && result.files.single.bytes != null) {
                  setDialogState(() {
                    editImageBytes = result.files.single.bytes;
                    editImageName = result.files.single.name;
                    removeCurrentImage = false;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error picking image: $e')),
                );
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Edit Testimonial',
                style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width < 520
                    ? MediaQuery.of(context).size.width * 0.85
                    : 480,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reviewer Category
                        Text(
                          'Category',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: categoryVal,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'job_seeker', child: Text('Job Seeker')),
                            DropdownMenuItem(value: 'business', child: Text('Business')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => categoryVal = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Photo Selection Preview
                        Text(
                          'Reviewer Photo',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: widget.themeColor.withOpacity(0.1),
                              backgroundImage: editImageBytes != null
                                  ? MemoryImage(editImageBytes!)
                                  : (currentImageUrl != null && currentImageUrl.isNotEmpty && !removeCurrentImage
                                      ? NetworkImage(currentImageUrl) as ImageProvider
                                      : null),
                              child: (editImageBytes == null && (currentImageUrl == null || currentImageUrl.isEmpty || removeCurrentImage))
                                  ? Text(
                                      (nameCtrl.text.isNotEmpty ? nameCtrl.text.substring(0, 1) : 'T').toUpperCase(),
                                      style: GoogleFonts.notoSans(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: widget.themeColor,
                                      ),
                                    )
                                  : null,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: pickNewImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[100],
                                    foregroundColor: Colors.black87,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.grey[300]!),
                                    ),
                                  ),
                                  icon: const Icon(Icons.photo_library_rounded, size: 16),
                                  label: Text(
                                    editImageBytes != null || (currentImageUrl != null && currentImageUrl.isNotEmpty && !removeCurrentImage)
                                        ? 'Change Photo'
                                        : 'Upload Photo',
                                    style: GoogleFonts.notoSans(fontSize: 12),
                                  ),
                                ),
                                if (editImageBytes != null || (currentImageUrl != null && currentImageUrl.isNotEmpty && !removeCurrentImage)) ...[
                                  const SizedBox(height: 6),
                                  TextButton.icon(
                                    onPressed: () {
                                      setDialogState(() {
                                        editImageBytes = null;
                                        editImageName = null;
                                        removeCurrentImage = true;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                    ),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 14),
                                    label: Text(
                                      'Remove Photo',
                                      style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Name field
                        Text(
                          'Reviewer Name',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            hintText: 'Reviewer name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Name required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Role/Country
                        Text(
                          categoryVal == 'business' ? 'Company Role & Country' : 'Job Role & Country',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: roleCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Software Engineer, Germany',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Role & Country required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Star Rating
                        Text(
                          'Rating',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Row(
                          children: List.generate(5, (starIdx) {
                            return IconButton(
                              icon: Icon(
                                starIdx < ratingVal ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: Colors.amber,
                                size: 28,
                              ),
                              onPressed: () {
                                setDialogState(() => ratingVal = starIdx + 1.0);
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 16),

                        // Review Text
                        Text(
                          'Review Description',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: textCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Type testimonial text here...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Review text required' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final updatedTestimonial = Testimonial(
                      id: testimonial.id,
                      name: nameCtrl.text.trim(),
                      roleAndCountry: roleCtrl.text.trim(),
                      reviewText: textCtrl.text.trim(),
                      rating: ratingVal,
                      timestamp: testimonial.timestamp,
                      category: categoryVal,
                      imageUrl: removeCurrentImage ? '' : testimonial.imageUrl,
                    );
                    
                    try {
                      await FirebaseService.instance.updateTestimonial(
                        updatedTestimonial,
                        imageBytes: editImageBytes,
                        imageName: editImageName,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Testimonial updated successfully!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    elevation: 0,
                  ),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Panel for managing Jobs
  Widget _buildJobsPanel() {
    final isMobilePanel = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // Panel Header
        Padding(
          padding: EdgeInsets.all(isMobilePanel ? 12 : 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job Openings',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _addEditJobDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                label: Text(
                  'Add New Job',
                  style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // List of jobs
        Expanded(
          child: StreamBuilder<List<Job>>(
            stream: FirebaseService.instance.getJobsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading jobs: ${snapshot.error}'));
              }
              final jobs = snapshot.data ?? [];
              if (jobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off_rounded, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No job openings posted yet',
                        style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: isMobilePanel ? 12 : 24),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobilePanel ? 14 : 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: widget.themeColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.work_outline_rounded, color: widget.themeColor, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      '${job.company}  •  ${job.location}',
                                      style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black54),
                                    ),
                                    _buildJobStatusBadge(job.status),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        job.type,
                                        style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                                if (job.phone.isNotEmpty || job.email.isNotEmpty || job.link.isNotEmpty || job.name.isNotEmpty || job.clientCompany.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 6,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      if (job.clientCompany.isNotEmpty)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.business_outlined, size: 14, color: widget.themeColor.withOpacity(0.7)),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Client: ${job.clientCompany}',
                                              style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      if (job.name.isNotEmpty)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.person_outline_rounded, size: 14, color: widget.themeColor.withOpacity(0.7)),
                                            const SizedBox(width: 4),
                                            Text(
                                              job.name,
                                              style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      if (job.phone.isNotEmpty)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.phone_outlined, size: 14, color: widget.themeColor.withOpacity(0.7)),
                                            const SizedBox(width: 4),
                                            Text(
                                              job.phone,
                                              style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      if (job.email.isNotEmpty)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.email_outlined, size: 14, color: widget.themeColor.withOpacity(0.7)),
                                            const SizedBox(width: 4),
                                            Text(
                                              job.email,
                                              style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      if (job.link.isNotEmpty)
                                        InkWell(
                                          onTap: () {
                                            if (kIsWeb) {
                                              js.context.callMethod('open', [job.link]);
                                            }
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.link_rounded, size: 14, color: widget.themeColor),
                                              const SizedBox(width: 4),
                                              Text(
                                                'View Link',
                                                style: GoogleFonts.notoSans(
                                                  fontSize: 12,
                                                  color: widget.themeColor,
                                                  fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share_outlined),
                                color: const Color(0xFF1877F2),
                                tooltip: 'Share Job on Facebook Group',
                                onPressed: () => _showFacebookShareDialog(job),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                color: widget.themeColor,
                                tooltip: 'Edit Job',
                                onPressed: () => _addEditJobDialog(job),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                color: Colors.redAccent,
                                tooltip: 'Delete Job',
                                onPressed: () => _confirmDeleteJob(job.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFacebookShareDialog(Job job) {
    // Load list of target Facebook groups
    List<Map<String, String>> targetGroups = [];
    try {
      if (kIsWeb) {
        final stored = html.window.localStorage['fb_target_groups_list'];
        if (stored != null && stored.trim().isNotEmpty) {
          final List decoded = jsonDecode(stored);
          targetGroups = decoded.map((e) => {
            'name': (e['name'] ?? 'Facebook Group').toString(),
            'url': (e['url'] ?? 'https://www.facebook.com/groups/').toString(),
          }).toList();
        } else {
          final singleUrl = html.window.localStorage['fb_target_group_url'];
          if (singleUrl != null && singleUrl.trim().isNotEmpty) {
            targetGroups = [{'name': 'My Facebook Group', 'url': singleUrl.trim()}];
          }
        }
      }
    } catch (_) {}

    if (targetGroups.isEmpty) {
      targetGroups = [
        {'name': 'Official Facebook Group', 'url': 'https://www.facebook.com/groups/'}
      ];
    }

    final newGroupNameCtrl = TextEditingController();
    final newGroupUrlCtrl = TextEditingController();
    bool isAddingGroup = false;

    final jobUrl = (job.link.isNotEmpty &&
            (job.link.startsWith('http://') || job.link.startsWith('https://')))
        ? job.link
        : (kIsWeb && html.window.location.origin.isNotEmpty
            ? '${html.window.location.origin}/jobs?id=${job.id}'
            : 'https://avmglobal-consultants-113.web.app/jobs?id=${job.id}');

    final postText = '''🚀 WE ARE HIRING! 🚀

📌 Role: ${job.title}
📍 Location: ${job.location}
💼 Job Type: ${job.type}

📝 Description:
${job.description.trim().isNotEmpty ? (job.description.length > 250 ? '${job.description.substring(0, 250)}...' : job.description) : 'Exciting career opportunity with our team.'}

👉 View details & Apply here:
$jobUrl

#Hiring #JobOpening #Careers #Jobs #${job.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')} #AVMGlobal''';

    void saveTargetGroups(List<Map<String, String>> list) {
      try {
        if (kIsWeb) {
          html.window.localStorage['fb_target_groups_list'] = jsonEncode(list);
          if (list.isNotEmpty) {
            html.window.localStorage['fb_target_group_url'] = list.first['url'] ?? '';
          }
        }
      } catch (_) {}
    }

    void copyAndOpen(BuildContext ctx, String groupName, String groupUrl) {
      Clipboard.setData(ClipboardData(text: postText));
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Post copied! Opening "$groupName"... Paste into the group post box.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      if (kIsWeb) {
        final urlToOpen = groupUrl.trim().isNotEmpty ? groupUrl.trim() : 'https://www.facebook.com/groups/';
        html.window.open(urlToOpen, '_blank');
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth < 600;

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: isMobile ? 16 : 24,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                isMobile ? 16 : 24,
                isMobile ? 16 : 24,
                isMobile ? 10 : 12,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 24,
                vertical: isMobile ? 8 : 12,
              ),
              actionsPadding: EdgeInsets.fromLTRB(
                isMobile ? 14 : 24,
                0,
                isMobile ? 14 : 24,
                isMobile ? 14 : 20,
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1877F2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.facebook,
                      color: const Color(0xFF1877F2),
                      size: isMobile ? 22 : 26,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMobile ? 'Share to FB Groups' : 'Share Job to Facebook Groups',
                          style: GoogleFonts.notoSans(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSans(
                            fontSize: isMobile ? 12 : 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: isMobile ? screenWidth : 580,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target Facebook Groups Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Target Facebook Groups (${targetGroups.length})',
                              style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 13 : 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1877F2),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(isAddingGroup ? Icons.close : Icons.add_circle_outline, size: 15),
                            label: Text(
                              isAddingGroup ? 'Cancel' : '+ Add Group',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                isAddingGroup = !isAddingGroup;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Add Group Inline Form
                      if (isAddingGroup)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(isMobile ? 10 : 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1877F2).withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF1877F2).withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Target Facebook Group',
                                style: GoogleFonts.notoSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: const Color(0xFF1877F2),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: newGroupNameCtrl,
                                style: GoogleFonts.notoSans(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Group Name (e.g. Germany IT Careers)',
                                  hintStyle: GoogleFonts.notoSans(fontSize: 12, color: Colors.black38),
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: newGroupUrlCtrl,
                                style: GoogleFonts.notoSans(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Group URL (e.g. https://www.facebook.com/groups/...)',
                                  hintStyle: GoogleFonts.notoSans(fontSize: 12, color: Colors.black38),
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setDialogState(() => isAddingGroup = false);
                                    },
                                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1877F2),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    onPressed: () {
                                      final name = newGroupNameCtrl.text.trim();
                                      final url = newGroupUrlCtrl.text.trim();
                                      if (url.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter a Facebook group URL')),
                                        );
                                        return;
                                      }
                                      setDialogState(() {
                                        targetGroups.add({
                                          'name': name.isNotEmpty ? name : 'Facebook Group ${targetGroups.length + 1}',
                                          'url': url.startsWith('http://') || url.startsWith('https://') ? url : 'https://$url',
                                        });
                                        saveTargetGroups(targetGroups);
                                        newGroupNameCtrl.clear();
                                        newGroupUrlCtrl.clear();
                                        isAddingGroup = false;
                                      });
                                    },
                                    child: const Text('Save Group', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // List of Target Facebook Groups
                      if (targetGroups.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'No groups added yet. Click "+ Add Group" above.',
                            style: GoogleFonts.notoSans(color: Colors.black54, fontSize: 13),
                          ),
                        )
                      else
                        Container(
                          constraints: BoxConstraints(maxHeight: isMobile ? 220 : 180),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: targetGroups.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final group = targetGroups[index];
                              final groupName = group['name'] ?? 'Facebook Group';
                              final groupUrl = group['url'] ?? 'https://www.facebook.com/groups/';

                              if (isMobile) {
                                // Clean stacked card for mobile screens
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.groups_rounded, size: 20, color: Color(0xFF1877F2)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              groupName,
                                              style: GoogleFonts.notoSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18),
                                            color: Colors.redAccent,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            tooltip: 'Remove Group',
                                            onPressed: () {
                                              setDialogState(() {
                                                targetGroups.removeAt(index);
                                                saveTargetGroups(targetGroups);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        groupUrl,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.notoSans(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF1877F2),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                          icon: const Icon(Icons.open_in_new, size: 14),
                                          label: const Text('Copy Post & Open Group', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          onPressed: () => copyAndOpen(context, groupName, groupUrl),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Desktop row layout
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.groups_rounded, size: 22, color: Color(0xFF1877F2)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            groupName,
                                            style: GoogleFonts.notoSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            groupUrl,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.notoSans(
                                              fontSize: 11,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1877F2),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        minimumSize: Size.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      icon: const Icon(Icons.open_in_new, size: 14),
                                      label: const Text('Copy & Open', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      onPressed: () => copyAndOpen(context, groupName, groupUrl),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18),
                                      color: Colors.redAccent,
                                      tooltip: 'Remove Group',
                                      onPressed: () {
                                        setDialogState(() {
                                          targetGroups.removeAt(index);
                                          saveTargetGroups(targetGroups);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 14),

                      // Formatted Post Content Preview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Formatted Post Content',
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 12 : 13,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            label: const Text('Copy Text', style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: postText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Job post content copied to clipboard!'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 10 : 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: SelectableText(
                          postText,
                          style: GoogleFonts.notoSans(
                            fontSize: isMobile ? 11 : 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (isMobile)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1877F2),
                            side: const BorderSide(color: Color(0xFF1877F2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: const Icon(Icons.share, size: 15),
                          label: const Text('FB Dialog', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            final shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(jobUrl)}&quote=${Uri.encodeComponent(postText)}';
                            if (kIsWeb) {
                              html.window.open(shareUrl, '_blank');
                            }
                          },
                        ),
                      ),
                    ],
                  )
                else ...[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1877F2),
                      side: const BorderSide(color: Color(0xFF1877F2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('FB Share Dialog'),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      final shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(jobUrl)}&quote=${Uri.encodeComponent(postText)}';
                      if (kIsWeb) {
                        html.window.open(shareUrl, '_blank');
                      }
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteJob(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job?'),
        content: const Text('Are you sure you want to permanently delete this job listing? Applicants will no longer be able to apply to it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseService.instance.deleteJob(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job listing deleted successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting job: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Panel for viewing Job Applications
  Widget _buildJobApplicationsPanel() {
    final isMobilePanel = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel Header
        Padding(
          padding: EdgeInsets.all(isMobilePanel ? 12 : 24),
          child: Text(
            'Job Applications',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // List of applications
        Expanded(
          child: StreamBuilder<List<JobApplication>>(
            stream: FirebaseService.instance.getJobApplicationsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading applications: ${snapshot.error}'));
              }
              final applications = snapshot.data ?? [];
              if (applications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No job applications received yet',
                        style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: isMobilePanel ? 12 : 24),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  String formattedDate = '';
                  try {
                    formattedDate = '${app.appliedAt.day}/${app.appliedAt.month}/${app.appliedAt.year}';
                  } catch (_) {}

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobilePanel ? 14 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: widget.themeColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person_outline_rounded, color: widget.themeColor, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.applicantName,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Applied For: ${app.jobTitle}',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: widget.themeColor,
                                      ),
                                    ),
                                    if (formattedDate.isNotEmpty)
                                      Text(
                                        'Applied On: $formattedDate',
                                        style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black38),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                color: Colors.redAccent,
                                tooltip: 'Delete Application',
                                onPressed: () => _confirmDeleteJobApplication(app.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 24,
                            runSpacing: 12,
                            children: [
                              _buildAppDetailField(Icons.email_outlined, 'Email', app.applicantEmail),
                              _buildAppDetailField(Icons.phone_outlined, 'Phone', app.applicantPhone),
                              if (app.resumeFileName.isNotEmpty)
                                _buildAppDetailField(Icons.attach_file_rounded, 'Resume', app.resumeFileName, isLink: true, resumeUrl: app.resumeUrl),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppDetailField(IconData icon, String label, String value, {bool isLink = false, String? resumeUrl}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.notoSans(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
            if (isLink && resumeUrl != null)
              InkWell(
                onTap: () {
                  _openResume(resumeUrl);
                },
                child: Text(
                  value,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: widget.themeColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            else
              Text(value, style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  void _confirmDeleteJobApplication(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application?'),
        content: const Text('Are you sure you want to permanently delete this candidate application record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseService.instance.deleteJobApplication(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job application deleted successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobStatusBadge(String status) {
    final isOpen = status.trim().isEmpty || status.trim().toLowerCase() == 'open';
    final color = isOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final label = isOpen ? 'Open' : 'Closed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isOpen
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog form to Add or Edit jobs
  void _addEditJobDialog([Job? job]) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: job?.title ?? '');
    final companyCtrl = TextEditingController(text: job?.company ?? '');
    final locationCtrl = TextEditingController(text: job?.location ?? '');
    final salaryCtrl = TextEditingController(text: job?.salaryRange ?? '');
    final descCtrl = TextEditingController(text: job?.description ?? '');
    final clientCompanyCtrl = TextEditingController(text: job?.clientCompany ?? '');
    final phoneCtrl = TextEditingController(text: job?.phone ?? '');
    final emailCtrl = TextEditingController(text: job?.email ?? '');
    final linkCtrl = TextEditingController(text: job?.link ?? '');
    final nameCtrl = TextEditingController(text: job?.name ?? '');
    String typeVal = job?.type ?? 'Full-time';
    String statusVal = job?.status ?? 'Open';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                job == null ? 'Add Job Opening' : 'Edit Job Opening',
                style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width < 600
                    ? MediaQuery.of(context).size.width * 0.9
                    : 550,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text('Job Title', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: titleCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Senior Software Engineer',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Job title required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Company
                        Text('Company', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: companyCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Innovatech',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Company required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Location
                        Text('Location', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: locationCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Munich, Germany',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Location required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Type, Status and Salary Range
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Job Type', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: typeVal,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                                      DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                                      DropdownMenuItem(value: 'Contract', child: Text('Contract')),
                                      DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                                      DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setDialogState(() => typeVal = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: statusVal,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'Open',
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                                            const SizedBox(width: 6),
                                            const Text('Open'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Closed',
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                                            const SizedBox(width: 6),
                                            const Text('Closed'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setDialogState(() => statusVal = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Salary Range
                        Text('Salary Range', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: salaryCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. €70,000 - €85,000 / yr',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Salary required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text('Job Description', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: descCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Type job description here...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Description required' : null,
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Admin-Only Fields',
                          style: GoogleFonts.notoSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: widget.themeColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Client Company
                        Text('Client Company', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: clientCompanyCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Acme Corp (Client)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Contact Name
                        Text('Contact Name', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. John Doe',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phone and Email Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Phone Number', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: phoneCtrl,
                                    decoration: InputDecoration(
                                      hintText: 'e.g. +1 555-0199',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email ID', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: emailCtrl,
                                    decoration: InputDecoration(
                                      hintText: 'e.g. admin@domain.com',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    validator: (val) {
                                      if (val != null && val.trim().isNotEmpty) {
                                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                        if (!emailRegex.hasMatch(val.trim())) {
                                          return 'Invalid email format';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Link field
                        Text('Link', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: linkCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. https://example.com/job-source',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              if (!val.trim().startsWith('http://') && !val.trim().startsWith('https://')) {
                                return 'URL must start with http:// or https://';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final newJob = Job(
                      id: job?.id ?? '',
                      title: titleCtrl.text.trim(),
                      company: companyCtrl.text.trim(),
                      location: locationCtrl.text.trim(),
                      type: typeVal,
                      salaryRange: salaryCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      requirements: '',
                      postedAt: job?.postedAt ?? DateTime.now(),
                      phone: phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      link: linkCtrl.text.trim(),
                      name: nameCtrl.text.trim(),
                      employerId: job?.employerId ?? 'admin',
                      clientCompany: clientCompanyCtrl.text.trim(),
                      status: statusVal,
                    );

                    try {
                      if (job == null) {
                        await FirebaseService.instance.addJob(newJob);
                      } else {
                        await FirebaseService.instance.updateJob(newJob);
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(job == null ? 'Job posted successfully!' : 'Job updated successfully!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    elevation: 0,
                  ),
                  child: const Text('Save Job', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Tab 5: Recent Searches Management
  Widget _buildRecentSearchesPanel() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService.instance.getAdminRecentSearchesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading searches: ${snapshot.error}'));
        }
        final searches = snapshot.data ?? [];
        if (searches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No search records found',
                  style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final isMobilePanel = MediaQuery.of(context).size.width < 600;

        return ListView.builder(
          padding: EdgeInsets.all(isMobilePanel ? 12 : 24),
          itemCount: searches.length,
          itemBuilder: (context, index) {
            final item = searches[index];
            final query = item['query'] ?? '';
            final count = item['count'] ?? 1;
            final docId = item['id'] ?? '';

            // Format Timestamp
            String formattedDate = '';
            if (item['timestamp'] != null) {
              try {
                final date = item['timestamp'] is DateTime
                    ? item['timestamp']
                    : (item['timestamp'] as dynamic).toDate();
                formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              } catch (_) {}
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.search_rounded, color: widget.themeColor, size: 24),
                ),
                title: Text(
                  query,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Searches: $count',
                          style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (item['success'] as bool? ?? false) ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (item['success'] as bool? ?? false) ? 'Found Jobs' : 'No Results',
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: (item['success'] as bool? ?? false) ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (formattedDate.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Last Searched: $formattedDate',
                        style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black38),
                      ),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: Colors.redAccent,
                  tooltip: 'Delete Log',
                  onPressed: () => _confirmDeleteRecentSearch(docId),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteRecentSearch(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Search Log?'),
        content: const Text('Are you sure you want to delete this user search log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseService.instance.deleteRecentSearch(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Search log deleted successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredUsersPanel() {
    final isMobilePanel = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel Header
        Padding(
          padding: EdgeInsets.all(isMobilePanel ? 12 : 24),
          child: Text(
            'Registered Candidates',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // List of registered users
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirebaseService.instance.getRegisteredUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading registered users: ${snapshot.error}'));
              }
              final users = snapshot.data ?? [];
              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No registered candidates found',
                        style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: isMobilePanel ? 12 : 24),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final id = user['id'] ?? '';
                  final name = user['name'] ?? '';
                  final phone = user['phone'] ?? '';
                  final email = user['email'] ?? '';
                  final languages = List<String>.from(user['languages'] ?? []);
                  final pastJobTitle = user['pastJobTitle'] ?? '';
                  final pastJobDescription = user['pastJobDescription'] ?? '';
                  final currentJobTitle = user['currentJobTitle'] ?? '';
                  final currentJobDescription = user['currentJobDescription'] ?? '';
                  final highestEducation = user['highestEducation'] ?? '';
                  final skills = List<String>.from(user['skills'] ?? []);
                  final aadharCardUrl = user['aadharCardUrl'] ?? '';
                  final aadharCardFileName = user['aadharCardFileName'] ?? '';
                  final aadharCardFrontUrl = user['aadharCardFrontUrl'] ?? aadharCardUrl;
                  final aadharCardFrontFileName = user['aadharCardFrontFileName'] ?? aadharCardFileName;
                  final aadharCardBackUrl = user['aadharCardBackUrl'] ?? '';
                  final aadharCardBackFileName = user['aadharCardBackFileName'] ?? '';
                  final resumeUrl = user['resumeUrl'] ?? '';
                  final resumeFileName = user['resumeFileName'] ?? '';

                  String formattedDate = '';
                  if (user['registeredAt'] != null) {
                    try {
                      final date = user['registeredAt'] is DateTime
                          ? user['registeredAt']
                          : (user['registeredAt'] as dynamic).toDate();
                      formattedDate = '${date.day}/${date.month}/${date.year}';
                    } catch (_) {}
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobilePanel ? 14 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: widget.themeColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person_outline_rounded, color: widget.themeColor, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Education: ${highestEducation.isNotEmpty ? highestEducation : "N/A"}',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: widget.themeColor,
                                      ),
                                    ),
                                    if (formattedDate.isNotEmpty)
                                      Text(
                                        'Registered On: $formattedDate',
                                        style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black38),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                color: Colors.redAccent,
                                tooltip: 'Delete Candidate',
                                onPressed: () => _confirmDeleteRegisteredUser(id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          // Grid details
                          Wrap(
                            spacing: 24,
                            runSpacing: 12,
                            children: [
                              _buildAppDetailField(Icons.phone_outlined, 'Phone', phone),
                              _buildAppDetailField(Icons.email_outlined, 'Email', email.isNotEmpty ? email : "N/A"),
                              if (aadharCardFrontFileName.isNotEmpty)
                                _buildAppDetailField(Icons.image_rounded, 'Aadhar Front', aadharCardFrontFileName, isLink: true, resumeUrl: aadharCardFrontUrl),
                              if (aadharCardBackFileName.isNotEmpty)
                                _buildAppDetailField(Icons.image_rounded, 'Aadhar Back', aadharCardBackFileName, isLink: true, resumeUrl: aadharCardBackUrl),
                              if (resumeFileName.isNotEmpty)
                                _buildAppDetailField(Icons.attach_file_rounded, 'Resume', resumeFileName, isLink: true, resumeUrl: resumeUrl),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          if (languages.isNotEmpty) ...[
                            Text(
                              'Languages Speak:',
                              style: GoogleFonts.notoSans(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: languages.map((lang) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(lang, style: GoogleFonts.notoSans(fontSize: 12, color: Colors.black87)),
                              )).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (skills.isNotEmpty) ...[
                            Text(
                              'Skills:',
                              style: GoogleFonts.notoSans(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: skills.map((skill) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.themeColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(skill, style: GoogleFonts.notoSans(fontSize: 12, color: widget.themeColor, fontWeight: FontWeight.w600)),
                              )).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (currentJobTitle.isNotEmpty || currentJobDescription.isNotEmpty) ...[
                            _buildEmploymentDetail(
                              label: 'Current Employment',
                              title: currentJobTitle,
                              desc: currentJobDescription,
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (pastJobTitle.isNotEmpty || pastJobDescription.isNotEmpty) ...[
                            _buildEmploymentDetail(
                              label: 'Past Employment',
                              title: pastJobTitle,
                              desc: pastJobDescription,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmploymentDetail({required String label, required String title, required String desc}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              if (title.isNotEmpty && desc.isNotEmpty) const SizedBox(height: 6),
              if (desc.isNotEmpty)
                Text(
                  desc,
                  style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black54, height: 1.4),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDeleteRegisteredUser(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Candidate Registration', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to permanently delete this candidate profile? This action cannot be undone.', style: GoogleFonts.notoSans()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.notoSans(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseService.instance.deleteRegisteredUser(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Candidate registration deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text('Delete', style: GoogleFonts.notoSans(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _openResume(String resumeUrl) {
    if (resumeUrl.contains('demo-storage.example.com') || resumeUrl.contains('example.com')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Resume Not Available', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'This resume was submitted when Firebase Storage was unavailable or in demo mode, '
            'so the file was not uploaded to the server.\n\n'
            'For new applications, please verify that Firebase Storage is enabled in your Firebase Console.',
            style: GoogleFonts.notoSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: widget.themeColor)),
            ),
          ],
        ),
      );
    } else {
      // Use HTML AnchorElement to natively open the download URL in a new tab
      // This bypasses browser popup blockers and triggers correct downloads for non-PDFs (doc/docx)
      html.AnchorElement(href: resumeUrl)
        ..target = '_blank'
        ..rel = 'noopener noreferrer'
        ..click();
    }
  }
}
