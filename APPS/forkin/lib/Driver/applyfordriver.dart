import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:forkin/Driver/driverpanel.dart';

class ApplyForDriverScreen extends StatefulWidget {
  const ApplyForDriverScreen({super.key});

  @override
  State<ApplyForDriverScreen> createState() => _ApplyForDriverScreenState();
}

class _ApplyForDriverScreenState extends State<ApplyForDriverScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();

  bool _submitted = false;

  Future<void> _submitApplication() async {
    if (_cnicController.text.isEmpty ||
        _licenseController.text.isEmpty ||
        _vehicleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(user!.uid)
          .set({
        'uid': user!.uid,
        'name': user!.displayName ?? 'No Name',
        'email': user!.email ?? 'No Email',
        'phone': user!.phoneNumber ?? 'N/A',
        'cnic': _cnicController.text.trim(),
        'license': _licenseController.text.trim(),
        'vehicle': _vehicleController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'currentLocation': null, // will be updated on delivery
      });

      // Optional: update 'driver' field in `users` collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'driver': true});

      setState(() {
        _submitted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application Submitted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Apply as Driver',
            style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.delivery_dining, size: 60, color: Colors.yellow[800]),
                const SizedBox(height: 16),
                Text(
                  'Driver Registration',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // User info display
                _infoRow("Name", user?.displayName ?? 'No Name'),
                _infoRow("Email", user?.email ?? 'No Email'),
                _infoRow("Phone", user?.phoneNumber ?? 'Not Available'),

                const Divider(height: 40),

                // Input fields
                _inputField("CNIC", _cnicController),
                _inputField("License Number", _licenseController),
                _inputField("Vehicle Name", _vehicleController),

                const SizedBox(height: 30),

                _submitted
                    ? ElevatedButton.icon(
                  icon: const Icon(Icons.motorcycle),
                  label: Text('Go to Driver Panel',
                      style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DriverPanelScreen()),
                    );
                  },
                )
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text('Submit',
                      style: GoogleFonts.poppins(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[800],
                      foregroundColor: Colors.black),
                  onPressed: _submitApplication,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$label: ",
              style:
              GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(fontSize: 14),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
