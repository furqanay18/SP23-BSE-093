import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:forkin/main.dart';

class CompleteSplashScreen extends StatefulWidget {
  @override
  _CompleteSplashScreenState createState() => _CompleteSplashScreenState();
}

class _CompleteSplashScreenState extends State<CompleteSplashScreen> with TickerProviderStateMixin {
  int stage = 1;
  late AnimationController _glowController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6), // smoother circular motion
    )..repeat();

    Timer(Duration(seconds: 4), () => setState(() => stage = 2));
    Timer(Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthGate()),
      );
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 800),
        child: stage == 1 ? _stageOne() : _stageTwo(),
      ),
    );
  }

  /// --------- STAGE 1 ----------
  Widget _stageOne() {
    return Container(
      key: ValueKey(1),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Colors.black, Colors.deepOrange.shade900.withOpacity(0.5)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) {
                final glow = 20 + (_glowController.value * 30);
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.8),
                        blurRadius: glow,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'data:image/png;base64,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', // Example burger+fries image
                      fit: BoxFit.cover,
                      height: 80,
                      width: 80,
                      errorBuilder: (_, __, ___) => Icon(Icons.fastfood, size: 60, color: Colors.orange),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Colors.orange, Colors.redAccent],
                ).createShader(bounds);
              },
              child: Text(
                "forkin",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Tasty deliveries, faster!",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// --------- STAGE 2 ----------
  Widget _stageTwo() {
    return Container(
      key: ValueKey(2),
      padding: EdgeInsets.all(20),
      child: Stack(
        children: [
          _floatingEmoji('🍕', 180, 0),
          _floatingEmoji('🍔', 200, pi / 2),
          _floatingEmoji('🍟', 180, pi),
          _floatingEmoji('🥤', 200, 3 * pi / 2),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Colors.deepOrange, Colors.red, Colors.pink],
                    ).createShader(bounds);
                  },
                  child: Text(
                    "FoodieExpress",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Bringing taste to your doorstep.",
                  style: TextStyle(color: Colors.grey[300], fontSize: 16),
                ),
                SizedBox(height: 40),
                _glowingPulseBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Glowing loading bar
  Widget _glowingPulseBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.1, end: 1),
      duration: Duration(seconds: 3),
      builder: (context, value, _) {
        return Container(
          width: 200,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.pink],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrangeAccent.withOpacity(0.7),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Floating emojis in smooth circular path
  Widget _floatingEmoji(String emoji, double radius, double angleOffset) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, __) {
        double angle = (_floatController.value * 2 * pi) + angleOffset;
        double x = radius * cos(angle);
        double y = radius * sin(angle);

        double scale = 1 + 0.2 * sin(_floatController.value * 2 * pi);
        double rotation = _floatController.value * 2 * pi;

        return Positioned(
          left: MediaQuery.of(context).size.width / 2 + x - 20,
          top: MediaQuery.of(context).size.height / 2 + y - 20,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Text(
                emoji,
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
        );
      },
    );
  }
}
