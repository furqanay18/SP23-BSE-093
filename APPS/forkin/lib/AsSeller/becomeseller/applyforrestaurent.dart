import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forkin/helpers/getcurrentlocation.dart'; // Import your getCurrentLocation() method

class ApplyRestaurantScreen extends StatefulWidget {
  const ApplyRestaurantScreen({super.key});

  @override
  State<ApplyRestaurantScreen> createState() => _ApplyRestaurantScreenState();
}

class _ApplyRestaurantScreenState extends State<ApplyRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _coverPhotoController = TextEditingController();
  final _categoriesController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User not logged in.")));
      return;
    }

    final restaurantRef = _firestore.collection('restaurants').doc();

    try {
      final location = await getCurrentLocation(); // Your helper

      await restaurantRef.set({
        'restaurantId': restaurantRef.id,
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'coverPhoto': _coverPhotoController.text.trim(),
        'categories': _categoriesController.text.trim().split(','),
        'rating': 0.0,
        'isOpen': false,
        'isApproved': false,
        'createdAt': FieldValue.serverTimestamp(),
        'pickupLocation': location != null
            ? {
          'latitude': location.latitude,
          'longitude': location.longitude,
        }
            : null,
      });

      await _firestore.collection('users').doc(user.uid).update({
        'becomeownerstatus': 'wishing',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant application submitted.")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isSubmitting = false);
  }

  Widget _buildLabeledField(String label, TextEditingController controller, IconData icon,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Card(
          elevation: 6,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.yellow[800]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.yellow[800]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.yellow[800]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.yellow[800]!, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        iconTheme: const IconThemeData(color: Colors.yellow),
        title: Text("Apply for Restaurant",
            style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121212), Color(0xFF1C1C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 📍 Location Info Message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black87),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Your current location will be used as pickup address by riders.",
                          style: GoogleFonts.poppins(
                              color: Colors.black87, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabeledField("Restaurant Name", _nameController,
                    Icons.restaurant_menu),
                _buildLabeledField("Description", _descController,
                    Icons.description, maxLines: 3),
                _buildLabeledField(
                    "Address", _addressController, Icons.location_on),
                _buildLabeledField("Phone Number", _phoneController,
                    Icons.phone, keyboardType: TextInputType.phone),
                _buildLabeledField("Email", _emailController, Icons.email,
                    keyboardType: TextInputType.emailAddress),
                _buildLabeledField("Cover Photo URL", _coverPhotoController,
                    Icons.photo),
                _buildLabeledField("Categories (comma-separated)",
                    _categoriesController, Icons.category),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[800],
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("APPLY",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
