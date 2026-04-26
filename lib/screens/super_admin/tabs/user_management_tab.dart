import 'package:flutter/material.dart';

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color cardBg = Colors.white;

  String _selectedFilter = 'Filter';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('View and manage the users accounts and informations.', style: TextStyle(color: Colors.black54)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement Add User logic or open the dialog we created earlier
          },
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
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title, Search, and Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  SizedBox(
                    width: 250,
                    height: 35,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFilter = newValue!;
                          });
                        },
                        items: <String>['Filter', 'Admin', 'Teacher']
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
            ],
          ),
          const SizedBox(height: 20),

          // The Data Table
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
              dataRowMinHeight: 50,
              dataRowMaxHeight: 50,
              horizontalMargin: 10,
              columns: const [
                DataColumn(label: Text('ID Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: [
                _buildDataRow('2024-001', 'Maria Santos Cruz', 'mariacruz@gmail.com', '09234561234', 'Admin'),
                _buildDataRow('2024-002', 'Andrew Bucod', 'andrew123@gmail.com', '09421215467', 'Teacher'),
                _buildDataRow('2024-003', 'Linda Walker', 'lindawalker3@gmail.com', '09555576789', 'Teacher'),
                _buildDataRow('2024-004', 'Luke Nickle', 'lukenickle@gmail.com', '09767612398', 'Teacher'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String id, String name, String email, String phone, String role) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontSize: 12))),
        DataCell(Text(name, style: const TextStyle(fontSize: 12))),
        DataCell(Text(email, style: const TextStyle(fontSize: 12))),
        DataCell(Text(phone, style: const TextStyle(fontSize: 12))),
        DataCell(Text(role, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
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