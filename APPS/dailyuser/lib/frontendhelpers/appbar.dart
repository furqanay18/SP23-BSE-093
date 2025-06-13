import 'package:flutter/material.dart';

class CustomCurvedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String inventoryName;
  final double height;

  const CustomCurvedAppBar({
    super.key,
    required this.inventoryName,
    this.height = 70, // Reduced height
  });

  @override
  Size get preferredSize => Size.fromHeight(height + 20);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: preferredSize.height,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(double.infinity, height + 20),
            painter: CurvedPainter(),
          ),
          Positioned(
            top: topPadding + 8,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: topPadding + 18),
              child: Text(
                inventoryName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final double curveHeight = 40; // More prominent curve

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(0, size.height, curveHeight, size.height)
      ..lineTo(size.width - curveHeight, size.height)
      ..quadraticBezierTo(size.width, size.height, size.width, size.height - curveHeight)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawShadow(path, Colors.black54, 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
