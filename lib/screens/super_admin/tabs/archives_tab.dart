import 'package:flutter/material.dart';

class ArchivesTab extends StatefulWidget {
  const ArchivesTab({super.key});

  @override
  State<ArchivesTab> createState() => _ArchivesTabState();
}

class _ArchivesTabState extends State<ArchivesTab> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color cardBg = Colors.white;

  String _selectedType = 'All Types';
  String _selectedReason = 'All Reasons';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildStatCards(),
          const SizedBox(height: 30),
          _buildAlgorithmInfoCards(),
          const SizedBox(height: 30),
          _buildArchivedTableSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Archived Records', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('View and manage automatically archived student records', style: TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(child: _statCard('Total Archived', '32')),
        const SizedBox(width: 20),
        Expanded(child: _statCard('Graduated', '7')),
        const SizedBox(width: 20),
        Expanded(child: _statCard('Transferred', '123')),
        const SizedBox(width: 20),
        Expanded(child: _statCard('This Year', '52')),
      ],
    );
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
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 10),
          Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAlgorithmInfoCards() {
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
          const Text('Automatic Archiving Algorithm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoCard('Retention Period', Icons.calendar_today, Colors.blue.shade50, Colors.blue.shade700, ['Records are automatically archived after:', '• Graduated students: After 3 years', '• Transferred students: After 2 years', '• Inactive records: After 5 years'])),
              const SizedBox(width: 15),
              Expanded(child: _infoCard('Archive Process', Icons.archive_outlined, Colors.green.shade50, Colors.green.shade700, ['Automated workflow:', '• Daily scan at midnight', '• Identify eligible records', '• Secure data transfer', '• Generate archive report'])),
              const SizedBox(width: 15),
              Expanded(child: _infoCard('Data Recovery', Icons.restore, Colors.cyan.shade50, Colors.cyan.shade700, ['Archived records can be:', '• Retrieved anytime', '• Restored to active status', '• Exported for backup', '• Permanently deleted'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, IconData icon, Color bgColor, Color iconColor, List<String> details) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 15),
          ...details.map((text) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(text, style: TextStyle(color: iconColor.withOpacity(0.8), fontSize: 11, height: 1.4)),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildArchivedTableSection() {
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
          const Text('Archived Records', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or student number....',
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
              const SizedBox(width: 15),
              _buildDropdown(value: _selectedType, items: ['All Types', 'Student', 'Document'], onChanged: (val) => setState(() => _selectedType = val!)),
              const SizedBox(width: 15),
              _buildDropdown(value: _selectedReason, items: ['All Reasons', 'Graduated', 'Transferred', 'Inactive'], onChanged: (val) => setState(() => _selectedReason = val!)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
              dataRowMinHeight: 50,
              dataRowMaxHeight: 50,
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
                _buildDataRow('2020-045', 'Carlos Ramos Fernandez', 'Grade 12', 'ABM-A', 'Graduated', 'Elena Fernandez'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(String id, String name, String grade, String section, String status, String guardian) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(fontSize: 12))),
      DataCell(Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
      DataCell(Text(grade, style: const TextStyle(fontSize: 12))),
      DataCell(Text(section, style: const TextStyle(fontSize: 12))),
      DataCell(Text(status, style: const TextStyle(fontSize: 12))),
      DataCell(Text(guardian, style: const TextStyle(fontSize: 12))),
      DataCell(IconButton(icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.black54), onPressed: () {})),
    ]);
  }
}