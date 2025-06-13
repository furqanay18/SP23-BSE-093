import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'addtocart.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    final snap = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .get();
    if (snap.exists) {
      final List<String> fetchedCategories = List<String>.from(
        snap.data()?['categories'] ?? [],
      );
      setState(() {
        categories = fetchedCategories;
        _tabController = TabController(length: categories.length, vsync: this);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Menu')),
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.black,
            indicatorColor: Colors.deepOrange,
            tabs:
            categories.map((cat) => Tab(text: cat.trim())).toList(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                return CategoryProductsView(
                  restaurantId: widget.restaurantId,
                  category: category.trim(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryProductsView extends StatelessWidget {
  final String restaurantId;
  final String category;

  const CategoryProductsView({
    super.key,
    required this.restaurantId,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        if (products.isEmpty) {
          return const Center(child: Text("No products in this category."));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68, // adjusted to prevent overflow
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final data = products[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      data['image'] ?? '',
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 100,
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? 'No Name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                            const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${data['price'] ?? 0}",
                            style:
                            const TextStyle(color: Colors.deepOrange),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.deepOrange,
                              ),
                              onPressed: () async {
                                await addToCart(context, {
                                  'id': data.id,
                                  'name': data['name'],
                                  'price': data['price'],
                                  'image': data['image'],
                                  'restaurantId': data['restaurantId'],
                                  'quantity': 1,
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                    Text("Added ${data['name']} to cart"),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
