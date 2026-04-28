import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- FETCH USER PROFILE ---
  Future<Map<String, dynamic>?> getUserProfile() async {
    final User? currentUser = _auth.currentUser;
    
    if (currentUser != null) {
      DocumentSnapshot userDoc = await _db.collection('users').doc(currentUser.uid).get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        // Include the auth email as a fallback if the document lacks it
        data['auth_email'] = currentUser.email; 
        return data;
      }
    }
    return null;
  }

  // --- UPDATE USER PROFILE ---
  Future<void> updateUserProfile({required String fullName, required String phone}) async {
    final User? currentUser = _auth.currentUser;
    
    if (currentUser != null) {
      // Safely format the 10-digit UI phone number back to 11-digit database format (09xx)
      String formattedPhoneToSave = phone.trim();
      if (formattedPhoneToSave.startsWith('9') && formattedPhoneToSave.length == 10) {
        formattedPhoneToSave = '0$formattedPhoneToSave';
      }

      await _db.collection('users').doc(currentUser.uid).update({
        'full_name': fullName.trim(),
        'phone': formattedPhoneToSave,
      });
    } else {
      throw Exception('No user currently logged in.');
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
  }
}