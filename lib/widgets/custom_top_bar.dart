import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/login_screen.dart'; // Ensure this path matches your project structure

class CustomTopBar extends StatefulWidget {
  final bool isMobile;
  final String roleName; // e.g., "Super Admin", "Admin", or "Teacher"

  const CustomTopBar({super.key, required this.isMobile, required this.roleName});

  @override
  State<CustomTopBar> createState() => _CustomTopBarState();
}

class _CustomTopBarState extends State<CustomTopBar> {
  String _userName = 'Loading...';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // The widget fetches its own data, removing the need for the dashboards to do it!
  Future<void> _fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) setState(() => _userEmail = user.email ?? '');
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() => _userName = doc.data()?['full_name'] ?? widget.roleName);
        }
      } catch (e) {
        if (mounted) setState(() => _userName = widget.roleName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 15 : 30, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Responsive Search Bar
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20), 
                border: Border.all(color: Colors.black12)
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 15),
          
          // Profile & Notifications
          Row(
            children: [
              if (!widget.isMobile) ...[
                const Icon(Icons.notifications, color: Color(0xFF0F8241)),
                const SizedBox(width: 15),
                // Displays the role passed from the parent dashboard
                Text(widget.roleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 15),
              ],
              
              // Upgraded Popup Menu
              PopupMenuButton<String>(
                tooltip: 'Account Menu', 
                offset: const Offset(0, 45), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (value) async {
                  if (value == 'logout') {
                    // Confirmation Dialog
                    bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true), 
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Logout')
                          ),
                        ],
                      )
                    ) ?? false;

                    if (confirm) {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TISRMSLoginScreen()));
                      }
                    }
                  }
                },
                itemBuilder: (BuildContext context) => [
                  // Non-Clickable Header
                  PopupMenuItem<String>(
                    enabled: false, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(_userEmail, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 10),
                        Text('Logout', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
                child: const CircleAvatar(backgroundColor: Colors.black12, child: Icon(Icons.person, color: Color(0xFF0F8241))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}