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
import 'dart:js' as js;

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
                        id: 'testimonials',
                        title: 'Manage Testimonials',
                        icon: Icons.reviews_rounded,
                        isLargeScreen: isLargeScreen,
                      ),
                    ],
                  ),
                ),
              
              // Panel Display Area
              Expanded(
                child: Container(
                  color: Colors.grey[100],
                  child: _activeTab == 'inquiries'
                      ? _buildInquiriesPanel()
                      : _activeTab == 'jobs'
                          ? _buildJobsPanel()
                          : _activeTab == 'job_applications'
                              ? _buildJobApplicationsPanel()
                              : _buildTestimonialsPanel(),
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
                          : 3,
              onTap: (index) {
                setState(() {
                  _activeTab = index == 0
                      ? 'inquiries'
                      : index == 1
                          ? 'jobs'
                          : index == 2
                              ? 'job_applications'
                              : 'testimonials';
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
                  icon: Icon(Icons.reviews_rounded),
                  label: 'Reviews',
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
                                if (job.phone.isNotEmpty || job.email.isNotEmpty || job.link.isNotEmpty || job.name.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 6,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
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

  // Dialog form to Add or Edit jobs
  void _addEditJobDialog([Job? job]) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: job?.title ?? '');
    final companyCtrl = TextEditingController(text: job?.company ?? '');
    final locationCtrl = TextEditingController(text: job?.location ?? '');
    final salaryCtrl = TextEditingController(text: job?.salaryRange ?? '');
    final descCtrl = TextEditingController(text: job?.description ?? '');
    final reqsCtrl = TextEditingController(text: job?.requirements ?? '');
    final phoneCtrl = TextEditingController(text: job?.phone ?? '');
    final emailCtrl = TextEditingController(text: job?.email ?? '');
    final linkCtrl = TextEditingController(text: job?.link ?? '');
    final nameCtrl = TextEditingController(text: job?.name ?? '');
    String typeVal = job?.type ?? 'Full-time';

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

                        // Company and Location
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Type and Salary Range
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
                                ],
                              ),
                            ),
                          ],
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

                        // Requirements
                        Text('Job Requirements (Bulleted lines)', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: reqsCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: '• Requirement 1\n• Requirement 2\n...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Requirements required' : null,
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
                      requirements: reqsCtrl.text.trim(),
                      postedAt: job?.postedAt ?? DateTime.now(),
                      phone: phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      link: linkCtrl.text.trim(),
                      name: nameCtrl.text.trim(),
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
      js.context.callMethod('open', [resumeUrl]);
    }
  }
}
