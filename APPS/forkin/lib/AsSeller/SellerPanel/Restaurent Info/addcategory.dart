import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final TextEditingController _categoryController = TextEditingController();
  List<String> _categories = [];
  bool _isLoading = true;
  String? _docId;

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
      final doc = query.docs.first;
      final data = doc.data();
      _docId = doc.id;

      setState(() {
        _categories = List<String>.from(data['categories'] ?? []);
        _isLoading = false;
      });
    }
  }

  Future<void> _addCategory() async {
    final newCategory = _categoryController.text.trim();

    if (newCategory.isEmpty || _docId == null) return;

    if (_categories.contains(newCategory)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category already exists")),
      );
      return;
    }

    setState(() => _categories.add(newCategory));

    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(_docId)
        .update({'categories': _categories});

    _categoryController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Category added")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Manage Categories"),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 60),
              Wrap(
                spacing: 8,       // horizontal space between chips
                runSpacing: 12,   // vertical space between lines of chips
                children: _categories
                    .map(
                      (cat) => Chip(
                    label: Text(cat),
                    backgroundColor: Colors.amber,
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                )
                    .toList(),
              ),

              const Divider(height: 30, color: Colors.white),
              Text(
                "Add New Category:",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _categoryController,
                    style: GoogleFonts.poppins(),
                    decoration: const InputDecoration(
                      hintText: "Enter category name",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: Text("Add Category", style: GoogleFonts.poppins()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
