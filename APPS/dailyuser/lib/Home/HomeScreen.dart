import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyuser/Home/additem.dart';
import 'package:dailyuser/Home/placeholderfiles.dart';
import 'package:dailyuser/Home/stockalert.dart';
import 'package:dailyuser/Home/stockinout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dailyuser/frontendhelpers/appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String inventoryName = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchInventoryName();
  }

  Future<void> fetchInventoryName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('inventories')
        .where('adminUid', isEqualTo: uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        inventoryName = snapshot.docs.first['inventoryUsername'] ?? '';
        loading = false;
      });
    } else {
      setState(() {
        inventoryName = 'Unknown Inventory';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomCurvedAppBar(inventoryName: inventoryName),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _sectionTitle('Stock In/Out'),
                _optionCard('Stock In', Icons.download_rounded, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>  UpdateStockPage(inventoryUsername: inventoryName, type: 'in')));
                }),
                _optionCard('Stock Out', Icons.upload_rounded, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => UpdateStockPage(inventoryUsername: inventoryName, type: 'out')));
                }),
                _optionCard('Move Stock', Icons.compare_arrows_rounded, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MoveStockPage()));
                }),
                _optionCard('Adjust', Icons.tune_rounded, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdjustPage()));
                }),
                const Divider(height: 30, thickness: 1.5),
                _sectionTitle('Low Stock Alert'),
                _optionCard('Check Stock Shortage', Icons.warning_amber_rounded, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>  StockShortagePage(inventoryUsername: inventoryName)));
                }),
                const Divider(height: 30, thickness: 1.5),
                _sectionTitle('Manage Items'),
                _optionCard('Add Item', Icons.add_box_rounded, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddItemScreen())); // Replace with AddItemPage
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _optionCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
