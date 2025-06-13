import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteHelper {
  static const String _key = 'favorite_restaurants';

  // Get list of favorite restaurants
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List decoded = json.decode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Check if a restaurant is in favorites by restaurantId
  static Future<bool> isFavorite(String restaurantId) async {
    final favorites = await getFavorites();
    return favorites.any((r) => r['restaurantId'] == restaurantId);
  }

  // Add to favorites (ensures no duplicates)
  // Add to favorites (cleans unsupported types like Timestamp)
  static Future<void> addFavorite(Map<String, dynamic> restaurantData) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    final exists = favorites.any((r) => r['restaurantId'] == restaurantData['restaurantId']);
    if (!exists) {
      // Clean the restaurantData before storing
      final cleanedData = Map<String, dynamic>.from(restaurantData)
        ..removeWhere((key, value) => value is! String && value is! num && value is! bool && value is! List && value is! Map);

      await prefs.setString(_key, json.encode([...favorites, cleanedData]));
    }
  }


  // Remove from favorites
  static Future<void> removeFavorite(String restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((r) => r['restaurantId'] == restaurantId);
    await prefs.setString(_key, json.encode(favorites));
  }
}
