import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

// We can reuse the exact same tabs we already built!
import '../super_admin/tabs/dashboard_tab.dart';
import '../super_admin/tabs/students_tab.dart';
import '../super_admin/tabs/documents_tab.dart';
import '../super_admin/tabs/archives_tab.dart';
import '../super_admin/tabs/reports_tab.dart';
import '../super_admin/tabs/settings_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color lightBg = const Color(0xFFEAF1EB); 
  final Color activeNavBg = const Color(0xFFD3E7D9); 

  int _selectedIndex = 0; 

  // Map the sidebar indexes to the actual tab files (Excluding User Management)
  final List<Widget> _pages = [
    const DashboardTab(), // Index 0
    const StudentsTab(),  // Index 1
    const DocumentsTab(), // Index 2
    const ArchivesTab(),  // Index 3
    const ReportsTab(),   // Index 4
    const SettingsTab(),  // Index 5
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: Row(
        children: [
          // 1. LEFT SIDEBAR (Admin Shell)
          _buildSidebar(),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS FOR THE SHELL ---

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: primaryGreen,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 40, height: 40, errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, color: Colors.amber, size: 40)),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TIS Records', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Academic System', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 10),
          
          // Navigation items minus User Management
          _buildNavItem(0, Icons.dashboard, 'Dashboard'),
          _buildNavItem(1, Icons.people, 'Students'),
          _buildNavItem(2, Icons.folder, 'Documents'),
          _buildNavItem(3, Icons.archive, 'Archives'),
          _buildNavItem(4, Icons.insert_chart, 'Reports'),
          _buildNavItem(5, Icons.settings, 'Settings'),
          
          const Spacer(),
          
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: activeNavBg, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Talisay Integrated School', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),
                const Text('Secure Academic Records Database System', style: TextStyle(color: Colors.black54, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeNavBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? primaryGreen : Colors.white, size: 20),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(color: isActive ? primaryGreen : Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 400, height: 40,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search students, documents, or records...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          
          Row(
            children: [
              const Icon(Icons.notifications, color: Color(0xFF0F8241)),
              const SizedBox(width: 20),
              // Updated Role Text
              const Text('Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 15),
              InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TISRMSLoginScreen()));
                  }
                },
                child: const CircleAvatar(backgroundColor: Colors.black12, child: Icon(Icons.person, color: Color(0xFF0F8241))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}