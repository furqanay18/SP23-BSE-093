import 'package:dailyuser/Home/HomeScreen.dart';
import 'package:dailyuser/Items/ItemsScreen.dart';
import 'package:dailyuser/Settings/settings.dart';
import 'package:dailyuser/Transactions/transactions.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ItemsScreen(),
    LogScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: Colors.yellow[700],
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.black,
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: Colors.yellow[700]!,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.inventory_2),
            title: const Text("Items"),
            selectedColor: Colors.yellow[700]!,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.receipt_long),
            title: const Text("Transactions"),
            selectedColor: Colors.yellow[700]!,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.settings),
            title: const Text("Settings"),
            selectedColor: Colors.yellow[700]!,
          ),
        ],
      ),
    );
  }
}
