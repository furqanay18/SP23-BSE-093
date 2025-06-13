import 'package:flutter/material.dart';
import 'package:forkin/AsSeller/becomeseller/applyforrestaurent.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
// Change this to your next screen

class AppIntroScreen extends StatelessWidget {
  const AppIntroScreen({super.key});

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ApplyRestaurantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: " Chef? Nah. Owner",
          body: "Late nights, perfect plates – this one’s yours",
          image: Lottie.asset('lottie/chef.json'),
          decoration: getPageDecoration(),
        ),
        PageViewModel(
          title: "Gully ka flavour, city ka craze.",
          body: "Khaana wahi, level naya.",
          image: Lottie.asset('lottie/kitchen.json'),
          decoration: getPageDecoration(),
        ),
        PageViewModel(
          title: "Delivery on Point!",
          body: "Har box ke saath tera naam deliver hoga",
          image: Lottie.asset('lottie/delivery.json'),
          decoration: getPageDecoration(),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Get Started", style: TextStyle(fontWeight: FontWeight.bold)),
      dotsDecorator: getDotDecoration(),
    );
  }

  PageDecoration getPageDecoration() {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.pink.shade800,
      ),
      bodyTextStyle: const TextStyle(fontSize: 18),
      bodyPadding: const EdgeInsets.all(16), // ✅ use this instead of descriptionPadding
      imagePadding: const EdgeInsets.only(top: 40),
      pageColor: Colors.white,
    );
  }


  DotsDecorator getDotDecoration() => DotsDecorator(
    color: Colors.grey,
    activeColor: Colors.pink,
    size: const Size(10, 10),
    activeSize: const Size(22, 10),
    activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  );
}
