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

class _ApplyForDriverScreenState extends State<ApplyForDriverScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();

  bool _submitted = false;

  late AnimationController _animationController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        'currentLocation': null,
      });

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
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: Color(0xFF0D0D2A), // dark blue-black
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.blueAccent, Colors.transparent],
                          radius: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.5),
                            blurRadius: 25,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.delivery_dining,
                            size: 60, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Driver Registration',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _infoRow("Name", user?.displayName ?? 'No Name'),
                    _infoRow("Email", user?.email ?? 'No Email'),
                    _infoRow("Phone", user?.phoneNumber ?? 'Not Available'),

                    const Divider(height: 40, color: Colors.white24),

                    _inputField("CNIC", _cnicController),
                    _inputField("License Number", _licenseController),
                    _inputField("Vehicle Name", _vehicleController),

                    const SizedBox(height: 30),

                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedScale(
                        duration: Duration(milliseconds: 300),
                        scale: 1.0,
                        child: _submitted
                            ? ElevatedButton.icon(
                          icon: const Icon(Icons.motorcycle),
                          label: Text('Go to Driver Panel',
                              style: GoogleFonts.poppins()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const DriverPanelScreen()),
                            );
                          },
                        )
                            : ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text('Submit',
                              style: GoogleFonts.poppins(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            shadowColor:
                            Colors.lightBlueAccent.withOpacity(0.6),
                          ),
                          onPressed: _submitApplication,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
          Expanded(
            child: Text(value,
                style:
                GoogleFonts.poppins(fontSize: 14, color: Colors.white),
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
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueGrey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent)),
        ),
      ),
    );
  }
}
