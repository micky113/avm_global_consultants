import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:avm_global_web/models/job.dart';
import 'package:avm_global_web/services/firebase_service.dart';
import 'package:avm_global_web/view/admin/admin_dashboard.dart';
import 'package:avm_global_web/view/admin/employer_dashboard.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:js' as js;

class JobsPage extends StatefulWidget {
  final String? initialJobId;
  final String? initialSearchQuery;
  final String? initialLocationQuery;
  const JobsPage({
    super.key,
    this.initialJobId,
    this.initialSearchQuery,
    this.initialLocationQuery,
  });

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
  String _markedSuccessQuery = '';
  String _locationQuery = '';
  bool _showingFallbackResults = false;

  final List<String> _jobTypes = ['All', 'Full-time', 'Part-time', 'Contract', 'Remote', 'Hybrid'];

  static const Map<String, List<String>> _countryToCities = {
    'india': [
      'bengaluru', 'bangalore',
      'mumbai', 'bombay',
      'chennai', 'madras',
      'kolkata', 'calcutta',
      'gurugram', 'gurgaon',
      'pune', 'poona',
      'kochi', 'cochin',
      'trivandrum', 'thiruvananthapuram',
      'vizag', 'visakhapatnam',
      'baroda', 'vadodara',
      'mysore', 'mysuru',
      'calicut', 'kozhikode',
      'belgaum', 'belagavi',
      'gulbarga', 'kalaburagi',
      'hubli', 'hubballi',
      'mangalore', 'mangaluru',
      'sholapur', 'solapur',
      'jullundur', 'jalandhar',
      'cawnpore', 'kanpur',
      'panjim', 'panaji',
      'pondicherry', 'puducherry', 'pondy',
      'alleppey', 'alappuzha',
      'quilon', 'kollam',
      'trichur', 'thrissur',
      'palghat', 'palakkad',
      'cannanore', 'kannur',
      'tellicherry', 'thalassery',
      'delhi', 'new delhi',
      'hyderabad', 'secunderabad',
      'ahmedabad', 'surat', 'jaipur', 'lucknow', 'patna', 'bhopal'
    ],
    'germany': ['munich', 'münchen', 'berlin', 'frankfurt', 'hamburg', 'stuttgart', 'dusseldorf', 'düsseldorf', 'cologne', 'köln', 'dresden', 'bonn', 'nuremberg', 'nürnberg', 'leipzig'],
    'canada': ['toronto', 'vancouver', 'montreal', 'ville-marie', 'ottawa', 'calgary', 'edmonton', 'quebec', 'winnipeg', 'halifax'],
    'australia': ['sydney', 'melbourne', 'brisbane', 'perth', 'adelaide', 'canberra', 'hobart', 'darwin'],
    'united kingdom': ['london', 'londinium', 'manchester', 'birmingham', 'glasgow', 'edinburgh', 'liverpool', 'leeds', 'sheffield', 'bristol'],
    'uk': ['london', 'londinium', 'manchester', 'birmingham', 'glasgow', 'edinburgh', 'liverpool', 'leeds', 'sheffield', 'bristol'],
    'ireland': ['dublin', 'cork', 'galway', 'limerick', 'waterford'],
    'poland': ['warsaw', 'warszawa', 'krakow', 'kraków', 'wroclaw', 'wrocław', 'poznan', 'poznań', 'gdansk', 'gdańsk', 'lodz', 'łódź', 'katowice'],
    'croatia': ['zagreb', 'split', 'rijeka', 'zadar', 'dubrovnik'],
    'lithuania': ['vilnius', 'kaunas', 'klaipeda', 'klaipėda'],
    'romania': ['bucharest', 'bucurești', 'cluj', 'cluj-napoca', 'timisoara', 'timișoara', 'iasi', 'iași', 'constanta', 'constanța'],
    'france': ['paris', 'marseille', 'lyon', 'toulouse', 'nice', 'nantes', 'strasbourg'],
    'united arab emirates': ['dubai', 'abu dhabi', 'sharjah', 'ajman', 'al ain'],
    'uae': ['dubai', 'abu dhabi', 'sharjah', 'ajman', 'al ain'],
    'saudi arabia': ['riyadh', 'jeddah', 'mecca', 'makkah', 'medina', 'madinah', 'dammam', 'khobar', 'al khobar'],
    'ksa': ['riyadh', 'jeddah', 'mecca', 'makkah', 'medina', 'madinah', 'dammam', 'khobar', 'al khobar'],
    'qatar': ['doha', 'al rayyan', 'al wakrah'],
    'oman': ['muscat', 'salalah', 'sohar'],
    'kuwait': ['kuwait city'],
    'bahrain': ['manama'],
    'netherlands': ['amsterdam', 'rotterdam', 'the hague', 'den haag', 'utrecht', 'eindhoven'],
    'austria': ['vienna', 'wien', 'salzburg', 'graz', 'linz', 'innsbruck'],
    'switzerland': ['zurich', 'zürich', 'geneva', 'genève', 'basel', 'bern', 'lausanne'],
    'italy': ['rome', 'roma', 'milan', 'milano', 'naples', 'napoli', 'turin', 'torino', 'palermo', 'genoa', 'genova', 'florence', 'firenze', 'venice', 'venezia'],
    'spain': ['madrid', 'barcelona', 'valencia', 'seville', 'sevilla', 'zaragoza', 'malaga', 'málaga'],
    'united states': ['new york', 'los angeles', 'chicago', 'houston', 'phoenix', 'san francisco', 'seattle', 'boston', 'miami', 'dallas'],
    'us': ['new york', 'los angeles', 'chicago', 'houston', 'phoenix', 'san francisco', 'seattle', 'boston', 'miami', 'dallas'],
    'usa': ['new york', 'los angeles', 'chicago', 'houston', 'phoenix', 'san francisco', 'seattle', 'boston', 'miami', 'dallas'],
    'malta': ['valletta', 'sliema', 'st. julian\'s', 'msida', 'gzira', 'birkirkara'],
    'luxembourg': ['luxembourg city', 'esch-sur-alzette', 'differdange', 'dudelange'],
    'belgium': ['brussels', 'bruxelles', 'antwerp', 'antwerpen', 'ghent', 'gent', 'charleroi', 'liege', 'liège', 'bruges', 'brugge'],
    'sweden': ['stockholm', 'gothenburg', 'göteborg', 'malmo', 'malmö', 'uppsala'],
    'norway': ['oslo', 'christiania', 'kristiania', 'bergen', 'trondheim', 'stavanger'],
    'finland': ['helsinki', 'helsingfors', 'espoo', 'esbo', 'tampere', 'vantaa', 'vanda'],
    'denmark': ['copenhagen', 'københavn', 'aarhus', 'århus', 'odense', 'aalborg'],
    'new zealand': ['auckland', 'wellington', 'christchurch', 'hamilton', 'tauranga'],
    'nz': ['auckland', 'wellington', 'christchurch', 'hamilton', 'tauranga'],
    'vietnam': ['ho chi minh city', 'saigon', 'sài gòn', 'hanoi', 'hà nội', 'da nang', 'đà nẵng'],
    'turkey': ['istanbul', 'constantinople', 'ankara', 'izmir'],
    'russia': ['st. petersburg', 'leningrad', 'petrograd', 'moscow', 'volgograd', 'stalingrad'],
  };

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

  String _getPostedAgoText(DateTime postedAt) {
    final now = DateTime.now();
    final difference = now.difference(postedAt);

    if (difference.inDays < 0) {
      return 'Posted today';
    }

    if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return 'Posted ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return 'Posted ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Posted just now';
      }
    } else if (difference.inDays == 1) {
      return 'Posted yesterday';
    } else if (difference.inDays < 30) {
      return 'Posted ${difference.inDays} days ago';
    } else {
      final months = (difference.inDays / 30).floor();
      if (months == 1) {
        return 'Posted 1 month ago';
      } else {
        return 'Posted $months months ago';
      }
    }
  }

  bool _jobMatches(Job job, List<String> queryTerms) {
    if (queryTerms.isEmpty) return true;
    final title = job.title.toLowerCase();
    final company = job.company.toLowerCase();

    for (final term in queryTerms) {
      if (!(title.contains(term) || company.contains(term))) {
        return false;
      }
    }
    return true;
  }

  bool _locationMatches(Job job, List<String> locationTerms) {
    if (locationTerms.isEmpty) return true;
    final location = job.location.toLowerCase();

    for (final term in locationTerms) {
      bool termMatches = location.contains(term);

      if (!termMatches && _countryToCities.containsKey(term)) {
        final cities = _countryToCities[term]!;
        termMatches = cities.any((city) => location.contains(city));
      }

      if (!termMatches) return false;
    }
    return true;
  }

  bool _jobAndLocationMatchesCombined(Job job, List<String> queryTerms) {
    if (queryTerms.isEmpty) return true;
    final title = job.title.toLowerCase();
    final company = job.company.toLowerCase();
    final location = job.location.toLowerCase();

    for (final term in queryTerms) {
      bool termMatches = title.contains(term) ||
          company.contains(term) ||
          location.contains(term);

      if (!termMatches && _countryToCities.containsKey(term)) {
        final cities = _countryToCities[term]!;
        termMatches = cities.any((city) => location.contains(city));
      }

      if (!termMatches) return false;
    }
    return true;
  }

  void _logJobView(Job job) {
    FirebaseAnalytics.instance.logEvent(
      name: 'view_job',
      parameters: {
        'job_id': job.id,
        'job_title': job.title,
        'job_company': job.company,
      },
    );
    if (kIsWeb && js.context.hasProperty('gtag')) {
      js.context.callMethod('gtag', [
        'event',
        'view_job',
        js.JsObject.jsify({
          'job_id': job.id,
          'job_title': job.title,
          'job_company': job.company,
        })
      ]);
    }
  }

  Widget _buildFallbackBanner(bool isMobile) {
    if (!_showingFallbackResults || _locationQuery.isEmpty || _searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No $_searchQuery jobs found in $_locationQuery. Showing $_searchQuery jobs in other locations.',
              style: GoogleFonts.notoSans(
                color: Colors.orange[800],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageScrollController = ScrollController();
    _searchController = TextEditingController();
    if (widget.initialSearchQuery != null) {
      _searchQuery = widget.initialSearchQuery!;
    }
    if (widget.initialLocationQuery != null) {
      _locationQuery = widget.initialLocationQuery!;
    }

    if (_searchQuery.isNotEmpty && _locationQuery.isNotEmpty) {
      _searchController.text = '$_searchQuery $_locationQuery';
    } else if (_searchQuery.isNotEmpty) {
      _searchController.text = _searchQuery;
    } else if (_locationQuery.isNotEmpty) {
      _searchController.text = _locationQuery;
    }

    _jobsStream = FirebaseService.instance.getJobsStream();
    _pageFocusNode = FocusNode();

    // Log analytics page view on enter
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Jobs',
      screenClass: 'JobsPage',
    );
    FirebaseAnalytics.instance.logEvent(
      name: 'custom_page_view',
      parameters: {
        'page_path': '/jobs',
        'page_title': 'Jobs',
        'page_location': '${Uri.base.origin}/jobs',
      },
    );

    // Direct GA4 Javascript event call for single page app (SPA) tracking
    if (kIsWeb && js.context.hasProperty('gtag')) {
      js.context.callMethod('gtag', [
        'event',
        'page_view',
        js.JsObject.jsify({
          'page_title': 'Jobs',
          'page_path': '/jobs',
          'page_location': '${Uri.base.origin}/jobs',
        })
      ]);
    }
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
                width: isMobile ? 40 : 54,
                height: isMobile ? 28 : 38,
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
          actions: [
            if (!isMobile) ...[
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/employer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeColor,
                    side: BorderSide(color: themeColor, width: 2.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.post_add_rounded, size: 16),
                  label: Text(
                    'Post a Job',
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
                _logJobView(_selectedJob!);
                if (!isDesktop) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showMobileDetailSheet(_selectedJob!);
                  });
                }
              }
            }
          }
          
          // Filter jobs
          bool showingFallback = false;
          List<Job> filteredJobs = [];

          if (_locationQuery.isNotEmpty) {
            final jobQueryTerms = _searchQuery
                .toLowerCase()
                .split(RegExp(r'\s+'))
                .where((term) => term.isNotEmpty)
                .toList();

            final locQueryTerms = _locationQuery
                .toLowerCase()
                .split(RegExp(r'\s+'))
                .where((term) => term.isNotEmpty)
                .toList();

            // Try both first
            final primaryJobs = jobs.where((job) {
              final matchesType = _selectedType == 'All' || job.type == _selectedType;
              return matchesType && _jobMatches(job, jobQueryTerms) && _locationMatches(job, locQueryTerms);
            }).toList();

            if (primaryJobs.isNotEmpty) {
              filteredJobs = primaryJobs;
            } else if (jobQueryTerms.isNotEmpty) {
              // Fallback to job only
              final fallbackJobs = jobs.where((job) {
                final matchesType = _selectedType == 'All' || job.type == _selectedType;
                return matchesType && _jobMatches(job, jobQueryTerms);
              }).toList();

              if (fallbackJobs.isNotEmpty) {
                filteredJobs = fallbackJobs;
                showingFallback = true;
              }
            }
          } else {
            // Combined query
            final queryTerms = _searchQuery
                .toLowerCase()
                .split(RegExp(r'\s+'))
                .where((term) => term.isNotEmpty)
                .toList();

            filteredJobs = jobs.where((job) {
              final matchesType = _selectedType == 'All' || job.type == _selectedType;
              return matchesType && _jobAndLocationMatchesCombined(job, queryTerms);
            }).toList();
          }

          // Update state in post frame callback to avoid setting state during build
          if (showingFallback != _showingFallbackResults) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _showingFallbackResults = showingFallback;
                });
              }
            });
          }

          // Mark search query as successful in Firestore if it contains elements and returns jobs
          if (_searchQuery.trim().isNotEmpty && filteredJobs.isNotEmpty && _searchQuery != _markedSuccessQuery) {
            _markedSuccessQuery = _searchQuery;
            FirebaseService.instance.markSearchSuccessful(_searchQuery);
          }

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
                
                // Fallback banner
                _buildFallbackBanner(isMobile),
                
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
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _locationQuery = '';
                    });
                  },
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
          _logJobView(job);
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
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        job.location,
                        style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.monetization_on_outlined, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        job.salaryRange,
                        style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        _getPostedAgoText(job.postedAt),
                        style: GoogleFonts.notoSans(fontSize: 13, color: Colors.black54),
                      ),
                    ],
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
    return SelectionArea(
      child: Container(
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
                        _buildDetailBadge(Icons.calendar_today_rounded, _getPostedAgoText(job.postedAt)),
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
                    SelectableText(
                      'Job Description',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      job.description,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SelectableText(
                      'Requirements',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
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
        return SelectionArea(
          child: Container(
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
                        const SizedBox(height: 8),
                        _buildDetailBadge(Icons.calendar_today_rounded, _getPostedAgoText(job.postedAt)),
                        const Divider(height: 32),
                        SelectableText(
                          'Job Description',
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          job.description,
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SelectableText(
                          'Requirements',
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
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
