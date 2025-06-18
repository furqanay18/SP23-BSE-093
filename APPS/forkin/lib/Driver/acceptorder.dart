import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AcceptOrderScreen extends StatefulWidget {
  final String orderId;

  const AcceptOrderScreen({super.key, required this.orderId});

  @override
  State<AcceptOrderScreen> createState() => _AcceptOrderScreenState();
}

class _AcceptOrderScreenState extends State<AcceptOrderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = true;
  bool isAccepted = false;
  bool showDeliverButton = false;

  Map<String, dynamic>? orderData;
  Map<String, dynamic>? restaurantData;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    _listenForStatusChanges();
  }

  Future<void> _loadOrder() async {
    final orderDoc = await _firestore.collection('orders').doc(widget.orderId).get();
    if (!orderDoc.exists) return;

    orderData = orderDoc.data();
    final restaurantId = orderData!['restaurantId'];

    final restaurantDoc = await _firestore.collection('restaurants').doc(restaurantId).get();
    if (restaurantDoc.exists) {
      restaurantData = restaurantDoc.data();
    }

    if (orderData!['rider'] != 'no') {
      isAccepted = true;
    }

    if (orderData!['status'] == 'On the way') {
      showDeliverButton = true;
    }

    setState(() => isLoading = false);
  }

  void _listenForStatusChanges() {
    _firestore.collection('orders').doc(widget.orderId).snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['status'] == 'On the way') {
          setState(() {
            showDeliverButton = true;
          });
        }
      }
    });
  }

  Future<void> _launchCoordinates(double lat, double lng) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Ensures it opens in Maps app or browser
      );
    } else {
      // Optional: Show error if URL couldn't be launched
      debugPrint('Could not launch map URL: $url');
      // You can show a snackbar or alert here if needed
    }
  }
  Future<void> _acceptOrder() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || orderData == null) return;

    final latestOrderSnapshot = await _firestore.collection('orders').doc(widget.orderId).get();
    if (latestOrderSnapshot.data()?['rider'] != 'no') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order already accepted by another rider.")),
      );
      return;
    }

    await _firestore.collection('orders').doc(widget.orderId).update({
      'rider': currentUser.uid,
      'status': 'Assigned',
    });

    setState(() {
      isAccepted = true;
      showDeliverButton = false;
    });
  }

  Future<void> _markAsDelivered() async {
    await _firestore.collection('orders').doc(widget.orderId).update({
      'status': 'Delivered',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order marked as Delivered.")),
    );

    setState(() {
      showDeliverButton = false;
    });
  }

  Future<bool> _onWillPop() async => isAccepted == false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C1C1C),
          iconTheme: const IconThemeData(color: Colors.yellow),
          title: Text("Order Details", style: GoogleFonts.poppins(color: Colors.white)),
          centerTitle: true,
          automaticallyImplyLeading: isAccepted,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Customer Info",
                  style: GoogleFonts.poppins(
                      color: Colors.yellow[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 8),
              _info("Name", orderData?['userName']),
              _info("Phone", orderData?['phone']),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _info("Address", orderData?['userAddress'])),
                  IconButton(
                    icon: const Icon(Icons.location_on, color: Colors.red),
                    onPressed: () {
                      final userLoc = orderData?['userLocation'];
                      if (userLoc != null) {
                        _launchCoordinates(userLoc['latitude'], userLoc['longitude']);
                      }
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.white30, height: 30),

              Text("Pickup from Restaurant",
                  style: GoogleFonts.poppins(
                      color: Colors.yellow[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 8),
              _info("Name", restaurantData?['name']),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _info("Address", restaurantData?['address'])),
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.green),
                    onPressed: () {
                      final pickupLoc = restaurantData?['pickupLocation'];
                      if (pickupLoc != null) {
                        _launchCoordinates(
                            pickupLoc['latitude'], pickupLoc['longitude']);
                      }
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.white30, height: 30),

              _info("Total Bill", "₹${orderData?['totalBill'].toStringAsFixed(2)}"),
              const SizedBox(height: 20),

              if (!isAccepted)
                ElevatedButton.icon(
                  onPressed: _acceptOrder,
                  icon: const Icon(Icons.check),
                  label: Text("Accept Order",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[800],
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),

              if (isAccepted && !showDeliverButton)
                Center(
                  child: Text("You have accepted this order",
                      style: GoogleFonts.poppins(
                          color: Colors.greenAccent, fontWeight: FontWeight.w600)),
                ),

              if (showDeliverButton)
                ElevatedButton.icon(
                  onPressed: _markAsDelivered,
                  icon: const Icon(Icons.done_all),
                  label: Text("Mark as Delivered",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: GoogleFonts.poppins(
              color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
          children: [
            TextSpan(
              text: value ?? 'N/A',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
