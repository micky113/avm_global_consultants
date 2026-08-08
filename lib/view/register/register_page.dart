import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:avm_global_web/view/about_us/about_us_base_page.dart';
import 'package:avm_global_web/services/firebase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _highestEducationController = TextEditingController();
  final TextEditingController _currentJobTitleController = TextEditingController();
  final TextEditingController _currentJobDescController = TextEditingController();
  final TextEditingController _pastJobTitleController = TextEditingController();
  final TextEditingController _pastJobDescController = TextEditingController();

  // Tag Input Fields
  final TextEditingController _languageInputController = TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();

  final List<String> _languages = [];
  final List<String> _skills = [];

  // ID Proof Selection
  Uint8List? _idProofBytes;
  String? _idProofName;
  bool _isPickingFile = false;
  String? _idProofError;

  // Optional Resume Selection
  Uint8List? _resumeBytes;
  String? _resumeName;
  bool _isPickingResume = false;

  // Page States
  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _highestEducationController.dispose();
    _currentJobTitleController.dispose();
    _currentJobDescController.dispose();
    _pastJobTitleController.dispose();
    _pastJobDescController.dispose();
    _languageInputController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  // Pick Aadhar Card Image
  Future<void> _pickIdProof() async {
    setState(() {
      _isPickingFile = true;
      _idProofError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _idProofBytes = result.files.single.bytes;
          _idProofName = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() {
        _idProofError = 'Error picking file: $e';
      });
    } finally {
      setState(() => _isPickingFile = false);
    }
  }

  void _clearIdProof() {
    setState(() {
      _idProofBytes = null;
      _idProofName = null;
      _idProofError = null;
    });
  }

  // Pick Resume (Optional)
  Future<void> _pickResume() async {
    setState(() {
      _isPickingResume = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _resumeBytes = result.files.single.bytes;
          _resumeName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isPickingResume = false);
    }
  }

  void _clearResume() {
    setState(() {
      _resumeBytes = null;
      _resumeName = null;
    });
  }

  // Tags/Chips helper additions
  void _addLanguage() {
    final text = _languageInputController.text.trim();
    if (text.isNotEmpty && !_languages.contains(text)) {
      setState(() {
        _languages.add(text);
        _languageInputController.clear();
      });
    }
  }

  void _addSkill() {
    final text = _skillInputController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _skillInputController.clear();
      });
    }
  }

  // Submission handler
  Future<void> _submitRegistration() async {
    // Check form inputs
    final isFormValid = _formKey.currentState?.validate() ?? false;
    
    // Check ID proof (Compulsory)
    bool isIdProofValid = true;
    if (_idProofBytes == null || _idProofName == null) {
      setState(() {
        _idProofError = 'Please upload a photo of your Aadhar card (ID Proof)';
      });
      isIdProofValid = false;
    }

    if (!isFormValid || !isIdProofValid) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseService.instance.registerUser(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        languages: _languages,
        pastJobTitle: _pastJobTitleController.text.trim(),
        pastJobDescription: _pastJobDescController.text.trim(),
        currentJobTitle: _currentJobTitleController.text.trim(),
        currentJobDescription: _currentJobDescController.text.trim(),
        highestEducation: _highestEducationController.text.trim(),
        skills: _skills,
        idProofFileName: _idProofName!,
        idProofFileBytes: _idProofBytes!,
        resumeFileName: _resumeName,
        resumeFileBytes: _resumeBytes,
      );

      setState(() {
        _isSuccess = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF146EB8);
    const darkBlue = Color(0xFF0A192F);

    if (_isSuccess) {
      return AboutUsBasePage(
        title: 'Registration Successful',
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Registration Completed!',
                      style: GoogleFonts.notoSans(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Thank you for registering, ${_nameController.text.trim()}. Your profile has been uploaded successfully. Our consultants will evaluate your skills and contact you if there are matching opportunities.',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => context.go('/'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Return to Homepage',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return AboutUsBasePage(
      title: 'Register as Candidate',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Complete Your Candidate Profile',
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please fill out all mandatory fields to register with AVM Global Consultants. Make sure to provide a valid phone number and Aadhar card image.',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),

                // Card Section: Personal Information
                _buildCardSection(
                  title: '1. Personal Information',
                  icon: Icons.person_rounded,
                  themeColor: themeColor,
                  darkBlue: darkBlue,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _nameController,
                            label: 'Full Name (Compulsory)',
                            icon: Icons.person_outline_rounded,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number (Compulsory)',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email ID',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(val.trim())) {
                            return 'Please enter a valid email address';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Languages chip field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _languageInputController,
                            onSubmitted: (_) => _addLanguage(),
                            decoration: _inputDecoration(
                              label: 'Languages you can speak (Press enter or add)',
                              icon: Icons.translate_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          onPressed: _addLanguage,
                          style: IconButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    if (_languages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _languages.map((lang) {
                          return Chip(
                            label: Text(lang),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _languages.remove(lang);
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: themeColor.withOpacity(0.2)),
                            ),
                            backgroundColor: themeColor.withOpacity(0.05),
                            labelStyle: GoogleFonts.notoSans(
                              fontWeight: FontWeight.w600,
                              color: themeColor,
                              fontSize: 13,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Card Section: Professional Experience
                _buildCardSection(
                  title: '2. Professional Experience & Education',
                  icon: Icons.work_history_rounded,
                  themeColor: themeColor,
                  darkBlue: darkBlue,
                  children: [
                    _buildTextField(
                      controller: _highestEducationController,
                      label: 'Highest Education (e.g. Master in CS, B.Tech, Nursing Diploma)',
                      icon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _skillInputController,
                            onSubmitted: (_) => _addSkill(),
                            decoration: _inputDecoration(
                              label: 'Key Skills (Press enter or add)',
                              icon: Icons.bolt_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          onPressed: _addSkill,
                          style: IconButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    if (_skills.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _skills.map((skill) {
                          return Chip(
                            label: Text(skill),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _skills.remove(skill);
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: themeColor.withOpacity(0.2)),
                            ),
                            backgroundColor: themeColor.withOpacity(0.05),
                            labelStyle: GoogleFonts.notoSans(
                              fontWeight: FontWeight.w600,
                              color: themeColor,
                              fontSize: 13,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Current Employment Details',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _currentJobTitleController,
                      label: 'Current Job Title',
                      icon: Icons.work_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _currentJobDescController,
                      label: 'Current Job Description',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Past Employment Details',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _pastJobTitleController,
                      label: 'Past Job Title',
                      icon: Icons.history_toggle_off_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _pastJobDescController,
                      label: 'Past Job Description',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Card Section: Identity Verification (Aadhar Upload)
                _buildCardSection(
                  title: '3. Identity Verification (Compulsory)',
                  icon: Icons.verified_user_rounded,
                  themeColor: themeColor,
                  darkBlue: darkBlue,
                  children: [
                    Text(
                      'Please upload a clear scan or picture of your Aadhar Card. Only JPG, JPEG, and PNG formats are accepted.',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _isPickingFile ? null : _pickIdProof,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: _idProofBytes != null
                                ? Colors.green.withOpacity(0.02)
                                : Colors.blue.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _idProofError != null
                                  ? Colors.redAccent
                                  : _idProofBytes != null
                                      ? Colors.green.withOpacity(0.4)
                                      : themeColor.withOpacity(0.3),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _idProofBytes != null
                              ? Stack(
                                  children: [
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.memory(
                                              _idProofBytes!,
                                              width: 200,
                                              height: 110,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Container(
                                                color: Colors.grey[200],
                                                width: 200,
                                                height: 110,
                                                child: const Icon(Icons.image_rounded, size: 40, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            _idProofName ?? 'Image Uploaded',
                                            style: GoogleFonts.notoSans(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[800],
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 2,
                                        ),
                                        onPressed: _clearIdProof,
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isPickingFile) ...[
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Opening File Picker...',
                                          style: GoogleFonts.notoSans(color: Colors.black54),
                                        ),
                                      ] else ...[
                                        Icon(
                                          Icons.cloud_upload_outlined,
                                          size: 48,
                                          color: themeColor.withOpacity(0.8),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Click here to upload Aadhar Card',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: themeColor,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'JPG, JPEG, or PNG',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 12,
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (_idProofError != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _idProofError!,
                              style: GoogleFonts.notoSans(
                                color: Colors.redAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Card Section: Resume Upload (Optional)
                _buildCardSection(
                  title: '4. Resume / CV (Optional)',
                  icon: Icons.description_rounded,
                  themeColor: themeColor,
                  darkBlue: darkBlue,
                  children: [
                    Text(
                      'Please upload your latest Resume or CV. PDF, DOC, and DOCX formats are accepted.',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _isPickingResume ? null : _pickResume,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: _resumeBytes != null
                                ? Colors.green.withOpacity(0.02)
                                : Colors.blue.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _resumeBytes != null
                                  ? Colors.green.withOpacity(0.4)
                                  : themeColor.withOpacity(0.3),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _resumeBytes != null
                              ? Stack(
                                  children: [
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.insert_drive_file_rounded,
                                            size: 40,
                                            color: themeColor,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            _resumeName ?? 'Resume Uploaded',
                                            style: GoogleFonts.notoSans(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[800],
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 2,
                                        ),
                                        onPressed: _clearResume,
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isPickingResume) ...[
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Opening File Picker...',
                                          style: GoogleFonts.notoSans(color: Colors.black54),
                                        ),
                                      ] else ...[
                                        Icon(
                                          Icons.cloud_upload_outlined,
                                          size: 40,
                                          color: themeColor.withOpacity(0.8),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Click here to upload Resume',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: themeColor,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'PDF, DOC, or DOCX',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 12,
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Register Button / Submission state
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      disabledBackgroundColor: themeColor.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Registering Profile...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Register Now',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Visual helper: Form cards
  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Color themeColor,
    required Color darkBlue,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.black12.withOpacity(0.06)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: themeColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  // Visual helper: Custom text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label: label, icon: icon),
      style: GoogleFonts.notoSans(fontSize: 15),
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.notoSans(fontSize: 14, color: Colors.black45),
      prefixIcon: Icon(icon, color: Colors.black45, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF146EB8), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}
