import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> addToCart(BuildContext context, Map<String, dynamic> product) async {
  final prefs = await SharedPreferences.getInstance();

  final String? cartJson = prefs.getString('cart');
  List<dynamic> cart = [];

  if (cartJson != null) {
    cart = json.decode(cartJson);

    // Check if cart is not empty and restaurantId doesn't match
    if (cart.isNotEmpty && cart[0]['restaurantId'] != product['restaurantId']) {
      bool shouldClear = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Start New Cart?"),
          content: const Text("Your cart contains items from another restaurant. Do you want to clear it and add this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Clear & Add"),
            ),
          ],
        ),
      ) ?? false;

      if (!shouldClear) return;

      // Clear cart
      cart.clear();
    }
  }

  // Add product
  cart.add(product);
  await prefs.setString('cart', json.encode(cart));

  // Optional: feedback
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Added ${product['name']} to cart")),
  );
}
