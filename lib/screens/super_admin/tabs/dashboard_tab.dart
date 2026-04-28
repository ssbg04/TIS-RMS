import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  final Color cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Detect screen width for responsive layout
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20.0 : 30.0), // Adapt padding for mobile
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildStatCards(isMobile),
          const SizedBox(height: 30),
          
          // Responsive layout for the main content area
          if (isMobile)
            Column(
              children: [
                _buildRecentActivities(),
                const SizedBox(height: 20),
                _buildPendingTasks(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildRecentActivities()),
                const SizedBox(width: 30),
                Expanded(flex: 2, child: _buildPendingTasks()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome to Academic Records System', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('Talisay Integrated High School - School Year 2024-2025', style: TextStyle(color: Colors.black54)),
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
              Expanded(child: _statCard('Total Students', '32')),
              const SizedBox(width: 15),
              Expanded(child: _statCard('Document Processed', '7')),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _statCard('Archived Records', '123')),
              const SizedBox(width: 15),
              Expanded(child: _statCard('Active Records', '52')),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _statCard('Total Students', '32')),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Document Processed', '7')),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Archived Records', '123')),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Active Records', '52')),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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

  Widget _buildRecentActivities() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _activityItem('New student record added', 'Sofia Torres Villanueva', '2 hours ago'),
          _activityItem('Document verified', 'Maria Santos Cruz', '4 hours ago'),
          _activityItem('Record archived', 'Carlos Ramos Fernandez', '1 day ago', isLast: true),
        ],
      ),
    );
  }

  Widget _activityItem(String title, String subtitle, String time, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 2, height: 40, color: Colors.grey.shade300, margin: const EdgeInsets.only(right: 15, top: 5)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                Text(time, style: const TextStyle(color: Colors.black38, fontSize: 12)),
                if (!isLast) const Divider(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTasks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pending Tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _taskItem('Verify 12 pending documents', '12 items', 'High', Colors.red),
          _taskItem('Update 8 student records', '8 items', 'Medium', Colors.amber),
          _taskItem('Archive graduated students records', '8 items', 'Low', Colors.blue),
        ],
      ),
    );
  }

  Widget _taskItem(String title, String subtitle, String priority, Color priorityColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.error_outline, color: priorityColor, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: priorityColor.withOpacity(0.2), borderRadius: BorderRadius.circular(5)),
                child: Text(priority, style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
}