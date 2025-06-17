import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApplyForDriverScreen extends StatelessWidget {
  const ApplyForDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Apply for Driver',
            style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delivery_dining, size: 64, color: Colors.yellow),
                  const SizedBox(height: 16),
                  Text(
                    'Want to become a delivery driver?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap below to apply. Our admin will review and approve your request.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[800],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text('Apply Now',
                        style: GoogleFonts.poppins(fontSize: 16)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Request sent to admin!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Later: Update user doc in Firestore with driver request flag.
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
