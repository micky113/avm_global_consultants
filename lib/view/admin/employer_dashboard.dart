import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avm_global_web/services/firebase_service.dart';
import 'package:avm_global_web/models/job.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:js' as js;

bool isValidCompanyEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(email)) {
    return false;
  }
  final domain = email.split('@').last.toLowerCase();
  final genericDomains = {
    'gmail.com',
    'yahoo.com',
    'yahoo.co.in',
    'yahoo.co.uk',
    'outlook.com',
    'hotmail.com',
    'aol.com',
    'mail.com',
    'zoho.com',
    'protonmail.com',
    'icloud.com',
    'gmx.com',
    'yandex.com',
    'rediffmail.com',
    'live.com',
    'msn.com',
  };
  return !genericDomains.contains(domain);
}

class EmployerDashboardDialog extends StatefulWidget {
  final Color themeColor;
  final bool initialAuthenticated;
  final String employerId;
  final String employerEmail;

  const EmployerDashboardDialog({
    super.key,
    required this.themeColor,
    this.initialAuthenticated = false,
    required this.employerId,
    required this.employerEmail,
  });

  @override
  State<EmployerDashboardDialog> createState() => _EmployerDashboardDialogState();
}

class _EmployerDashboardDialogState extends State<EmployerDashboardDialog> {
  String _companyName = '';
  String _employerName = '';

  @override
  void initState() {
    super.initState();
    _loadEmployerProfile();
  }

  Future<void> _loadEmployerProfile() async {
    if (widget.employerId.isEmpty) {
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('employers')
          .doc(widget.employerId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _companyName = doc.data()?['company'] ?? '';
          _employerName = doc.data()?['name'] ?? '';
        });
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.displayName != null) {
          final parts = user.displayName!.split('|');
          setState(() {
            _employerName = parts.first.trim();
            if (parts.length > 1) {
              _companyName = parts[1].trim();
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 800;

    return Container(
      width: isLargeScreen ? screenSize.width * 0.85 : screenSize.width * 0.95,
      height: screenSize.height * 0.85,
      constraints: BoxConstraints(
        maxWidth: isLargeScreen ? screenSize.width * 0.85 : screenSize.width * 0.95,
        maxHeight: screenSize.height * 0.85,
      ),
      child: _buildDashboardView(isLargeScreen),
    );
  }

  // Dashboard Main View (only has Manage Jobs)
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
                      Icons.business_center_rounded,
                      color: Colors.white,
                      size: isMobile ? 24 : 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isMobile 
                            ? 'Employer Console' 
                            : 'AVM Global - Employer Console${_companyName.isNotEmpty ? " ($_companyName)" : ""}',
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
                    tooltip: 'Close Console',
                    icon: Icon(Icons.close_rounded, color: Colors.white, size: isMobile ? 20 : 24),
                    onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : context.go('/'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Body Content (Manage Jobs Panel only)
        Expanded(
          child: _buildJobsPanel(),
        ),
      ],
    );
  }

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
            stream: FirebaseService.instance.getJobsStream(employerId: widget.employerId),
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

  // Dialog form to Add or Edit jobs
  void _addEditJobDialog([Job? job]) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: job?.title ?? '');
    final companyCtrl = TextEditingController(text: job?.company ?? _companyName);
    final locationCtrl = TextEditingController(text: job?.location ?? '');
    final salaryCtrl = TextEditingController(text: job?.salaryRange ?? '');
    final descCtrl = TextEditingController(text: job?.description ?? '');
    final reqsCtrl = TextEditingController(text: job?.requirements ?? '');
    final phoneCtrl = TextEditingController(text: job?.phone ?? '');
    final emailCtrl = TextEditingController(text: job?.email ?? widget.employerEmail);
    final linkCtrl = TextEditingController(text: job?.link ?? '');
    final nameCtrl = TextEditingController(text: job?.name ?? _employerName);
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
                          'Contact Information',
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
                                      hintText: 'e.g. contact@domain.com',
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
                      employerId: widget.employerId,
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
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class EmployerAuthCard extends StatefulWidget {
  final Color themeColor;
  const EmployerAuthCard({super.key, required this.themeColor});

  @override
  State<EmployerAuthCard> createState() => _EmployerAuthCardState();
}

class _EmployerAuthCardState extends State<EmployerAuthCard> {
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _authError;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _authError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isSignUp) {
        final name = _nameController.text.trim();
        final company = _companyController.text.trim();

        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        
        final user = credential.user;
        if (user != null) {
          await user.updateDisplayName("$name | $company");
          
          await FirebaseFirestore.instance.collection('employers').doc(user.uid).set({
            'uid': user.uid,
            'name': name,
            'company': company,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Sign In
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        
        // Double check email is company email
        final user = credential.user;
        if (user != null) {
          final userEmail = user.email ?? '';
          final adminEmails = [
            'mohanty747@gmail.com',
            'vishalmohapatra1928@gmail.com',
          ];
          if (adminEmails.contains(userEmail.toLowerCase()) || !isValidCompanyEmail(userEmail)) {
            // Sign out if admin or not corporate email
            await FirebaseAuth.instance.signOut();
            setState(() {
              _authError = adminEmails.contains(userEmail.toLowerCase())
                  ? 'Administrators should log in through the Admin panel.'
                  : 'Only company/corporate emails are allowed.';
            });
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _authError = e.message ?? 'Authentication failed.';
      });
    } catch (e) {
      setState(() {
        _authError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0A192F);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_center_rounded,
                color: widget.themeColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isSignUp ? 'Create Employer Account' : 'Employer Login',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSignUp 
                  ? 'Register with your corporate email to post and manage jobs.'
                  : 'Enter your company email and password to access the portal.',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            if (_authError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Text(
                  _authError!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_isSignUp) ...[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(
                  labelText: 'Company Name',
                  prefixIcon: const Icon(Icons.business_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter your company name' : null,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Company Email ID',
                hintText: 'e.g. hr@company.com',
                prefixIcon: const Icon(Icons.mail_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Enter your email ID';
                if (!isValidCompanyEmail(val.trim())) {
                  return 'Use a corporate email (no gmail, yahoo, etc.)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isSignUp ? 'Register & Log In' : 'Sign In',
                      style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() {
                _isSignUp = !_isSignUp;
                _authError = null;
              }),
              child: Text(
                _isSignUp 
                    ? 'Already have a corporate account? Sign In'
                    : 'Don\'t have an account? Register your company',
                style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, color: widget.themeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmployerPage extends StatefulWidget {
  const EmployerPage({super.key});

  @override
  State<EmployerPage> createState() => _EmployerPageState();
}

class _EmployerPageState extends State<EmployerPage> {
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isMobile, Color themeColor, Color darkBlue) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleSpacing: isMobile ? 8.0 : 20.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: IconButton(
              tooltip: 'Back to Home',
              icon: Icon(Icons.arrow_back_rounded, color: darkBlue, size: 24),
              onPressed: () => context.go('/'),
            ),
          ),
          title: Row(
            children: [
              Image.asset(
                'images/logo.png',
                fit: BoxFit.contain,
                width: isMobile ? 40 : 54,
                height: isMobile ? 28 : 38,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.business,
                  color: themeColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'AVM Global',
                    style: GoogleFonts.notoSans(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  Text(
                    'Consultants',
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.w500,
                      fontSize: isMobile ? 11 : 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 700;
    const themeColor = Color(0xFF146EB8);
    const darkBlue = Color(0xFF0A192F);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          final email = user.email ?? '';
          final adminEmails = [
            'mohanty747@gmail.com',
            'vishalmohapatra1928@gmail.com',
          ];

          if (adminEmails.contains(email.toLowerCase())) {
            return _buildAdminWarningView(context);
          }

          if (isValidCompanyEmail(email)) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: _buildAppBar(context, isMobile, themeColor, darkBlue),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12.0 : 40.0,
                      vertical: 24.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: EmployerDashboardDialog(
                            themeColor: themeColor,
                            initialAuthenticated: true,
                            employerId: user.uid,
                            employerEmail: email,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        // Unauthenticated - show Login/Signup card
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(context, isMobile, themeColor, darkBlue),
          body: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  margin: const EdgeInsets.all(24.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const EmployerAuthCard(themeColor: themeColor),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminWarningView(BuildContext context) {
    const themeColor = Color(0xFF146EB8);
    const darkBlue = Color(0xFF0A192F);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, false, themeColor, darkBlue),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
                const SizedBox(height: 20),
                Text(
                  'Administrator Session Active',
                  style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue),
                ),
                const SizedBox(height: 12),
                Text(
                  'You are currently signed in as an administrator.\nTo access the Employer Portal, please sign out of your administrator account first.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sign Out of Admin'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
