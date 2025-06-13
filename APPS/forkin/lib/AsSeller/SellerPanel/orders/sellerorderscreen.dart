import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerOrdersScreen extends StatefulWidget {
  final String statusQuery;
  const SellerOrdersScreen({super.key, required this.statusQuery});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  String? restaurantId;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRestaurantId();
  }

  Future<void> fetchRestaurantId() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (!mounted) return;
        setState(() {
          errorMessage = 'User not logged in.';
          isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (!mounted) return;

      if (doc.docs.isNotEmpty) {
        setState(() {
          restaurantId = doc.docs.first.id;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Restaurant not found for this user.';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error fetching restaurant ID: $e';
        isLoading = false;
      });
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.white))),
        backgroundColor: Colors.black,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.statusQuery} Orders'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('restaurantId', isEqualTo: restaurantId)
              .where('status', isEqualTo: widget.statusQuery)
              .orderBy('createdAt', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
              );
            }

            final orders = snapshot.data?.docs ?? [];

            if (orders.isEmpty) {
              return const Center(
                child: Text("No orders found.", style: TextStyle(color: Colors.white)),
              );
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final doc = orders[index];
                final data = doc.data() as Map<String, dynamic>;
                final cartItems = List<Map<String, dynamic>>.from(data['cartItems'] ?? []);

                return Card(
                  color: Colors.white,
                  elevation: 10,
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['userName'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("📍 ${data['userAddress']}", style: const TextStyle(fontFamily: 'Poppins')),
                        Text("📞 ${data['phone']}", style: const TextStyle(fontFamily: 'Poppins')),
                        const Divider(height: 20),
                        ...cartItems.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item['image'],
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text("Qty: ${item['quantity']}", style: const TextStyle(fontFamily: 'Poppins')),
                                  ],
                                ),
                              ),
                              Text("₹${item['price']}", style: const TextStyle(fontFamily: 'Poppins')),
                            ],
                          ),
                        )),
                        const Divider(height: 20),
                        Text("Total: ₹${data['totalBill']}", style: const TextStyle(fontFamily: 'Poppins')),
                        Text("Payment: ${data['paymentMethod']}", style: const TextStyle(fontFamily: 'Poppins')),
                        const SizedBox(height: 10),
                        if (widget.statusQuery == "Pending") ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => updateOrderStatus(doc.id, "Making"),
                                icon: const Icon(Icons.kitchen, color: Colors.black),
                                label: const Text("Mark as Making",
                                    style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => updateOrderStatus(doc.id, "On the way"),
                                icon: const Icon(Icons.delivery_dining, color: Colors.black),
                                label: const Text("On the Way",
                                    style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ] else if (widget.statusQuery == "Making") ...[
                          ElevatedButton.icon(
                            onPressed: () => updateOrderStatus(doc.id, "On the way"),
                            icon: const Icon(Icons.delivery_dining, color: Colors.black),
                            label: const Text("On the Way",
                                style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
