import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      // 1. Log the user in using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. If successful, get their unique UID
      String uid = userCredential.user!.uid;

      // 3. Fetch their profile data and role from the 'users' Firestore collection
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print('User document does not exist in Firestore.');
        return null;
      }
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}