import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/login_screen.dart'; 

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color cardBg = Colors.white;

  // Controllers to hold the text data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

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

  // --- 1. FETCH DATA FROM FIREBASE ---
  Future<void> _loadUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Fetch the document from the 'users' collection using the UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          
          // Handle the phone number conversion for the UI
          String rawPhone = data['phone'] ?? '';
          String displayPhone = rawPhone;
          
          // If it's stored as 09xx, strip the 0 so it sits nicely next to the +63
          if (rawPhone.startsWith('0')) {
            displayPhone = rawPhone.substring(1);
          } else if (rawPhone.startsWith('+63')) {
            displayPhone = rawPhone.substring(3).trim(); 
          }

          setState(() {
            _nameController.text = data['full_name'] ?? '';
            _emailController.text = data['email'] ?? currentUser.email ?? '';
            _phoneController.text = displayPhone; 
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  // --- 2. UPDATE DATA IN FIREBASE ---
  Future<void> _updateUserData() async {
    setState(() => _isSaving = true);
    
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        
        // Take the 9xx number from the UI and format it back to 09xx for the database
        String formattedPhoneToSave = _phoneController.text.trim();
        if (formattedPhoneToSave.startsWith('9') && formattedPhoneToSave.length == 10) {
          formattedPhoneToSave = '0$formattedPhoneToSave';
        }

        // Update ONLY the full_name and phone fields
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'full_name': _nameController.text.trim(),
          'phone': formattedPhoneToSave, // Saves as 09xx safely to the cloud
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          _buildLogoutCard(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          
          // Editable Full Name
          _buildTextField('Full Name', 'Enter your full name', _nameController, false),
          const SizedBox(height: 20),
          
          // Read-only Email
          _buildTextField('Email Address', 'Enter your email', _emailController, true),
          const SizedBox(height: 20),
          
          // Editable Phone Number with +63 visually locked inside the box
          _buildTextField('Phone Number', '912 345 6789', _phoneController, false, prefixText: '+63 ', maxLength: 11),
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

  // Dynamic TextField Builder supporting readOnly and prefixText
  Widget _buildTextField(String label, String placeholder, TextEditingController controller, bool isReadOnly, {String? prefixText, int? maxLength}) {
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
            
            // ✅ THIS ENFORCES THE LIMIT WITHOUT SHOWING AN UGLY CHARACTER COUNTER
            inputFormatters: maxLength != null 
                ? [LengthLimitingTextInputFormatter(maxLength), FilteringTextInputFormatter.digitsOnly] 
                : null,
                
            style: TextStyle(color: isReadOnly ? Colors.black54 : Colors.black87),
            decoration: InputDecoration(
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

  Widget _buildLogoutCard(BuildContext context) {
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
          const Text('Logout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Are you sure you want to logout from the system?', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TISRMSLoginScreen()));
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red, size: 18),
            label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              elevation: 0,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}