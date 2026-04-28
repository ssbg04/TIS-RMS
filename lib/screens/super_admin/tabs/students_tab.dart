import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../widgets/custom_modal.dart';

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color cardBg = Colors.white;
  
  String _searchQuery = '';
  String _selectedStatus = 'All Status';
  
  bool _isAddingStudent = false;
  bool _isEditingStudent = false;

  // --- PAGINATION VARIABLES ---
  List<DocumentSnapshot> _students = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _documentLimit = 10; // Number of students to fetch per page
  DocumentSnapshot? _lastDocument;
  Timer? _debounce;

  // --- STATS VARIABLES ---
  int _totalStudents = 0;
  int _activeStudents = 0;
  int _graduatedStudents = 0;
  int _droppedStudents = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats(); // Fetch the numbers for the top cards
    _fetchStudents(); // Fetch the first 10 students
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // --- 1. FETCH AGGREGATE STATS ---
  Future<void> _fetchStats() async {
    try {
      final totalSnap = await FirebaseFirestore.instance.collection('students').count().get();
      final activeSnap = await FirebaseFirestore.instance.collection('students').where('status', isEqualTo: 'Active').count().get();
      final gradSnap = await FirebaseFirestore.instance.collection('students').where('status', isEqualTo: 'Graduated').count().get();
      final dropSnap = await FirebaseFirestore.instance.collection('students').where('status', isEqualTo: 'Dropped').count().get();

      if (mounted) {
        setState(() {
          _totalStudents = totalSnap.count ?? 0;
          _activeStudents = activeSnap.count ?? 0;
          _graduatedStudents = gradSnap.count ?? 0;
          _droppedStudents = dropSnap.count ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  // --- 2. PAGINATED FETCH LOGIC ---
  Future<void> _fetchStudents({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      setState(() {
        _lastDocument = null;
        _students.clear();
        _hasMore = true;
      });
    }

    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      // Base Query: Order alphabetically by name
      Query query = FirebaseFirestore.instance.collection('students').orderBy('full_name');

      // Filter by Status
      if (_selectedStatus != 'All Status') {
        query = query.where('status', isEqualTo: _selectedStatus);
      }

      // Search by Name (Prefix Search)
      if (_searchQuery.isNotEmpty) {
        query = query.where('full_name', isGreaterThanOrEqualTo: _searchQuery)
                     .where('full_name', isLessThan: '$_searchQuery\uf8ff');
      }

      // Start after the last document for pagination
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      // Limit results
      query = query.limit(_documentLimit);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.length < _documentLimit) {
        _hasMore = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _students.addAll(snapshot.docs);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching students: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20.0 : 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildStatCards(isMobile, _totalStudents, _activeStudents, _graduatedStudents, _droppedStudents),
          const SizedBox(height: 30),
          _buildStudentTableSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student Records', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('Manage and view all student information', style: TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildStatCards(bool isMobile, int total, int active, int graduated, int dropped) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard('No of Student Records', total.toString())),
              const SizedBox(width: 15),
              Expanded(child: _statCard('Active Students', active.toString())),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _statCard('Graduated', graduated.toString())),
              const SizedBox(width: 15),
              Expanded(child: _statCard('Transferred/ Dropped', dropped.toString())),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _statCard('No of Student Records', total.toString())),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Active Students', active.toString())),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Graduated', graduated.toString())),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Transferred/ Dropped', dropped.toString())),
        ],
      );
    }
  }

  Widget _statCard(String title, String count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStudentTableSection() {
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
              const Text('All Students', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAddStudentDialog(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Add Student', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 15,
            runSpacing: 15,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 350),
                height: 35,
                child: TextField(
                  // DEBOUNCE SEARCH: Waits 500ms after typing to fetch
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      setState(() => _searchQuery = value);
                      _fetchStudents(refresh: true);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by exact name...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                    onChanged: (String? newValue) {
                      setState(() => _selectedStatus = newValue!);
                      _fetchStudents(refresh: true);
                    },
                    items: <String>['All Status', 'Active', 'Graduated', 'Dropped'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- PAGINATED DATA TABLE ---
          if (_students.isEmpty && !_isLoading)
             const Padding(padding: EdgeInsets.all(20), child: Text("No student records found.", style: TextStyle(color: Colors.grey)))
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
                    DataColumn(label: Text('Student Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Grade Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Section', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Guardian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: _students.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildDataRow(doc.id, data);
                  }).toList(),
                ),
              ),
            ),

          // --- LOAD MORE BUTTON ---
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
          else if (_hasMore && _students.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: TextButton.icon(
                  onPressed: () => _fetchStudents(refresh: false),
                  icon: const Icon(Icons.expand_more, size: 18),
                  label: const Text('Load More Students'),
                  style: TextButton.styleFrom(foregroundColor: primaryGreen),
                ),
              ),
            )
          else if (!_hasMore && _students.isNotEmpty)
             const Center(child: Padding(padding: EdgeInsets.only(top: 20.0), child: Text("End of list.", style: TextStyle(color: Colors.grey, fontSize: 12)))),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String docId, Map<String, dynamic> data) {
    return DataRow(
      cells: [
        DataCell(Text(data['student_id'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
        DataCell(Text(data['full_name'] ?? 'Unknown', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        DataCell(Text(data['grade_level'] ?? '-', style: const TextStyle(fontSize: 12))),
        DataCell(Text(data['section'] ?? '-', style: const TextStyle(fontSize: 12))),
        DataCell(_buildStatusBadge(data['status'] ?? 'Active')),
        DataCell(Text(data['guardian_name'] ?? '-', style: const TextStyle(fontSize: 12))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // EDIT BUTTON
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                tooltip: "Edit Student",
                onPressed: () => _showEditStudentDialog(context, data, docId),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.only(right: 8),
              ),
              // DELETE BUTTON
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                tooltip: "Delete Student",
                onPressed: () => _deleteStudent(docId, data['full_name'] ?? 'Student'),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    if (status == 'Active') {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
    } else if (status == 'Graduated') {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
    } else {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(5)),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // --- DELETE STUDENT LOGIC ---
  Future<void> _deleteStudent(String docId, String name) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student?'),
        content: Text('Are you sure you want to remove $name from the database?'),
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
      await FirebaseFirestore.instance.collection('students').doc(docId).delete();
      
      setState(() {
        _students.removeWhere((doc) => doc.id == docId);
      });
      _fetchStats(); // Update numbers
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name has been removed.'), backgroundColor: Colors.red));
      }
    }
  }

  // --- ADD NEW STUDENT DIALOG USING CUSTOM MODAL ---
  void _showAddStudentDialog(BuildContext context) {
    final studentIdCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final sectionCtrl = TextEditingController();
    final guardianCtrl = TextEditingController();
    
    String selectedGrade = 'Grade 7';
    String selectedStatus = 'Active';

    // Track validation errors
    String? idError;
    String? nameError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            
            // ✅ USING THE REUSABLE CUSTOM MODAL
            return CustomModal(
              title: 'Add New Student',
              isSaving: _isAddingStudent,
              saveText: 'Save',
              
              // --- LOGIC MOVED TO onSave ---
              onSave: () async {
                bool isValid = true;
                
                setStateDialog(() {
                  if (studentIdCtrl.text.trim().isEmpty) {
                    idError = 'Student ID is required';
                    isValid = false;
                  }
                  if (nameCtrl.text.trim().isEmpty) {
                    nameError = 'Full name is required';
                    isValid = false;
                  }
                });

                if (!isValid) return; // Stop if validation fails

                setStateDialog(() => _isAddingStudent = true);

                try {
                  // Save directly to the students collection using 'student_id'
                  await FirebaseFirestore.instance.collection('students').add({
                    'student_id': studentIdCtrl.text.trim(),
                    'full_name': nameCtrl.text.trim(),
                    'grade_level': selectedGrade,
                    'section': sectionCtrl.text.trim(),
                    'guardian_name': guardianCtrl.text.trim(),
                    'status': selectedStatus,
                    'created_at': FieldValue.serverTimestamp(),
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${nameCtrl.text} added successfully!'), backgroundColor: Colors.green)
                    );
                    _fetchStats(); // Update dashboard numbers
                    _fetchStudents(refresh: true); // Refresh the table
                  }
                } catch (e) {
                  if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Error adding student: $e'), backgroundColor: Colors.red)
                     );
                  }
                } finally {
                  setStateDialog(() => _isAddingStudent = false);
                }
              },
              
              // --- UI FORM FIELDS STYLED LIKE FIGMA ---
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: studentIdCtrl, 
                    decoration: InputDecoration(
                      labelText: 'Student ID (e.g., 2024-001)', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      errorText: idError,
                    ),
                    onChanged: (_) => setStateDialog(() => idError = null),
                  ),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: nameCtrl, 
                    decoration: InputDecoration(
                      labelText: 'Full Name', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      errorText: nameError,
                    ),
                    onChanged: (_) => setStateDialog(() => nameError = null),
                  ),
                  const SizedBox(height: 15),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedGrade,
                          decoration: InputDecoration(
                            labelText: 'Grade Level', 
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          items: ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) => setStateDialog(() => selectedGrade = val!),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: sectionCtrl, 
                          decoration: InputDecoration(
                            labelText: 'Section', 
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          )
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: guardianCtrl, 
                    decoration: InputDecoration(
                      labelText: 'Guardian Name', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    )
                  ),
                  const SizedBox(height: 15),
                  
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Enrollment Status', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Graduated', child: Text('Graduated')),
                      DropdownMenuItem(value: 'Dropped', child: Text('Dropped')),
                    ],
                    onChanged: (val) => setStateDialog(() => selectedStatus = val!),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  // --- EDIT STUDENT DIALOG USING CUSTOM MODAL ---
  void _showEditStudentDialog(BuildContext context, Map<String, dynamic> studentData, String docId) {
    // Pre-fill the controllers with existing database data
    final studentIdCtrl = TextEditingController(text: studentData['student_id'] ?? '');
    final nameCtrl = TextEditingController(text: studentData['full_name'] ?? '');
    final sectionCtrl = TextEditingController(text: studentData['section'] ?? '');
    final guardianCtrl = TextEditingController(text: studentData['guardian_name'] ?? '');
    
    // Pre-fill dropdowns, falling back to defaults if null
    String selectedGrade = studentData['grade_level'] ?? 'Grade 7';
    String selectedStatus = studentData['status'] ?? 'Active';

    // Track validation errors
    String? idError;
    String? nameError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            
            // ✅ USING THE REUSABLE CUSTOM MODAL
            return CustomModal(
              title: 'Edit Student Profile',
              isSaving: _isEditingStudent,
              saveText: 'Update',
              
              // --- UPDATE LOGIC ---
              onSave: () async {
                bool isValid = true;
                
                setStateDialog(() {
                  if (studentIdCtrl.text.trim().isEmpty) {
                    idError = 'Student ID is required';
                    isValid = false;
                  }
                  if (nameCtrl.text.trim().isEmpty) {
                    nameError = 'Full name is required';
                    isValid = false;
                  }
                });

                if (!isValid) return; // Stop if validation fails

                setStateDialog(() => _isEditingStudent = true);

                try {
                  // Update the specific document in the students collection
                  await FirebaseFirestore.instance.collection('students').doc(docId).update({
                    'student_id': studentIdCtrl.text.trim(),
                    'full_name': nameCtrl.text.trim(),
                    'grade_level': selectedGrade,
                    'section': sectionCtrl.text.trim(),
                    'guardian_name': guardianCtrl.text.trim(),
                    'status': selectedStatus,
                    'updated_at': FieldValue.serverTimestamp(),
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${nameCtrl.text} updated successfully!'), backgroundColor: Colors.green)
                    );
                    _fetchStats(); // Update dashboard numbers in case status changed
                    _fetchStudents(refresh: true); // Refresh the table to show edits
                  }
                } catch (e) {
                  if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Error updating student: $e'), backgroundColor: Colors.red)
                     );
                  }
                } finally {
                  setStateDialog(() => _isEditingStudent = false);
                }
              },
              
              // --- UI FORM FIELDS STYLED LIKE FIGMA ---
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: studentIdCtrl, 
                    decoration: InputDecoration(
                      labelText: 'Student ID (e.g., 2024-001)', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      errorText: idError,
                    ),
                    onChanged: (_) => setStateDialog(() => idError = null),
                  ),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: nameCtrl, 
                    decoration: InputDecoration(
                      labelText: 'Full Name', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      errorText: nameError,
                    ),
                    onChanged: (_) => setStateDialog(() => nameError = null),
                  ),
                  const SizedBox(height: 15),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedGrade,
                          decoration: InputDecoration(
                            labelText: 'Grade Level', 
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          items: ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) => setStateDialog(() => selectedGrade = val!),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: sectionCtrl, 
                          decoration: InputDecoration(
                            labelText: 'Section', 
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          )
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: guardianCtrl, 
                    decoration: InputDecoration(
                      labelText: 'Guardian Name', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    )
                  ),
                  const SizedBox(height: 15),
                  
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Enrollment Status', 
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Graduated', child: Text('Graduated')),
                      DropdownMenuItem(value: 'Dropped', child: Text('Dropped')),
                    ],
                    onChanged: (val) => setStateDialog(() => selectedStatus = val!),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }
}