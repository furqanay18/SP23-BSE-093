import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dailyuser/homepage.dart';
import '../frontendhelpers/appbar.dart'; // Your custom app bar import

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key});

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  final TextEditingController _inventoryUsernameController = TextEditingController();
  final TextEditingController _passcodeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String inventoryName = '';

  void _joinTeam() async {
    final uid = _auth.currentUser?.uid;
    final username = _inventoryUsernameController.text.trim();
    final passcode = _passcodeController.text.trim();

    if (uid == null || username.isEmpty || passcode.isEmpty) return;

    setState(() => isLoading = true);

    final query = await FirebaseFirestore.instance
        .collection('inventories')
        .where('inventoryUsername', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      _showMessage('No inventory found with that username');
      setState(() => isLoading = false);
      return;
    }

    final doc = query.docs.first;
    final data = doc.data();
    final correctPasscode = data['passcode'];
    final List<dynamic> members = data['members'] ?? [];

    if (passcode != correctPasscode) {
      _showMessage('Incorrect passcode');
      setState(() => isLoading = false);
      return;
    }

    if (members.contains(uid)) {
      _showMessage('Already a team member');
    } else {
      members.add(uid);
      await doc.reference.update({'members': members});
      _showMessage('Joined team successfully');
    }

    setState(() {
      inventoryName = data['inventoryUsername'] ?? '';
      isLoading = false;
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          CustomCurvedAppBar(inventoryName: 'Join Team'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    controller: _inventoryUsernameController,
                    decoration: const InputDecoration(
                      labelText: 'Inventory Username',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passcodeController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Passcode',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: isLoading ? null : _joinTeam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Join Team'),
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
