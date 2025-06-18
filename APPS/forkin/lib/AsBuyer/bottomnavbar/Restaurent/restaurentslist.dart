import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forkin/AsBuyer/bottomnavbar/Restaurent/products.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forkin/AsBuyer/bottomnavbar/favorites/favourite_helper.dart';
import 'package:forkin/AsBuyer/bottomnavbar/Restaurent/closedrestraunt.dart';

class RestaurentsList extends StatefulWidget {
  const RestaurentsList({super.key});

  @override
  State<RestaurentsList> createState() => _RestaurentsListState();
}

class _RestaurentsListState extends State<RestaurentsList> {
  Set<String> favoriteIds = {};
  String? orderStatus;

  @override
  void initState() {
    super.initState();
    loadFavorites();
    checkOrderStatus();
  }

  Future<void> loadFavorites() async {
    final favorites = await FavoriteHelper.getFavorites();
    setState(() {
      favoriteIds = favorites.map((r) => r['restaurantId'].toString()).toSet();
    });
  }

  Future<void> toggleFavorite(Map<String, dynamic> restaurantData) async {
    final id = restaurantData['restaurantId'];
    final isFav = favoriteIds.contains(id);
    if (isFav) {
      await FavoriteHelper.removeFavorite(id);
    } else {
      await FavoriteHelper.addFavorite(restaurantData);
    }
    await loadFavorites();
  }

  Future<void> checkOrderStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('uid', isEqualTo: uid)
        .where('status', isNotEqualTo: 'Delivered')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        orderStatus = snapshot.docs.first['status'];
      });
    }
  }

  String getStatusMessage(String status) {
    switch (status) {
      case 'Pending':
        return '⏳ Order laga diya hai boss, ab zara ruk ja!';
      case 'Making':
        return '👨‍🍳 Chef full form mein hai, ban raha hai tera swaad!';
      case 'On the way':
        return '🛵 Bhukkad! Tera khana raste mein hai, plate ready rakh!';
      default:
        return '🍽️ Order placed, stay tuned!';
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.lock_clock;
      case 'Making':
        return Icons.kitchen;
      case 'On the way':
        return Icons.delivery_dining;
      default:
        return Icons.fastfood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomLeft,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (orderStatus != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.yellowAccent,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          getStatusIcon(orderStatus!),
                          size: 32,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            getStatusMessage(orderStatus!),
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('restaurants')
                  .where('isApproved', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No restaurants currently.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final restaurantId = data['restaurantId'];

                    return InkWell(
                        onTap: () {
                          if (data['isOpen'] == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RestaurantDetailPage(restaurantId: restaurantId),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ClosedRestaurantPage(),
                              ),
                            );
                          }
                        },

                      child: Card(
                        color: const Color(0xFF1C1C1C),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  Image.network(
                                    data['coverPhoto'] ?? '',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (data['isOpen'] == false)
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        color: Colors.black.withOpacity(0.6),
                                        child: Center(
                                          child: Text(
                                            "Closed",
                                            style: GoogleFonts.poppins(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['name'] ?? 'No Name',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            favoriteIds.contains(restaurantId)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: favoriteIds.contains(restaurantId)
                                                ? Colors.red
                                                : Colors.white70,
                                          ),
                                          onPressed: () => toggleFavorite(data),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          (data['rating'] ?? 0).toString(),
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      data['address'] ?? 'No Address',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

