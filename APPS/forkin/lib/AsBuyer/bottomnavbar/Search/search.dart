import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forkin/AsBuyer/bottomnavbar/Restaurent/products.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forkin/AsBuyer/bottomnavbar/favorites/favourite_helper.dart';

class SearchRestaurantsScreen extends StatefulWidget {
  const SearchRestaurantsScreen({super.key});

  @override
  State<SearchRestaurantsScreen> createState() => _SearchRestaurantsScreenState();
}

class _SearchRestaurantsScreenState extends State<SearchRestaurantsScreen> {
  String searchQuery = '';
  List<QueryDocumentSnapshot> allRestaurants = [];
  List<QueryDocumentSnapshot> filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('isApproved', isEqualTo: true)
        .where('isOpen', isEqualTo: true)
        .get();

    setState(() {
      allRestaurants = snapshot.docs;
      filteredRestaurants = allRestaurants;
    });
  }

  void updateSearchResults(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredRestaurants = allRestaurants.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString().toLowerCase();
        final categories = List<String>.from(data['categories'] ?? []);
        return name.contains(searchQuery) ||
            categories.any((category) => category.toLowerCase().contains(searchQuery));
      }).toList();
    });
  }

  Future<void> toggleFavorite(Map<String, dynamic> restaurant) async {
    final isFav = await FavoriteHelper.isFavorite(restaurant['restaurantId']);
    if (isFav) {
      await FavoriteHelper.removeFavorite(restaurant['restaurantId']);
    } else {
      await FavoriteHelper.addFavorite(restaurant);
    }
    setState(() {});
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
      child: Column(
        children: [
          const SizedBox(height: 40), // For safe area / spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: updateSearchResults,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by name or category",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRestaurants.length,
              itemBuilder: (context, index) {
                final doc = filteredRestaurants[index];
                final data = doc.data() as Map<String, dynamic>;
                final restaurantId = data['restaurantId'];

                return FutureBuilder<bool>(
                  future: FavoriteHelper.isFavorite(restaurantId),
                  builder: (context, snapshot) {
                    final isFav = snapshot.data ?? false;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantDetailPage(restaurantId: restaurantId),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.black,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                        shadowColor: Colors.amberAccent.withOpacity(0.3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Image.network(
                                data['coverPhoto'] ?? '',
                                width: 120,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 100, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['name'] ?? 'No Name',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            isFav ? Icons.favorite : Icons.favorite_border,
                                            color: isFav ? Colors.red : Colors.grey,
                                          ),
                                          onPressed: () => toggleFavorite(data),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          (data['rating'] ?? 0).toString(),
                                          style: const TextStyle(fontSize: 14, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      data['address'] ?? 'No Address',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
