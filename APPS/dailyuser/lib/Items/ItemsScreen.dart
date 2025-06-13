import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchItemsGroupedByCategory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    // Get all inventories where the user is a member
    final inventorySnapshot = await FirebaseFirestore.instance
        .collection('inventories')
        .where('members', arrayContains: uid)
        .get();

    final inventoryUsernames = inventorySnapshot.docs
        .map((doc) => doc['inventoryUsername'] as String)
        .toList();

    if (inventoryUsernames.isEmpty) return [];

    // Fetch all items from these inventories
    final itemsSnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('inventoryusername', whereIn: inventoryUsernames)
        .get();

    return itemsSnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchItemsGroupedByCategory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No items available.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final items = snapshot.data!;
        final Map<String, List<Map<String, dynamic>>> grouped = {};

        for (var item in items) {
          final category = item['category'] ?? 'Uncategorized';
          grouped.putIfAbsent(category, () => []).add(item);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: grouped.entries.map((entry) {
              final category = entry.key;
              final categoryItems = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      headingRowColor: MaterialStateProperty.all(Colors.black45),
                      dataRowColor: MaterialStateProperty.all(Colors.black12),
                      columns: const [
                        DataColumn(
                          label: Row(
                            children: [
                              Icon(Icons.inventory_2, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Name', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              Icon(Icons.price_check, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Price', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              Icon(Icons.numbers, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Qty', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              Icon(Icons.calculate, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Total', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                      rows: categoryItems.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item['name'] ?? '', style: const TextStyle(color: Colors.white))),
                            DataCell(Text(item['price'].toString(), style: const TextStyle(color: Colors.white))),
                            DataCell(Text(item['quantity'].toString(), style: const TextStyle(color: Colors.white))),
                            DataCell(Text(item['totalcost'].toString(), style: const TextStyle(color: Colors.white))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
