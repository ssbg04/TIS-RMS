import 'package:flutter/material.dart';

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color cardBg = Colors.white;
  
  String _selectedStatus = 'All Status';

  @override
  Widget build(BuildContext context) {
    // Detect screen width for responsive layout
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20.0 : 30.0), // Smaller padding on mobile
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildStatCards(isMobile),
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

  Widget _buildStatCards(bool isMobile) {
    // 2x2 Grid for mobile, Row of 4 for desktop
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard('No of Student Records', '5')),
              const SizedBox(width: 15),
              Expanded(child: _statCard('Active Students', '4')),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _statCard('Graduated', '1')),
              const SizedBox(width: 15),
              Expanded(child: _statCard('Transferred/ Dropped', '0')),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _statCard('No of Student Records', '5')),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Active Students', '4')),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Graduated', '1')),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Transferred/ Dropped', '0')),
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
          // Top Row: Title and Add Button (Responsive Wrap)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 15,
            children: [
              const Text('All Students', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement Add Student logic
                },
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
          
          // Second Row: Search and Filter (Responsive Wrap)
          Wrap(
            spacing: 15,
            runSpacing: 15,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 350), // Allows shrinking on very small phones
                height: 35,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or student number....',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                    items: <String>['All Status', 'Active', 'Graduated', 'Dropped']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // The Data Table wrapped in a Horizontal ScrollView for mobile screens
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
                rows: [
                  _buildDataRow('2024-001', 'Maria Santos Cruz', 'Grade 11', 'STEM-A', 'Active', 'Juan Cruz'),
                  _buildDataRow('2024-002', 'Juan Reyes Garcia', 'Grade 10', 'Diamond', 'Active', 'Rosa Garcia'),
                  _buildDataRow('2024-003', 'Ana Lopez Mendoza', 'Grade 11', 'STEM-A', 'Active', 'Pedro Mendoza'),
                  _buildDataRow('2020-045', 'Carlos Ramos Fernandez', 'Grade 12', 'ABM-A', 'Graduated', 'Elena Fernandez'),
                  _buildDataRow('2024-004', 'Sofia Torres Villanueva', 'Grade 10', 'Diamond', 'Active', 'Miguel Villanueva'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String id, String name, String grade, String section, String status, String guardian) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontSize: 12))),
        DataCell(Text(name, style: const TextStyle(fontSize: 12))),
        DataCell(Text(grade, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        DataCell(Text(section, style: const TextStyle(fontSize: 12))),
        DataCell(Text(status, style: const TextStyle(fontSize: 12))),
        DataCell(Text(guardian, style: const TextStyle(fontSize: 12))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.black54),
                onPressed: () {},
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.only(right: 8),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black54),
                onPressed: () {},
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }
}