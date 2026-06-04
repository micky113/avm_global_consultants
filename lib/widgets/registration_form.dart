import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../utils/responsive.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => RegistrationFormState();
}

class RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  bool _isSubmitting = false;

  void prefill(String country, String jobTitle) {
    setState(() {
      _countryController.text = country;
    });
    // Visual indicator that field was updated from job board
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied for $jobTitle. Country pre-filled: $country'),
        backgroundColor: const Color(0xFFD4AF37),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _pickResume() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true, // Mandatory for web to get bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Limit file size to 5MB
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size exceeds 5MB limit. Please choose a smaller file.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = file.bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFileName = null;
      _selectedFileBytes = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);

    try {
      final double exp = double.tryParse(_experienceController.text) ?? 0.0;

      await FirebaseService.instance.submitCandidate(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        qualification: _qualificationController.text.trim(),
        experience: exp,
        preferredCountry: _countryController.text.trim(),
        resumeFileName: _selectedFileName,
        resumeFileBytes: _selectedFileBytes,
      );

      if (mounted) {
        // Success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFFD4AF37)),
                SizedBox(width: 10),
                Text('Submission Successful'),
              ],
            ),
            content: Text(
              FirebaseService.instance.isFirebaseInitialized
                  ? 'Your profile and resume have been successfully uploaded to our recruitment system. Our consultants will get in touch shortly.'
                  : 'Profile registered successfully (Running in Mock Demo Mode. Complete Firebase configurations to connect live database!).',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetForm();
                },
                child: const Text('OK', style: TextStyle(color: Color(0xFF0A192F))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Form Submission Failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _qualificationController.clear();
    _experienceController.clear();
    _countryController.clear();
    _clearFile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A), // Slate 900
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 60.0,
        vertical: 80.0,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Slate 800
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'GET PLACED ABROAD',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Candidate Registration',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: isMobile ? 24 : 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 60,
                        height: 3,
                        color: const Color(0xFFD4AF37),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Submit your profile details and upload your CV/Resume. Our onboarding specialists will analyze your details and map them to global matches.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Name & Email
                _rowOrColumn(
                  isMobile,
                  _buildTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                  ),
                  _buildTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email is required';
                      final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailReg.hasMatch(val)) return 'Enter a valid email address';
                      return null;
                    },
                  ),
                ),

                // Phone & Qualification
                _rowOrColumn(
                  isMobile,
                  _buildTextField(
                    label: 'Phone Number (with Country Code)',
                    controller: _phoneController,
                    icon: Icons.phone_android_outlined,
                    validator: (val) => val == null || val.isEmpty ? 'Phone is required' : null,
                  ),
                  _buildTextField(
                    label: 'Highest Qualification',
                    controller: _qualificationController,
                    icon: Icons.school_outlined,
                    validator: (val) => val == null || val.isEmpty ? 'Qualification is required' : null,
                  ),
                ),

                // Experience & Destination Country
                _rowOrColumn(
                  isMobile,
                  _buildTextField(
                    label: 'Total Experience (Years)',
                    controller: _experienceController,
                    icon: Icons.work_history_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Experience is required';
                      if (double.tryParse(val) == null) return 'Must be a valid decimal number';
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: 'Preferred Destination Country',
                    controller: _countryController,
                    icon: Icons.flight_takeoff_outlined,
                    validator: (val) => val == null || val.isEmpty ? 'Preferred country is required' : null,
                  ),
                ),
                const SizedBox(height: 24),

                // File Upload Section
                const Text(
                  'Upload Resume/CV',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickResume,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedFileName != null
                            ? const Color(0xFFD4AF37)
                            : Colors.white30,
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: _selectedFileName != null
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.picture_as_pdf, color: Color(0xFFD4AF37), size: 36),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _selectedFileName!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Ready to submit',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                  onPressed: _clearFile,
                                ),
                              ],
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, color: Colors.white70, size: 40),
                              SizedBox(height: 12),
                              Text(
                                'Click to select Resume/CV (PDF, DOC, DOCX)',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Max file size: 5MB',
                                style: TextStyle(color: Colors.white30, fontSize: 11),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 48),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0A192F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: const Color(0xFFD4AF37).withOpacity(0.3),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A192F)),
                          )
                        : const Text(
                            'Submit Application',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rowOrColumn(bool isMobile, Widget child1, Widget child2) {
    if (isMobile) {
      return Column(
        children: [
          child1,
          const SizedBox(height: 12),
          child2,
          const SizedBox(height: 12),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: child1),
            const SizedBox(width: 24),
            Expanded(child: child2),
          ],
        ),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        filled: true,
        fillColor: const Color(0xFF0F172A),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}
