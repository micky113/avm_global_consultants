import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:avm_global_web/models/job.dart';
import 'package:avm_global_web/services/firebase_service.dart';
import 'package:avm_global_web/view/admin/admin_dashboard.dart';

class JobsPage extends StatefulWidget {
  final String? initialJobId;
  const JobsPage({super.key, this.initialJobId});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final Color themeColor = const Color(0xFF146EB8);
  final Color darkBlue = const Color(0xFF0A192F);

  String _searchQuery = '';
  String _selectedType = 'All'; // 'All', 'Full-time', 'Part-time', 'Contract', etc.
  Job? _selectedJob; // Used for split screen detailed view
  bool _hasInitializedSelection = false;

  final List<String> _jobTypes = ['All', 'Full-time', 'Part-time', 'Contract', 'Remote', 'Hybrid'];

  late final ScrollController _pageScrollController;
  late final Stream<List<Job>> _jobsStream;
  late final TextEditingController _searchController;
  late final FocusNode _pageFocusNode;

  String _getShareUrl(String jobId) {
    final baseUri = Uri.base;
    final href = baseUri.toString();
    if (href.contains('/#/')) {
      return '${baseUri.origin}/#/jobs?id=$jobId';
    } else {
      return '${baseUri.origin}/jobs?id=$jobId';
    }
  }

  @override
  void initState() {
    super.initState();
    _pageScrollController = ScrollController();
    _searchController = TextEditingController();
    _jobsStream = FirebaseService.instance.getJobsStream();
    _pageFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _searchController.dispose();
    _pageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 900;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleSpacing: isMobile ? 16.0 : 40.0,
          leading: IconButton(
            tooltip: 'Back to Home',
            icon: Icon(Icons.arrow_back_rounded, color: darkBlue, size: 24),
            onPressed: () => context.go('/'),
          ),
          title: Row(
            children: [
              Image.asset(
                'images/logo.png',
                fit: BoxFit.contain,
                width: isMobile ? 45 : 55,
                height: isMobile ? 45 : 55,
              ),
              const SizedBox(width: 12),
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
                      fontSize: isMobile ? 12 : 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (!isMobile)
              Padding(
                padding: const EdgeInsets.only(right: 40.0),
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AdminDashboardDialog(themeColor: themeColor);
                      },
                    );
                  },
                  icon: Icon(Icons.admin_panel_settings_rounded, color: themeColor),
                  label: Text(
                    'Admin Console',
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: StreamBuilder<List<Job>>(
        stream: _jobsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading jobs: ${snapshot.error}'));
          }

          final jobs = snapshot.data ?? [];

          // Initialize custom selection from query parameter if available
          if (!_hasInitializedSelection && jobs.isNotEmpty) {
            _hasInitializedSelection = true;
            if (widget.initialJobId != null) {
              final jobIndex = jobs.indexWhere((j) => j.id == widget.initialJobId);
              if (jobIndex != -1) {
                _selectedJob = jobs[jobIndex];
                if (!isDesktop) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showMobileDetailSheet(_selectedJob!);
                  });
                }
              }
            }
          }
          
          // Filter jobs
          final filteredJobs = jobs.where((job) {
            final matchesSearch = job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                job.location.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesType = _selectedType == 'All' || job.type == _selectedType;
            return matchesSearch && matchesType;
          }).toList();

          // Auto-select first job if on desktop and none selected
          if (isDesktop && _selectedJob == null && filteredJobs.isNotEmpty) {
            _selectedJob = filteredJobs.first;
          }

          return Focus(
            focusNode: _pageFocusNode,
            autofocus: true,
            onKeyEvent: (FocusNode node, KeyEvent event) {
              if (FocusManager.instance.primaryFocus?.context?.widget is EditableText) {
                return KeyEventResult.ignored;
              }
              if (event is KeyDownEvent || event is KeyRepeatEvent) {
                const double scrollAmount = 60.0;
                if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  if (_pageScrollController.hasClients) {
                    final maxScroll = _pageScrollController.position.maxScrollExtent;
                    final target = (_pageScrollController.offset + scrollAmount).clamp(0.0, maxScroll);
                    _pageScrollController.animateTo(
                      target,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                    );
                  }
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  if (_pageScrollController.hasClients) {
                    final maxScroll = _pageScrollController.position.maxScrollExtent;
                    final target = (_pageScrollController.offset - scrollAmount).clamp(0.0, maxScroll);
                    _pageScrollController.animateTo(
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
              onTap: () {
                _pageFocusNode.requestFocus();
              },
              child: SingleChildScrollView(
                controller: _pageScrollController,
                child: Column(
              children: [
                // Banner / Search bar section
                _buildHeroSection(isMobile),
                
                // Main content area
                filteredJobs.isEmpty
                    ? SizedBox(
                        height: 400,
                        child: _buildEmptyState(),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12.0 : 40.0,
                          vertical: 20.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Job list panel
                            Expanded(
                              flex: 3,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredJobs.length,
                                itemBuilder: (context, index) {
                                  final job = filteredJobs[index];
                                  final isSelected = isDesktop && _selectedJob?.id == job.id;
                                  return _buildJobCard(job, isSelected, isDesktop);
                                },
                              ),
                            ),
                            
                            // Desktop split detailed panel
                            if (isDesktop && _selectedJob != null) ...[
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 4,
                                child: _buildDetailPanel(_selectedJob!),
                              ),
                            ],
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      );
        },
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor, darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 40.0,
        vertical: isMobile ? 24.0 : 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Global Opportunities',
            style: GoogleFonts.notoSans(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find and apply for premium international careers across Europe, Canada, Australia, and the Middle East.',
            style: GoogleFonts.notoSans(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 24),
          // Search & Filter controls
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search input
              Container(
                width: isMobile ? double.infinity : 320,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search title, company, location...',
                    hintStyle: GoogleFonts.notoSans(fontSize: 14, color: Colors.black38),
                    prefixIcon: Icon(Icons.search_rounded, color: themeColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              
              // Filter dropdown
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    dropdownColor: Colors.white,
                    style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedType = val);
                      }
                    },
                    items: _jobTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Job job, bool isSelected, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected && isDesktop ? themeColor : Colors.grey[200]!,
          width: isSelected && isDesktop ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (isDesktop) {
            setState(() => _selectedJob = job);
            if (_pageScrollController.hasClients) {
              _pageScrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          } else {
            // On mobile, show detailed sheet
            _showMobileDetailSheet(job);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company,
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job.type,
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.monetization_on_outlined, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    job.salaryRange,
                    style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              if (!isDesktop) ...[
                const SizedBox(height: 12),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => _showApplyDialog(job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Apply Now',
                      style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel(Job job) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detail Header
            Container(
              padding: const EdgeInsets.all(24.0),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: GoogleFonts.notoSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              final shareUrl = _getShareUrl(job.id);
                              Clipboard.setData(ClipboardData(text: shareUrl));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Job link copied to clipboard!'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: themeColor,
                              side: BorderSide(color: themeColor),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: Text(
                              'Share Job',
                              style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _showApplyDialog(job),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Apply Now',
                              style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.company,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildDetailBadge(Icons.location_on_rounded, job.location),
                      _buildDetailBadge(Icons.work_rounded, job.type),
                      _buildDetailBadge(Icons.monetization_on_rounded, job.salaryRange),
                    ],
                  ),
                ],
              ),
            ),
            
            // Detail Body
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job Description',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Requirements',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.requirements,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: Colors.grey[350]),
          const SizedBox(height: 16),
          Text(
            'No matching jobs found',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms or filters',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileDetailSheet(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: GoogleFonts.notoSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailBadge(Icons.location_on_rounded, job.location),
                      const SizedBox(height: 8),
                      _buildDetailBadge(Icons.work_rounded, job.type),
                      const SizedBox(height: 8),
                      _buildDetailBadge(Icons.monetization_on_rounded, job.salaryRange),
                      const Divider(height: 32),
                      Text(
                        'Job Description',
                        style: GoogleFonts.notoSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.description,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Requirements',
                        style: GoogleFonts.notoSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.requirements,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final shareUrl = _getShareUrl(job.id);
                                Clipboard.setData(ClipboardData(text: shareUrl));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Job link copied to clipboard!'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: themeColor,
                                side: BorderSide(color: themeColor),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.share_rounded, size: 18),
                              label: Text(
                                'Share',
                                style: GoogleFonts.notoSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showApplyDialog(job);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: Text(
                                'Apply Now',
                                style: GoogleFonts.notoSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showApplyDialog(Job job) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    
    Uint8List? resumeBytes;
    String? resumeName;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickResume() async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx'],
                  allowMultiple: false,
                );
                if (result != null && result.files.single.bytes != null) {
                  setDialogState(() {
                    resumeBytes = result.files.single.bytes;
                    resumeName = result.files.single.name;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error picking resume: $e')),
                );
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply for Job',
                    style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: darkBlue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${job.title} at ${job.company}',
                    style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width < 500
                    ? MediaQuery.of(context).size.width * 0.9
                    : 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          'Full Name',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        Text(
                          'Email Address',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email id',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailReg.hasMatch(val.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Contact Number
                        Text(
                          'Contact Number',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter your phone number',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your phone number' : null,
                        ),
                        const SizedBox(height: 16),

                        // Resume Upload
                        Text(
                          'Upload Resume (PDF, DOC)',
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        if (resumeName == null) ...[
                          OutlinedButton.icon(
                            onPressed: pickResume,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            icon: Icon(Icons.upload_file_rounded, color: themeColor),
                            label: Text(
                              'Select File',
                              style: GoogleFonts.notoSans(color: Colors.black87),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: themeColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.picture_as_pdf_rounded, color: themeColor),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    resumeName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel_rounded, color: Colors.grey),
                                  onPressed: () {
                                    setDialogState(() {
                                      resumeName = null;
                                      resumeBytes = null;
                                    });
                                  },
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
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          if (resumeBytes == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select and upload your resume'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);

                          try {
                            await FirebaseService.instance.submitJobApplication(
                              jobId: job.id,
                              jobTitle: job.title,
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              resumeFileName: resumeName,
                              resumeFileBytes: resumeBytes,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              _showSuccessDialog(job.title, job.company);
                            }
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Submission failed: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    disabledBackgroundColor: Colors.grey,
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Submit Application', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(String jobTitle, String company) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Application Submitted!',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have successfully applied for the position of $jobTitle at $company. Our recruitment team will review your profile and get back to you shortly.',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Great', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
