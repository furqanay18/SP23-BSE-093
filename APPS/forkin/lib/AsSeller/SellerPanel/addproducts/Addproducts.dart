import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forkin/AsSeller/SellerPanel/sellerpanel.dart'; // ✅ Add your seller panel screen import

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  List<String> _categories = [];

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final query = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        _categories = List<String>.from(query.docs.first['categories']);
      });
    }
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final restDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (restDoc.docs.isEmpty) return;

      final restId = restDoc.docs.first['restaurantId'];

      final data = {
        'name': nameController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'description': descriptionController.text.trim(),
        'image': imageUrlController.text.trim(),
        'category': _selectedCategory,
        'restaurantId': restId,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('products').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added!")),
      );

      // ✅ Redirect to seller panel
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellerPanelScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add product: $e")),
      );
    }
  }

  Widget _buildLabeledField(String label, TextEditingController controller,
      IconData icon, String? Function(String?) validator,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
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
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: validator,
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
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.yellow[800]),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.category, color: Colors.yellow[800]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.yellow[800]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.yellow[800]!, width: 2),
              ),
            ),
            items: _categories
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (val) => setState(() => _selectedCategory = val),
            validator: (val) => val == null ? "Select a category" : null,
            style: GoogleFonts.poppins(color: Colors.black),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        automaticallyImplyLeading: false, // ✅ remove back arrow
        title: Text("Add Product",
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
                _buildLabeledField("Product Name", nameController, Icons.fastfood,
                        (val) => val!.isEmpty ? "Required" : null),
                const SizedBox(height: 20),
                _buildLabeledField("Price", priceController, Icons.attach_money,
                        (val) => val!.isEmpty ? "Required" : null,
                    isNumber: true),
                const SizedBox(height: 20),
                _buildLabeledField("Description", descriptionController,
                    Icons.description, (val) => val!.isEmpty ? "Required" : null),
                const SizedBox(height: 20),
                _buildLabeledField("Image URL", imageUrlController, Icons.image,
                        (val) => val!.isEmpty ? "Required" : null),
                const SizedBox(height: 20),
                _buildDropdown(),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[800],
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("ADD PRODUCT",
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
