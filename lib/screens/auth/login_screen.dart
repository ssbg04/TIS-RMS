import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../super_admin/super_admin_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../teacher/teacher_dashboard.dart';

class TISRMSLoginScreen extends StatefulWidget {
  const TISRMSLoginScreen({super.key});

  @override
  State<TISRMSLoginScreen> createState() => _TISRMSLoginScreenState();
}

class _TISRMSLoginScreenState extends State<TISRMSLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  // Design System Colors [cite: 54, 58]
  final Color gradientStart = const Color(0xFFB2F89B);
  final Color gradientEnd = const Color(0xFF0F8241);
  final Color greenPanelColor = const Color(0xFF1C8248);
  final Color loginButtonColor = const Color(0xFF085F32);
  final Color inputFieldBackgroundColor = const Color(0xFFE5E5E5);

  @override
  void initState() {
    super.initState();
    _loadRememberMeState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- REMEMBER ME LOGIC ---
  Future<void> _loadRememberMeState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('saved_email') ?? '';
      }
    });
  }

  Future<void> _saveRememberMeState(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('saved_email', email);
    } else {
      await prefs.remove('saved_email');
    }
  }

  // --- LOGIN EXECUTION ---
  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() { _isLoading = true; });
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.'))
      );
      setState(() { _isLoading = false; });
      return;
    }

    // Attempt Firebase Login [cite: 268]
    final userData = await AuthService.login(email, password);

    if (userData != null) {
      // Save Remember Me preference
      await _saveRememberMeState(email);

      final role = userData['role'];
      if (mounted) {
        if (role == 'super_admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SuperAdminDashboard()));
        } else if (role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
        } else if (role == 'teacher') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TeacherDashboard()));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please check your credentials.'), backgroundColor: Colors.red)
        );
      }
    }
    if (mounted) setState(() { _isLoading = false; });
  }

  // --- RESPONSIVE UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [gradientStart, gradientEnd]),
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Switch to mobile layout if screen is narrower than 800px
              bool isMobile = constraints.maxWidth < 800;

              return Container(
                width: isMobile ? constraints.maxWidth * 0.9 : constraints.maxWidth * 0.8,
                height: isMobile ? constraints.maxHeight * 0.9 : constraints.maxHeight * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 5))],
                ),
                clipBehavior: Clip.antiAlias, // Ensures the corners stay rounded
                child: isMobile 
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildGreenPanel(isMobile: true),
                          _buildLoginForm(isMobile: true),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(flex: 1, child: _buildGreenPanel(isMobile: false)),
                        Expanded(flex: 1, child: _buildLoginForm(isMobile: false)),
                      ],
                    ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildGreenPanel({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 30 : 20),
      color: greenPanelColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Image.asset('assets/images/logo.png', width: isMobile ? 80 : 120, height: isMobile ? 80 : 120, errorBuilder: (context, error, stackTrace) => Icon(Icons.school, color: Colors.amber, size: isMobile ? 80 : 120)),
          const SizedBox(height: 20),
          Text("Talisay Integrated School", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold)), // [cite: 57]
          Text("TIAONG, QUEZON", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14)), // [cite: 57]
          SizedBox(height: isMobile ? 20 : 30),
          Text("Records Management System", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)), // [cite: 57]
          Text("Secure Academic Records Database System", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isMobile ? 10 : 12)), // [cite: 57]
        ],
      ),
    );
  }

  Widget _buildLoginForm({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 30 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text("Login", style: TextStyle(color: Color(0xFF0F8241), fontSize: 36, fontWeight: FontWeight.bold))),
          const SizedBox(height: 30),
          
          const Text("Email Address:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: _emailController,
            textInputAction: TextInputAction.next, // Moves to next field on "Enter"
            decoration: InputDecoration(
              hintText: "Enter your email...",
              filled: true, fillColor: inputFieldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
          
          const SizedBox(height: 15),
          const Text("Password:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done, 
            onFieldSubmitted: (_) => _handleLogin(), // TRIGGERS LOGIN ON "ENTER"
            decoration: InputDecoration(
              hintText: "Enter your password...",
              filled: true, fillColor: inputFieldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
          
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(value: _rememberMe, onChanged: (val) => setState(() => _rememberMe = val!), activeColor: loginButtonColor),
                  const Text("Remember Me"),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text("Forget Password?", style: TextStyle(color: Colors.black))),
            ],
          ),
          
          const SizedBox(height: 30),
          Center(
            child: _isLoading 
            ? const CircularProgressIndicator()
            : ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: loginButtonColor, 
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
              ),
              child: const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}