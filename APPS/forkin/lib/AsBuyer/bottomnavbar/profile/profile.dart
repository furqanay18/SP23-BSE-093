import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forkin/AsSeller/becomeseller/introscreens.dart';
import 'package:forkin/AsSeller/becomeseller/appliedfor.dart';
import 'package:forkin/AsSeller/SellerPanel/sellerpanel.dart';
import 'package:forkin/AsBuyer/bottomnavbar/profile/editprofile.dart';
import 'package:forkin/Driver/applyfordriver.dart';
import 'package:forkin/Driver/driverpanel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forkin/main.dart';
import 'package:forkin/Admin/adminscreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<bool> checkIfDriver() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final data = doc.data();
      return data?['driver'] == true;
    }
    return false;
  }

  Future<bool> checkIfAdmin() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final data = doc.data();
      return data?['admin'] == true;
    }
    return false;
  }

  Future<String> getBecomeOwnerStatus() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final data = doc.data();
      return data?['becomeownerstatus'] ?? 'nowish';
    }
    return 'nowish';
  }

  void navigateAccordingToStatus(String status) {
    if (status == 'nowish') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AppIntroScreen()));
    } else if (status == 'wishing') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AppliedForScreen()));
    } else if (status == 'approved') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerPanelScreen()));
    }
  }

  Widget customCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(2, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepOrange, Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage("assets/useravatar.jpg"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.displayName ?? "No Name",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    user?.email ?? "No Email",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile Actions
            customCard(
              icon: Icons.edit,
              title: "Edit Information",
              color: Colors.amberAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),

            FutureBuilder<String>(
              future: getBecomeOwnerStatus(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator(color: Colors.orange);
                }

                final status = snapshot.data!;
                return customCard(
                  icon: status == 'approved' ? Icons.dashboard : Icons.storefront,
                  title: status == 'approved' ? "Seller Panel" : "Be a Seller",
                  color: Colors.orange,
                  onTap: () => navigateAccordingToStatus(status),
                );
              },
            ),

            customCard(
              icon: Icons.logout,
              title: "Logout",
              color: Colors.redAccent,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => WelcomeScreen()),
                      (route) => false,
                );
              },
            ),

            FutureBuilder<bool>(
              future: checkIfAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done || !(snapshot.data ?? false)) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    customCard(
                      icon: Icons.admin_panel_settings,
                      title: "Admin Panel",
                      color: Colors.deepPurpleAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PendingRestaurantsScreen()),
                        );
                      },
                    ),

                  ],
                );
              },
            ),
            FutureBuilder<bool>(
              future: checkIfDriver(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final isDriver = snapshot.data!;
                return customCard(
                  icon: isDriver ? Icons.delivery_dining : Icons.motorcycle,
                  title: isDriver ? "Driver Panel" : "Wanna Deliver?",
                  color: Colors.orangeAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => isDriver ? DriverPanelScreen() : ApplyForDriverScreen()),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
