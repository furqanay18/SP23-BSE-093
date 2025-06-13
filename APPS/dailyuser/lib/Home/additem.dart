import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../frontendhelpers/appbar.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _lowStockController = TextEditingController();

  List<String> categories = [];
  List<String> locations = [];

  String? selectedCategory;
  String? selectedLocation;

  String inventoryUsername = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventoryDetails();
  }

  Future<void> _fetchInventoryDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('inventories')
        .where('adminUid', isEqualTo: uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        inventoryUsername = data['inventoryUsername'];
        categories = List<String>.from(data['categories'] ?? []);
        locations = List<String>.from(data['locations'] ?? []);
        isLoading = false;
      });
    }
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.parse(_quantityController.text.trim());
    final price = double.parse(_priceController.text.trim());
    final totalCost = quantity * price;

    final itemData = {
      'inventoryusername': inventoryUsername,
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': selectedCategory,
      'quantity': quantity,
      'price': price,
      'totalcost': totalCost,
      'locationQuantities': {selectedLocation!: quantity},
      'lowStockThreshold': int.parse(_lowStockController.text.trim()),
      'createdAt': Timestamp.now(),
      'adminUid': FirebaseAuth.instance.currentUser!.uid,

    };

    await FirebaseFirestore.instance.collection('items').add(itemData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          CustomCurvedAppBar(inventoryName: inventoryUsername),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nameController, 'Item Name'),
                    _buildTextField(_descriptionController, 'Description'),
                    _buildDropdown('Category', categories, (val) => setState(() => selectedCategory = val), selectedCategory),
                    _buildDropdown('Location', locations, (val) => setState(() => selectedLocation = val), selectedLocation),
                    _buildTextField(_quantityController, 'Quantity', isNumber: true),
                    _buildTextField(_priceController, 'Price', isNumber: true),
                    _buildTextField(_lowStockController, 'Low Stock Threshold', isNumber: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
                      child: const Text('Add Item', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
        ),
        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, ValueChanged<String?> onChanged, String? selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selected,
        dropdownColor: Colors.black87,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
        ),
        style: const TextStyle(color: Colors.white),
        iconEnabledColor: Colors.white,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Colors.white)))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }
}
