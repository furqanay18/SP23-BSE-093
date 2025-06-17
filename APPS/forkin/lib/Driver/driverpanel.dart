import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forkin/Driver/acceptorder.dart';

class DriverPanelScreen extends StatefulWidget {
  const DriverPanelScreen({super.key});

  @override
  State<DriverPanelScreen> createState() => _DriverPanelScreenState();
}

class _DriverPanelScreenState extends State<DriverPanelScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getRestaurantData(String restaurantId) async {
    final doc = await _firestore.collection('restaurants').doc(restaurantId).get();
    if (doc.exists) return doc.data();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        iconTheme: const IconThemeData(color: Colors.yellow),
        title: Text("Driver Panel", style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('orders').where('rider', isEqualTo: 'no').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.yellow));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No available orders found.",
                  style: GoogleFonts.poppins(color: Colors.white70)),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final restaurantId = data['restaurantId'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: getRestaurantData(restaurantId),
                builder: (context, restaurantSnapshot) {
                  final restaurant = restaurantSnapshot.data;

                  return Card(
                    color: Colors.white,
                    elevation: 6,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Customer: ${data['userName'] ?? ''}",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text("Phone: ${data['phone'] ?? ''}", style: GoogleFonts.poppins()),
                          Text("Delivery Address: ${data['userAddress'] ?? ''}",
                              style: GoogleFonts.poppins()),
                          const SizedBox(height: 6),
                          Text("Total Bill: ₹${data['totalBill']?.toStringAsFixed(2) ?? '0.00'}",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),

                          const Divider(height: 20, color: Colors.black54),

                          Text("Restaurant: ${restaurant?['name'] ?? 'Loading...'}",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          Text("Pickup Address: ${restaurant?['address'] ?? ''}",
                              style: GoogleFonts.poppins()),

                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow[800],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AcceptOrderScreen(orderId: order.id),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check),
                              label: const Text("Accept"),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
