import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../../services/user_management_service.dart';
import '../../../widgets/custom_modal.dart';

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color cardBg = Colors.white;

  final UserManagementService _userService = UserManagementService();

  String _searchQuery = '';
  String _selectedFilter = 'All Roles';
  bool _isAddingUser = false;

  // --- PAGINATION STATE ---
  List<DocumentSnapshot> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (_isLoading) return;

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
      // Call the external service instead of Firebase directly
      UserFetchResult result = await _userService.fetchUsers(
        lastDocument: _lastDocument,
        searchQuery: _searchQuery,
        roleFilter: _selectedFilter,
      );

      if (mounted) {
        setState(() {
          if (result.documents.isNotEmpty) {
            _lastDocument = result.documents.last;
            _users.addAll(result.documents);
          }
          _hasMore = result.hasMore;
        });
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error fetching users: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(String docId, String name) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to remove $name? This cannot be undone.'),
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
      try {
        await _userService.deleteUser(docId); // Call external service
        setState(() => _users.removeWhere((doc) => doc.id == docId));
        _showSnackBar('$name has been removed.', Colors.red);
      } catch (e) {
        _showSnackBar('Error deleting user: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
    }
  }

  // --- VALIDATION HELPER ---
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _showAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'teacher';
    
    // Track validation errors
    String? emailError;
    String? phoneError;
    String? passError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            
            // ✅ USING THE NEW CUSTOM MODAL MODULE
            return CustomModal(
              title: 'Add New User',
              isSaving: _isAddingUser,
              saveText: 'Save', // Matches the green button in your UI image
              
              // --- PASS YOUR STRICT VALIDATION LOGIC HERE ---
              onSave: () async {
                bool isValid = true;
                setStateDialog(() {
                  if (nameCtrl.text.trim().isEmpty) {
                    _showSnackBar('Full name is required.', Colors.orange);
                    isValid = false;
                  }
                  if (!_isValidEmail(emailCtrl.text.trim())) {
                    emailError = 'Please enter a valid email format';
                    isValid = false;
                  }
                  if (phoneCtrl.text.length != 11 || !phoneCtrl.text.startsWith('09')) {
                    phoneError = 'Must be 11 digits starting with 09';
                    isValid = false;
                  }
                  if (passCtrl.text.length < 6) {
                    passError = 'Password must be at least 6 characters';
                    isValid = false;
                  }
                });

                if (!isValid) return; // Stop if validation fails

                setStateDialog(() => _isAddingUser = true);

                try {
                  // Call external service instead of Firebase directly
                  await _userService.createNewUser(
                    fullName: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    password: passCtrl.text.trim(),
                    role: selectedRole,
                  );

                  if (mounted) {
                    Navigator.pop(context); // Closes the modal
                    _showSnackBar('${nameCtrl.text} registered successfully!', Colors.green);
                    _loadUsers(refresh: true); // Refresh list
                  }
                } catch (e) {
                  _showSnackBar('Error: $e', Colors.red);
                } finally {
                  setStateDialog(() => _isAddingUser = false);
                }
              },
              
              // --- FORM FIELDS STYLED TO MATCH FIGMA ---
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl, 
                    decoration: InputDecoration(
                      labelText: 'Full Name', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailCtrl, 
                    decoration: InputDecoration(
                      labelText: 'Email Address', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      errorText: emailError,
                    ),
                    onChanged: (_) => setStateDialog(() => emailError = null),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: phoneCtrl, 
                    keyboardType: TextInputType.phone, 
                    inputFormatters: [LengthLimitingTextInputFormatter(11), FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Phone Number (09xx...)', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      errorText: phoneError,
                    ),
                    onChanged: (_) => setStateDialog(() => phoneError = null),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passCtrl, 
                    obscureText: true, 
                    decoration: InputDecoration(
                      labelText: 'Temporary Password', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      errorText: passError,
                    ),
                    onChanged: (_) => setStateDialog(() => passError = null),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Assign Role', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (val) => setStateDialog(() => selectedRole = val!),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  // --- UI BUILDING CODE REMAINS THE SAME ---
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
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          setState(() => _searchQuery = value);
                          _loadUsers(refresh: true);
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
                          _loadUsers(refresh: true);
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
            
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
          else if (_hasMore && _users.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: TextButton.icon(
                  onPressed: () => _loadUsers(refresh: false),
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
}