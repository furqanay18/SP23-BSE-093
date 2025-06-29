import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fork_it/AsSeller/becomeseller/introscreens.dart';
import 'package:fork_it/AsSeller/becomeseller/appliedfor.dart';
import 'package:fork_it/AsSeller/SellerPanel/sellerpanel.dart';
import 'package:fork_it/AsBuyer/bottomnavbar/profile/editprofile.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<String> getBecomeOwnerStatus() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      final data = doc.data();
      return data?['becomeownerstatus'] ?? 'nowish';
    }
    return 'nowish';
  }

  void navigateAccordingToStatus(String status) {
    if (status == 'nowish') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppIntroScreen()),
      );
    } else if (status == 'wishing') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppliedForScreen()),
      );
    } else if (status == 'approved') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SellerPanelScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Gradient Header
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.yellow],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage("assets/useravatar.jpg"),
                ),
                const SizedBox(height: 12),
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
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Options
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 6,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 20),
                      leading: const Icon(Icons.edit, color: Colors.yellow),
                      title: Text(
                        "Edit Information",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      trailing:
                      const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfileScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  FutureBuilder<String>(
                    future: getBecomeOwnerStatus(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator(
                            color: Colors.yellow);
                      }

                      final status = snapshot.data!;
                      String title;
                      IconData icon;

                      if (status == 'approved') {
                        title = "Seller Panel";
                        icon = Icons.dashboard;
                      } else {
                        title = "Be a Seller";
                        icon = Icons.storefront;
                      }

                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 6,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          leading: Icon(icon, color: Colors.yellow[800]),
                          title: Text(
                            title,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                          trailing:
                          const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => navigateAccordingToStatus(status),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
