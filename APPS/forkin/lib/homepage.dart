import 'package:flutter/material.dart';
import 'package:forkin/AsBuyer/bottomnavbar/favorites/favourite.dart';
import 'package:forkin/AsBuyer/bottomnavbar/profile/profile.dart';
import 'package:forkin/AsBuyer/bottomnavbar/Restaurent/restaurentslist.dart';
import 'package:forkin/AsBuyer/bottomnavbar/Search/search.dart';
import 'package:forkin/AsBuyer/bottomnavbar/Cart/cart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomepageState();
}

class _HomepageState extends State<HomePage> {
  int index = 0;
  String userAddress = 'Loading address...';

  final screens = [RestaurentsList(),SearchRestaurantsScreen(), FavoritesScreen(), Cart(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    fetchUserAddress();
  }

  Future<void> fetchUserAddress() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc['address'] != null) {
          setState(() {
            userAddress = userDoc['address'];
          });
        } else {
          setState(() {
            userAddress = 'No address found';
          });
        }
      }
    } catch (e) {
      setState(() {
        userAddress = 'Error loading address';
      });
      print('Error fetching user address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            const SizedBox(width: 10),
            Text(
              'Fork it',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.montserrat().fontFamily,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(23, 23, 23, 1.0),
      ),
      body: Column(
        children: [
          Container(
            color: Color.fromRGBO(255, 255, 255, 1.0),
            child: SizedBox(
              height: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: Color.fromRGBO(233, 0, 255, 1.0),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          userAddress,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                            color: Colors.black,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: screens[index]),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: index,
        items: <Widget>[
          Icon(Icons.home, size: 30,color: Colors.black),
          Icon(Icons.search, size: 30,color: Colors.black),
          Icon(Icons.favorite, size: 30,color: Colors.black),
          Icon(Icons.shopping_bag, size: 30,color: Colors.black),
          Icon(Icons.person, size: 30,color: Colors.black),
        ],
        height: 60,
        backgroundColor: Colors.black,
        color: Color.fromRGBO(255, 198, 0, 1.0),
        buttonBackgroundColor: const Color.fromRGBO(225, 232, 235, 1.0),
        animationDuration: const Duration(milliseconds: 200),
        onTap: (newIndex) {
          setState(() {
            index = newIndex;
          });
        },
      ),
    );
  }
}
