import 'package:flutter/material.dart';

class DocumentsTab extends StatefulWidget {
  const DocumentsTab({super.key});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color cardBg = Colors.white;
  
  String _selectedType = 'All Types';
  String _selectedStatus = 'All Status';

  @override
  Widget build(BuildContext context) {
    // Detect screen width for responsive layout
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20.0 : 30.0), // Smaller padding on phones
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildStatCards(isMobile),
          const SizedBox(height: 30),
          _buildDocumentTableSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Replaced Row with Wrap so the Print button drops down on small screens
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 15,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Document Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Manage and verify student enrollment documents', style: TextStyle(color: Colors.black54)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement Print Logic
          },
          icon: const Icon(Icons.print_outlined, color: Colors.white, size: 18),
          label: const Text('Print Documents', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
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
              Expanded(child: _statCard('Total Documents', '5', Icons.description, Colors.blue.shade700)),
              const SizedBox(width: 15),
              Expanded(child: _statCard('Verified', '4', Icons.check_circle, Colors.green)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _statCard('Pending Review', '1', Icons.access_time_filled, Colors.orange)),
              const SizedBox(width: 15),
              Expanded(child: _statCard('Rejected', '0', Icons.cancel, Colors.red)),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _statCard('Total Documents', '5', Icons.description, Colors.blue.shade700)),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Verified', '4', Icons.check_circle, Colors.green)),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Pending Review', '1', Icons.access_time_filled, Colors.orange)),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Rejected', '0', Icons.cancel, Colors.red)),
        ],
      );
    }
  }

  Widget _statCard(String title, String count, IconData icon, Color iconColor) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13), overflow: TextOverflow.ellipsis)),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDocumentTableSection() {
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
          // Top Row: Title and Upload Button (Responsive Wrap)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 15,
            children: [
              const Text('All Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement Upload Document logic
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Upload Documents', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Second Row: Search and Filters (Responsive Wrap)
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
                    hintText: 'Search students, documents, or records...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18),
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
              _buildDropdown(
                value: _selectedType,
                items: ['All Types', 'Birth Certificate', 'Report Card', 'Medical Certificate', 'Good Moral'],
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              _buildDropdown(
                value: _selectedStatus,
                items: ['All Status', 'Verified', 'Pending', 'Rejected'],
                onChanged: (val) => setState(() => _selectedStatus = val!),
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
                  DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Document Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('File Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Upload Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
                rows: [
                  _buildDataRow('Maria Santos Cruz', 'Birth Certificate', 'birth_cert_maria_cruz.pdf', '2024-05-15', '2.3 MB', 'Verified'),
                  _buildDataRow('Maria Santos Cruz', 'Report Card', 'report_card_grade10.pdf', '2024-05-16', '1.8 MB', 'Verified'),
                  _buildDataRow('Juan Reyes Garcia', 'Birth Certificate', 'birth_cert_juan_garcia.pdf', '2024-05-18', '2.1 MB', 'Verified'),
                  _buildDataRow('Juan Reyes Garcia', 'Medical Certificate', 'medical_cert_garcia.pdf', '2024-05-18', '1.5 MB', 'Pending'),
                  _buildDataRow('Ana Lopez Mendoza', 'Good Moral', 'good_moral_ana.pdf', '2024-05-20', '1.2 MB', 'Verified'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(String name, String type, String fileName, String date, String size, String status) {
    return DataRow(
      cells: [
        DataCell(Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 5),
            Text(type, style: const TextStyle(fontSize: 12)),
          ],
        )),
        DataCell(Text(fileName, style: const TextStyle(fontSize: 12, color: Colors.black54))),
        DataCell(Text(date, style: const TextStyle(fontSize: 12))),
        DataCell(Text(size, style: const TextStyle(fontSize: 12))),
        DataCell(_buildStatusPill(status)),
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
                icon: const Icon(Icons.download_outlined, size: 18, color: Colors.black54),
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

  // Helper widget to create the colored status pills
  Widget _buildStatusPill(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    if (status == 'Verified') {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      icon = Icons.check_circle_outline;
    } else if (status == 'Pending') {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.access_time;
    } else {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}