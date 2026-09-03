import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avm_global_web/services/firebase_service.dart';
import 'package:avm_global_web/models/job.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;

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
  final bool isFullScreenPage;

  const EmployerDashboardDialog({
    super.key,
    required this.themeColor,
    this.initialAuthenticated = false,
    required this.employerId,
    required this.employerEmail,
    this.isFullScreenPage = false,
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

    if (widget.isFullScreenPage) {
      return _buildDashboardView(isLargeScreen);
    }

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
                physics: const AlwaysScrollableScrollPhysics(),
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
    final companyCtrl = TextEditingController(text: job?.company ?? _companyName);
    final locationCtrl = TextEditingController(text: job?.location ?? '');
    final salaryCtrl = TextEditingController(text: job?.salaryRange ?? '');
    final descCtrl = TextEditingController(text: job?.description ?? '');
    final phoneCtrl = TextEditingController(text: job?.phone ?? '');
    final emailCtrl = TextEditingController(text: job?.email ?? widget.employerEmail);
    final linkCtrl = TextEditingController(text: job?.link ?? '');
    final nameCtrl = TextEditingController(text: job?.name ?? _employerName);
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
                      requirements: '',
                      postedAt: job?.postedAt ?? DateTime.now(),
                      phone: phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      link: linkCtrl.text.trim(),
                      name: nameCtrl.text.trim(),
                      employerId: widget.employerId,
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
  bool _hasUserTypedPassword = false;
  String? _authError;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _companyController.clear();
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus && !_hasUserTypedPassword) {
        _passwordController.clear();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _passwordFocusNode.dispose();
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
              autofillHints: const [],
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
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [AutofillHints.oneTimeCode],
              keyboardType: TextInputType.visiblePassword,
              onChanged: (val) {
                _hasUserTypedPassword = true;
              },
              decoration: InputDecoration(
                labelText: _isSignUp ? 'Create Password' : 'Password',
                hintText: 'Enter password',
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
                _hasUserTypedPassword = false;
                _passwordController.clear();
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
  late final ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isMobile, Color themeColor, Color darkBlue) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
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
                width: isMobile ? 42 : 58,
                height: isMobile ? 42 : 58,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.business,
                  color: themeColor,
                  size: 38,
                ),
              ),
              const SizedBox(width: 8),
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
                child: Center(
                  child: Container(
                    width: isMobile ? screenSize.width * 0.95 : (screenSize.width > 1200 ? 1200 : screenSize.width * 0.9),
                    height: screenSize.height * 0.85,
                    margin: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8.0 : 24.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: EmployerDashboardDialog(
                      themeColor: themeColor,
                      initialAuthenticated: true,
                      employerId: user.uid,
                      employerEmail: email,
                      isFullScreenPage: true,
                    ),
                  ),
                ),
              ),
            );
          }
        }

        // Unauthenticated - show Login/Signup card with full keyboard scrolling support
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(context, isMobile, themeColor, darkBlue),
          body: Focus(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (FocusNode node, KeyEvent event) {
              final focusedContext = FocusManager.instance.primaryFocus?.context;
              if (focusedContext != null) {
                final widget = focusedContext.widget;
                if (widget is EditableText ||
                    widget is TextField ||
                    widget is TextFormField ||
                    focusedContext.findAncestorWidgetOfExactType<EditableText>() != null) {
                  return KeyEventResult.ignored;
                }
              }
              if (event is KeyDownEvent || event is KeyRepeatEvent) {
                const double scrollAmount = 60.0;
                if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                    event.logicalKey == LogicalKeyboardKey.pageDown) {
                  if (_scrollController.hasClients) {
                    final maxScroll = _scrollController.position.maxScrollExtent;
                    final delta = event.logicalKey == LogicalKeyboardKey.pageDown ? 300.0 : scrollAmount;
                    final target = (_scrollController.offset + delta).clamp(0.0, maxScroll);
                    _scrollController.animateTo(
                      target,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                    );
                  }
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                    event.logicalKey == LogicalKeyboardKey.pageUp) {
                  if (_scrollController.hasClients) {
                    final maxScroll = _scrollController.position.maxScrollExtent;
                    final delta = event.logicalKey == LogicalKeyboardKey.pageUp ? 300.0 : scrollAmount;
                    final target = (_scrollController.offset - delta).clamp(0.0, maxScroll);
                    _scrollController.animateTo(
                      target,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                    );
                  }
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: const EmployerAuthCard(themeColor: themeColor),
                      ),
                    ),
                  ),
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
        child: SingleChildScrollView(
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
      ),
    );
  }
}
