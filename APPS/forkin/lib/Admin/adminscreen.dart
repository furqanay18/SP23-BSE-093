import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class PendingRestaurantsScreen extends StatelessWidget {
  const PendingRestaurantsScreen({super.key});

  Future<void> approveRestaurant(String restaurantId, String uid) async {
    final restaurantRef =
    FirebaseFirestore.instance.collection('restaurants').doc(restaurantId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await restaurantRef.update({'isApproved': true});
    await userRef.update({'becomeownerstatus': 'approved'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pending Restaurants",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .where('isApproved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.yellow));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No pending restaurants",
                  style: GoogleFonts.poppins(color: Colors.white)),
            );
          }

          final restaurants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: restaurants.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final data = restaurants[index].data() as Map<String, dynamic>;
              final restaurantId = data['restaurantId'];
              final uid = data['uid'];
              final coverPhoto = data['coverPhoto'] ?? '';

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (coverPhoto.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(coverPhoto,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover),
                        ),
                      const SizedBox(height: 12),
                      Text("Name: ${data['name'] ?? ''}",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Description: ${data['description'] ?? ''}",
                          style: GoogleFonts.poppins(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("Address: ${data['address'] ?? ''}",
                          style: GoogleFonts.poppins(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("Phone: ${data['phone'] ?? ''}",
                          style: GoogleFonts.poppins(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("Email: ${data['email'] ?? ''}",
                          style: GoogleFonts.poppins(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        "Categories: ${(data['categories'] as List<dynamic>).join(', ')}",
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await approveRestaurant(restaurantId, uid);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Restaurant approved!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Approve",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
