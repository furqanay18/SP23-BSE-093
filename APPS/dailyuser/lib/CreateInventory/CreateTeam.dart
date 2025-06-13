import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dailyuser/homepage.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _passcode = TextEditingController();
  final TextEditingController _categories = TextEditingController();
  final TextEditingController _locations = TextEditingController();

  List<String> categoryList = [];
  List<String> locationList = [];

  bool isLoading = false;

  Future<void> createTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'dummyUid';
    final username = _username.text.trim();

    try {
      final existing = await FirebaseFirestore.instance
          .collection('inventories')
          .where('inventoryUsername', isEqualTo: username)
          .get();

      if (existing.docs.isNotEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This inventory username is already taken.")),
        );
        return;
      }

      final List<String> cats = _categories.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final List<String> locs = _locations.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await FirebaseFirestore.instance.collection('inventories').add({
        'adminUid': uid,
        'inventoryUsername': username,
        'passcode': _passcode.text.trim(),
        'categories': cats,
        'locations': locs,
        'members': [uid],
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'owner': true,
      });

      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team created successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _updateChips() {
    setState(() {
      categoryList = _categories.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      locationList = _locations.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E21), Color(0xFF1D233B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
            : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Start Your Inventory Journey",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildInputCard("Inventory Username", _username),
                  const SizedBox(height: 15),
                  _buildInputCard("Passcode", _passcode, isPassword: true),
                  const SizedBox(height: 15),
                  _buildInputCard("Categories (comma separated)", _categories, onChanged: (_) => _updateChips()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: categoryList
                        .map((cat) => Chip(
                      label: Text(cat),
                      backgroundColor: Colors.yellow.shade700,
                      labelStyle: const TextStyle(color: Colors.black),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 15),
                  _buildInputCard("Locations (comma separated)", _locations, onChanged: (_) => _updateChips()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: locationList
                        .map((loc) => Chip(
                      label: Text(loc),
                      backgroundColor: Colors.lightBlue.shade200,
                      labelStyle: const TextStyle(color: Colors.black),
                    ))
                        .toList(),
                  ),

                  const SizedBox(height: 35),

                  ElevatedButton(
                    onPressed: createTeam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Create Team',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(String label, TextEditingController controller,
      {bool isPassword = false, void Function(String)? onChanged}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: (val) => val!.isEmpty ? 'Required' : null,
          onChanged: onChanged,
          style: const TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontFamily: 'Poppins'),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
