import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_top_bar.dart';
import '../auth/login_screen.dart';

// Import the shared tabs
import '../super_admin/tabs/dashboard_tab.dart';
import '../super_admin/tabs/students_tab.dart';
import '../super_admin/tabs/documents_tab.dart';

// Import the specific teacher settings tab
import 'tabs/teacher_settings_tab.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final Color primaryGreen = const Color(0xFF0F8241);
  final Color lightBg = const Color(0xFFEAF1EB); 
  final Color activeNavBg = const Color(0xFFD3E7D9); 

  int _selectedIndex = 0; 

  // Map the sidebar indexes to the 4 specific tabs for Teachers
  final List<Widget> _pages = [
    const DashboardTab(),        // Index 0
    const StudentsTab(),         // Index 1
    const DocumentsTab(),        // Index 2
    const TeacherSettingsTab(),  // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Switch to Mobile (Hamburger) View if screen is narrow
        bool isMobile = constraints.maxWidth < 850;

        return Scaffold(
          backgroundColor: lightBg,
          appBar: isMobile
              ? AppBar(
                  backgroundColor: primaryGreen,
                  title: const Text('TIS Records', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  iconTheme: const IconThemeData(color: Colors.white), 
                )
              : null,
          drawer: isMobile ? Drawer(child: _buildSidebar(isMobile, context)) : null,
          
          // ✅ SAFE AREA: Protects the main body from the phone's top notch
          body: SafeArea(
            child: isMobile
                ? Column(
                    children: [
                      CustomTopBar(isMobile: isMobile, roleName: 'Teacher'),
                      Expanded(child: _pages[_selectedIndex]),
                    ],
                  )
                : Row(
                    children: [
                      _buildSidebar(isMobile, context),
                      Expanded(
                        child: Column(
                          children: [
                            CustomTopBar(isMobile: isMobile, roleName: 'Teacher'),
                            Expanded(child: _pages[_selectedIndex]),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDERS FOR THE SHELL ---

  Widget _buildSidebar(bool isMobile, BuildContext context) {
    return Container(
      width: 250,
      color: primaryGreen,
      // ✅ SAFE AREA: Protects the sidebar content when it slides out on mobile
      child: SafeArea(
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
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Only the 4 requested Navigation items for Teachers
                  _buildNavItem(0, Icons.dashboard, 'Dashboard', isMobile, context),
                  _buildNavItem(1, Icons.people, 'Students', isMobile, context),
                  _buildNavItem(2, Icons.folder, 'Documents', isMobile, context),
                  _buildNavItem(3, Icons.settings, 'Settings', isMobile, context),
                ],
              ),
            ),
            
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
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title, bool isMobile, BuildContext context) {
    bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        // Automatically close the sliding drawer when a tab is clicked on mobile
        if (isMobile) {
          Navigator.pop(context);
        }
      },
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
}