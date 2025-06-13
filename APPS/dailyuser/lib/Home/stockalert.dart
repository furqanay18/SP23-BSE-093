import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockShortagePage extends StatefulWidget {
  final String inventoryUsername;

  const StockShortagePage({super.key, required this.inventoryUsername});

  @override
  State<StockShortagePage> createState() => _StockShortagePageState();
}

class _StockShortagePageState extends State<StockShortagePage> {
  List<Map<String, dynamic>> lowStockItems = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchLowStockItems();
  }

  Future<void> fetchLowStockItems() async {
    final snap = await FirebaseFirestore.instance
        .collection('items')
        .where('inventoryusername', isEqualTo: widget.inventoryUsername)
        .get();

    final allItems = snap.docs.map((doc) => doc.data()).toList();

    final filtered = allItems.where((item) {
      final quantity = item['quantity'] ?? 0;
      final threshold = item['lowStockThreshold'] ?? 0;
      return quantity <= threshold;
    }).toList();

    setState(() {
      lowStockItems = filtered;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Low Stock Items'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.yellow,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : lowStockItems.isEmpty
          ? const Center(
        child: Text(
          'No items are below the low stock threshold.',
          style: TextStyle(color: Colors.white),
        ),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Name', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Quantity', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Threshold', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Category', style: TextStyle(color: Colors.white))),
          ],
          rows: lowStockItems.map((item) {
            return DataRow(cells: [
              DataCell(Text(item['name'] ?? '', style: const TextStyle(color: Colors.white))),
              DataCell(Text('${item['quantity']}', style: const TextStyle(color: Colors.white))),
              DataCell(Text('${item['lowStockThreshold']}', style: const TextStyle(color: Colors.white))),
              DataCell(Text(item['category'] ?? 'Uncategorized', style: const TextStyle(color: Colors.white))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
