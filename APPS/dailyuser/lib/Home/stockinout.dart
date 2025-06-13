import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateStockPage extends StatefulWidget {
  final String inventoryUsername;
  final String type; // "in" or "out"

  const UpdateStockPage({
    super.key,
    required this.inventoryUsername,
    required this.type,
  });

  @override
  State<UpdateStockPage> createState() => _UpdateStockPageState();
}

class _UpdateStockPageState extends State<UpdateStockPage> {
  String? selectedItemId;
  String? selectedItemName;
  String? selectedLocation;
  int quantity = 0;

  List<DocumentSnapshot> items = [];
  List<String> locations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final snap = await FirebaseFirestore.instance
        .collection('items')
        .where('inventoryusername', isEqualTo: widget.inventoryUsername)
        .get();

    setState(() {
      items = snap.docs;
      loading = false;
    });
  }

  void onItemSelected(String? itemId) {
    final selectedItem = items.firstWhere((doc) => doc.id == itemId);
    final locationMap = selectedItem['locationQuantities'] as Map<String, dynamic>? ?? {};
    setState(() {
      selectedItemId = itemId;
      selectedItemName = selectedItem['name'];
      locations = locationMap.keys.toList();
      selectedLocation = null; // reset location
    });
  }

  Future<void> updateStock() async {
    if (selectedItemId == null || selectedLocation == null || quantity <= 0) return;

    final docRef = FirebaseFirestore.instance.collection('items').doc(selectedItemId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final itemData = docSnap.data()!;
    final currentQty = itemData['quantity'] ?? 0;
    final locationMap = Map<String, dynamic>.from(itemData['locationQuantities'] ?? {});
    final locQty = locationMap[selectedLocation!] ?? 0;

    int newQty = widget.type == 'in' ? currentQty + quantity : currentQty - quantity;
    int newLocQty = widget.type == 'in' ? locQty + quantity : locQty - quantity;

    if (newQty < 0 || newLocQty < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity cannot go below 0')),
      );
      return;
    }

    // Update the item quantities
    await docRef.update({
      'quantity': newQty,
      'locationQuantities.${selectedLocation!}': newLocQty,
    });

    // Log the change
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance.collection('logs').add({
      'itemid': selectedItemId,
      'itemName': selectedItemName,
      'type': widget.type,
      'quantityChanged': quantity,
      'updatedBy': uid,
      'location': selectedLocation!,
      'inventoryusername': widget.inventoryUsername,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stock ${widget.type == 'in' ? 'added' : 'deducted'} and log saved.')),
    );

    setState(() {
      selectedItemId = null;
      selectedItemName = null;
      selectedLocation = null;
      quantity = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.type == 'in' ? 'Add Stock' : 'Remove Stock'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.yellow,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedItemId,
              decoration: _inputDecoration('Select Product'),
              items: items
                  .map((doc) => DropdownMenuItem(
                value: doc.id,
                child: Text(doc['name'], style: const TextStyle(color: Colors.black)),
              ))
                  .toList(),
              onChanged: onItemSelected,
              dropdownColor: Colors.white,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedLocation,
              decoration: _inputDecoration('Select Location'),
              items: locations
                  .map((loc) => DropdownMenuItem(
                value: loc,
                child: Text(loc, style: const TextStyle(color: Colors.black)),
              ))
                  .toList(),
              onChanged: (value) => setState(() => selectedLocation = value),
              dropdownColor: Colors.white,
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Enter Quantity'),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => quantity = int.tryParse(val) ?? 0,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: updateStock,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
              ),
              child: Text(widget.type == 'in' ? 'Add Stock' : 'Remove Stock'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white12,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
