import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async'; // Needed for Search Debouncing

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color cardBg = Colors.white;

  String _searchQuery = '';
  String _selectedFilter = 'All Roles';
  bool _isAddingUser = false;

  // --- PAGINATION VARIABLES ---
  List<DocumentSnapshot> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _documentLimit = 10; // Number of users to fetch per page
  DocumentSnapshot? _lastDocument;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Fetch the first batch of users when the screen loads
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // --- PAGINATION LOGIC ---
  Future<void> _fetchUsers({bool refresh = false}) async {
    if (_isLoading) return;

    // If refreshing (e.g., searching or changing roles), clear the current list
    if (refresh) {
      setState(() {
        _lastDocument = null;
        _users.clear();
        _hasMore = true;
      });
    }

    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      // 1. Base Query: Order alphabetically
      Query query = FirebaseFirestore.instance.collection('users').orderBy('full_name');

      // 2. Filter by Role
      if (_selectedFilter != 'All Roles') {
        query = query.where('role', isEqualTo: _selectedFilter);
      }

      // 3. Search by Name (Prefix Search)
      if (_searchQuery.isNotEmpty) {
        query = query.where('full_name', isGreaterThanOrEqualTo: _searchQuery)
                     .where('full_name', isLessThan: '$_searchQuery\uf8ff');
      }

      // 4. Start after the last document for pagination
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      // 5. Limit the results to our chunk size (e.g., 10)
      query = query.limit(_documentLimit);

      QuerySnapshot snapshot = await query.get();

      // If we got fewer documents than our limit, there are no more left in the database
      if (snapshot.docs.length < _documentLimit) {
        _hasMore = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _users.addAll(snapshot.docs);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching users: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildUserTableSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 15,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('View and manage user accounts and information.', style: TextStyle(color: Colors.black54)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddUserDialog(context),
          icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
          label: const Text('Add User', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTableSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 15,
            children: [
              const Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 250),
                    height: 35,
                    child: TextField(
                      // DEBOUNCE SEARCH: Waits 500ms after you stop typing to fetch from Firebase
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          setState(() => _searchQuery = value);
                          _fetchUsers(refresh: true); // Reset pagination and fetch new search results
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by exact name...',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                  ),
                  Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                        onChanged: (String? newValue) {
                          setState(() => _selectedFilter = newValue!);
                          _fetchUsers(refresh: true); // Reset pagination and filter by role
                        },
                        items: <String>['All Roles', 'admin', 'teacher'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value == 'All Roles' ? value : (value == 'admin' ? 'Admin' : 'Teacher')),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- PAGINATED DATA TABLE ---
          if (_users.isEmpty && !_isLoading)
            const Padding(padding: EdgeInsets.all(20), child: Text("No users found.", style: TextStyle(color: Colors.grey)))
          else
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                  dataRowMinHeight: 50,
                  dataRowMaxHeight: 50,
                  horizontalMargin: 10,
                  columns: const [
                    DataColumn(label: Text('UID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: _users.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final shortUid = doc.id.substring(0, 6).toUpperCase(); 
                    return _buildDataRow(
                      shortUid,
                      data['full_name'] ?? 'No Name',
                      data['email'] ?? 'No Email',
                      data['phone'] ?? 'N/A',
                      data['role'] ?? 'Unknown',
                      doc.id,
                    );
                  }).toList(),
                ),
              ),
            ),
            
          // --- LOAD MORE BUTTON ---
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
          else if (_hasMore && _users.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: TextButton.icon(
                  onPressed: () => _fetchUsers(refresh: false),
                  icon: const Icon(Icons.expand_more, size: 18),
                  label: const Text('Load More Users'),
                  style: TextButton.styleFrom(foregroundColor: primaryGreen),
                ),
              ),
            )
          else if (!_hasMore && _users.isNotEmpty)
             const Center(child: Padding(padding: EdgeInsets.only(top: 20.0), child: Text("End of list.", style: TextStyle(color: Colors.grey, fontSize: 12)))),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String uid, String name, String email, String phone, String role, String fullDocId) {
    String displayRole = role == 'super_admin' ? 'Super Admin' : (role == 'admin' ? 'Admin' : 'Teacher');
    
    return DataRow(
      cells: [
        DataCell(Text(uid, style: const TextStyle(fontSize: 12, color: Colors.black54))),
        DataCell(Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        DataCell(Text(email, style: const TextStyle(fontSize: 12))),
        DataCell(Text(phone, style: const TextStyle(fontSize: 12))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'admin' ? Colors.blue.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(5)
            ),
            child: Text(displayRole, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: role == 'admin' ? Colors.blue.shade700 : Colors.green.shade700)),
          )
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                onPressed: () => _deleteUser(fullDocId, name),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: "Delete User Record",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- DELETE USER LOGIC ---
  Future<void> _deleteUser(String docId, String name) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to remove $name from the database? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete')
          ),
        ],
      )
    ) ?? false;

    if (confirm) {
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();
      
      // Update UI locally without doing a full refresh
      setState(() {
        _users.removeWhere((doc) => doc.id == docId);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name has been removed.'), backgroundColor: Colors.red));
      }
    }
  }

  // --- ADD NEW USER (SECONDARY FIREBASE APP WORKAROUND) ---
  void _showAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'teacher';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Register New User'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
                      const SizedBox(height: 15),
                      TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
                      const SizedBox(height: 15),
                      
                      TextField(
                        controller: phoneCtrl, 
                        keyboardType: TextInputType.phone, 
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(11),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (09xx...)', 
                          border: OutlineInputBorder(),
                        )
                      ),
                      
                      const SizedBox(height: 15),
                      TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Temporary Password (Min 6 chars)', border: OutlineInputBorder())),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(labelText: 'Assign Role', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (val) => setStateDialog(() => selectedRole = val!),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isAddingUser ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: _isAddingUser ? null : () async {
                    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields. Password must be 6+ chars.'), backgroundColor: Colors.orange));
                      return;
                    }

                    if (phoneCtrl.text.length != 11 || !phoneCtrl.text.startsWith('09')) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number must be 11 digits starting with 09.'), backgroundColor: Colors.orange));
                      return;
                    }

                    setStateDialog(() => _isAddingUser = true);

                    try {
                      FirebaseApp secondaryApp = await Firebase.initializeApp(
                        name: 'SecondaryApp',
                        options: Firebase.app().options,
                      );

                      UserCredential newCred = await FirebaseAuth.instanceFor(app: secondaryApp)
                          .createUserWithEmailAndPassword(email: emailCtrl.text.trim(), password: passCtrl.text.trim());

                      if (newCred.user != null) {
                        await FirebaseFirestore.instance.collection('users').doc(newCred.user!.uid).set({
                          'full_name': nameCtrl.text.trim(),
                          'email': emailCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                          'role': selectedRole,
                          'created_at': FieldValue.serverTimestamp(),
                        });
                      }

                      await secondaryApp.delete();

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${nameCtrl.text} registered successfully!'), backgroundColor: Colors.green));
                        // REFRESH THE TABLE TO SHOW THE NEW USER
                        _fetchUsers(refresh: true);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                    } finally {
                      setStateDialog(() => _isAddingUser = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                  child: _isAddingUser 
                    ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Create User', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }
}