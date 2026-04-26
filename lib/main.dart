import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'firebase_options.dart'; 

import 'screens/auth/login_screen.dart';
import 'screens/super_admin/super_admin_dashboard.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TISRMSApp());
}

class TISRMSApp extends StatelessWidget {
  const TISRMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIS_RMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F8241)),
        useMaterial3: true,
      ),
      // Automatically route user based on their active Firebase Session
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If Firebase is checking...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          // If the user is actively logged in, bypass the login screen
          if (snapshot.hasData && snapshot.data != null) {
            // Note: In a fully complete app, you'd check Firestore here to see if 
            // they are a Teacher, Admin, or Super Admin before routing.
            // For now, we route directly to the Super Admin Dashboard.
            return const SuperAdminDashboard();
          }

          // Otherwise, show the Login Screen
          return const TISRMSLoginScreen();
        },
      ),
    );
  }
}