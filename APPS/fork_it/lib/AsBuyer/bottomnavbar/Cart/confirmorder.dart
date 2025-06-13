import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fork_it/homepage.dart';

class ConfirmOrderBar extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String restaurantId;

  const ConfirmOrderBar({
    super.key,
    required this.cartItems,
    required this.restaurantId,
  });

  @override
  State<ConfirmOrderBar> createState() => _ConfirmOrderBarState();
}

class _ConfirmOrderBarState extends State<ConfirmOrderBar> {
  String userAddress = '';
  String userName = '';
  String phoneNumber = '';
  bool loading = true;
  final _phoneController = TextEditingController();

  double get totalBill {
    return widget.cartItems.fold(0.0, (sum, item) => sum + (item['price'] ?? 0));
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snap.data();
    if (data != null) {
      setState(() {
        userAddress = data['address'] ?? '';
        userName = data['name'] ?? '';
        phoneNumber = data['phone'] ?? '';
        _phoneController.text = phoneNumber;
        loading = false;
      });
    }
  }

  Future<void> confirmOrder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your phone number")),
      );
      return;
    }

    final productsId = widget.cartItems.map((item) => item['productId']).toList();

    await FirebaseFirestore.instance.collection('orders').add({
      'restaurantId': widget.restaurantId,
      'uid': uid,
      'userName': userName,
      'userAddress': userAddress,
      'phone': _phoneController.text.trim(),
      'totalBill': totalBill,
      'paymentMethod': 'Cash on Delivery',
      'cartItems': widget.cartItems,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cart');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );

    }

  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Deliver to: $userAddress", style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total: ₹${totalBill.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: confirmOrder,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                child: const Text("Confirm Order"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
