import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forkin/homepage.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  String? _message;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<User?> registerUser({
    required String name,
    required String email,
    required String address,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      await user?.updateDisplayName(name);

      if (user != null) {
        await user.sendEmailVerification();
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'address': address,
          'owner': false,
          'becomeownerstatus': "nowish"
        });

        setState(() {
          _message = 'Registration successful! Please verify your email before logging in.';
        });
        return user;
      }
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    }
    return null;
  }

  void _registerUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final user = await registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        address: addressController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message ?? "Error")),
      );

      if (user != null && user.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF176), Color(0xFFFFC107)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create Your\nAccount",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildLabeledField("Full Name", nameController, Icons.person,
                            validator: (value) => value!.isEmpty ? "Name is required" : null),
                        const SizedBox(height: 20),
                        _buildLabeledField("Email", emailController, Icons.email, validator: (value) {
                          if (value!.isEmpty) return "Email is required";
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) return "Enter a valid email";
                          return null;
                        }),
                        const SizedBox(height: 20),
                        _buildLabeledField("Password", passwordController, Icons.lock,
                            obscure: true,
                            validator: (value) {
                              if (value!.isEmpty) return "Password is required";
                              if (value.length < 6) return "Must be at least 6 characters";
                              return null;
                            }),
                        const SizedBox(height: 20),
                        _buildLabeledField("Address", addressController, Icons.location_on,
                            validator: (value) => value!.isEmpty ? "Address is required" : null),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () => _registerUser(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("SIGN UP", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: Text(
                            "Or Sign Up With",
                            style: GoogleFonts.poppins(color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: _buildSocialIcon(FontAwesomeIcons.google),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabeledField(
      String label, TextEditingController controller, IconData icon,
      {bool obscure = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
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
            style: GoogleFonts.poppins(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-up coming soon...")),
        );
      },
      icon: Icon(icon, color: Colors.white),
      label: const Text("Continue with Google", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
