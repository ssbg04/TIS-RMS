import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/settings_service.dart'; // Import the shared service
import '../../auth/login_screen.dart'; 

class TeacherSettingsTab extends StatefulWidget {
  const TeacherSettingsTab({super.key});

  @override
  State<TeacherSettingsTab> createState() => _TeacherSettingsTabState();
}

class _TeacherSettingsTabState extends State<TeacherSettingsTab> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color cardBg = Colors.white;

  // Utilize the shared service
  final SettingsService _settingsService = SettingsService();

  // Controllers to hold the text data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  // Validation errors
  String? _nameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- 1. CALL SERVICE TO FETCH DATA ---
  Future<void> _loadUserData() async {
    try {
      final userData = await _settingsService.getUserProfile();

      if (userData != null) {
        // Handle the phone number conversion for the UI (+63 prefix handling)
        String rawPhone = userData['phone'] ?? '';
        String displayPhone = rawPhone;
        
        if (rawPhone.startsWith('0')) {
          displayPhone = rawPhone.substring(1);
        } else if (rawPhone.startsWith('+63')) {
          displayPhone = rawPhone.substring(3).trim(); 
        }

        if (mounted) {
          setState(() {
            _nameController.text = userData['full_name'] ?? '';
            _emailController.text = userData['email'] ?? userData['auth_email'] ?? '';
            _phoneController.text = displayPhone; 
            _isLoading = false;
          });
        }
      } else {
        _showSnackBar('User profile not found.', Colors.orange);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('Error loading profile: $e', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // --- 2. VALIDATE AND CALL SERVICE TO UPDATE DATA ---
  Future<void> _updateUserData() async {
    // Reset errors
    setState(() {
      _nameError = null;
      _phoneError = null;
    });

    bool isValid = true;

    // Validate Full Name
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Full Name cannot be empty');
      isValid = false;
    }

    // Validate Phone Number (Needs to be exactly 10 digits since +63 is prefixed)
    if (_phoneController.text.trim().isNotEmpty && _phoneController.text.trim().length != 10) {
      setState(() => _phoneError = 'Phone number must be exactly 10 digits');
      isValid = false;
    }

    if (!isValid) return; // Stop if validation fails

    setState(() => _isSaving = true);
    
    try {
      await _settingsService.updateUserProfile(
        fullName: _nameController.text,
        phone: _phoneController.text,
      );

      _showSnackBar('Profile updated successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('Error updating profile: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildAccountInfoCard(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Top right buttons are deliberately removed for Teacher role
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('Manage your account settings and preferences', style: TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildAccountInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          
          // Editable Full Name with validation
          _buildTextField('Full Name', 'Enter your full name', _nameController, false, errorText: _nameError),
          const SizedBox(height: 20),
          
          // Read-only Email
          _buildTextField('Email Address', 'Enter your email', _emailController, true),
          const SizedBox(height: 20),
          
          // Editable Phone Number with +63 visually locked, limited to exactly 10 digits, with validation
          _buildTextField('Phone Number', '912 345 6789', _phoneController, false, prefixText: '+63 ', maxLength: 10, errorText: _phoneError),
          const SizedBox(height: 30),
          
          // Save Button with Loading State
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _updateUserData,
            icon: _isSaving 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save, color: Colors.white, size: 18),
            label: Text(_isSaving ? 'Saving...' : 'Save Changes', style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // Dynamic TextField Builder supporting readOnly, prefixText, input validation, and formatters
  Widget _buildTextField(String label, String placeholder, TextEditingController controller, bool isReadOnly, {String? prefixText, int? maxLength, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13)),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500), 
          child: TextField(
            controller: controller,
            readOnly: isReadOnly,
            keyboardType: prefixText != null ? TextInputType.phone : TextInputType.text,
            
            inputFormatters: maxLength != null 
                ? [LengthLimitingTextInputFormatter(maxLength), FilteringTextInputFormatter.digitsOnly] 
                : null,
                
            style: TextStyle(color: isReadOnly ? Colors.black54 : Colors.black87),
            onChanged: (val) {
              // Clear the error immediately as the user starts typing again
              if (errorText != null) setState(() {}); 
            },
            decoration: InputDecoration(
              errorText: errorText, // Displays red validation text
              prefixText: prefixText, 
              prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.black54),
              filled: true,
              fillColor: isReadOnly ? Colors.grey.shade200 : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryGreen)),
            ),
          ),
        ),
      ],
    );
  }
}