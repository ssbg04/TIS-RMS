import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class UserFetchResult {
  final List<DocumentSnapshot> documents;
  final bool hasMore;
  
  UserFetchResult({required this.documents, required this.hasMore});
}

class UserManagementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final int _documentLimit = 10;

  // --- PAGINATED FETCH LOGIC ---
  Future<UserFetchResult> fetchUsers({
    DocumentSnapshot? lastDocument,
    String searchQuery = '',
    String roleFilter = 'All Roles',
  }) async {
    Query query = _db.collection('users').orderBy('full_name');

    if (roleFilter != 'All Roles') {
      query = query.where('role', isEqualTo: roleFilter);
    }

    if (searchQuery.isNotEmpty) {
      query = query.where('full_name', isGreaterThanOrEqualTo: searchQuery)
                   .where('full_name', isLessThan: '$searchQuery\uf8ff');
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(_documentLimit);

    QuerySnapshot snapshot = await query.get();

    bool hasMore = snapshot.docs.length == _documentLimit;

    return UserFetchResult(
      documents: snapshot.docs,
      hasMore: hasMore,
    );
  }

  // --- DELETE USER LOGIC ---
  Future<void> deleteUser(String docId) async {
    await _db.collection('users').doc(docId).delete();
  }

  // --- ADD NEW USER LOGIC ---
  Future<void> createNewUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    // Initialize secondary app to avoid logging out the Super Admin
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: Firebase.app().options,
    );

    try {
      // Create user in Auth
      UserCredential newCred = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save profile to Firestore
      if (newCred.user != null) {
        await _db.collection('users').doc(newCred.user!.uid).set({
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'role': role,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    } finally {
      // Always ensure the secondary app is deleted even if it fails
      await secondaryApp.delete();
    }
  }
}