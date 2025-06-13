import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyuser/authentication/login.dart';
import 'package:dailyuser/homepage.dart';
import 'package:dailyuser/CreateInventory/inventoryaccess.dart'; // Make sure this import is correct
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;

      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (doc.exists && doc.data()?['owner'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InventoryAccessPage()),
          );
        }
      } catch (e) {
        // Optional: handle errors
        debugPrint('Error fetching user data: $e');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F), // Navy Blue
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/inventa.png',
              width: 170,
              height: 170,
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
