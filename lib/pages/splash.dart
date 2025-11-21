import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart';
import '../services/api_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String quote = "Loading...";
  final int maxQuoteLength = 100;

  @override
  void initState() {
    super.initState();

    // Ambil kata motivasi dari API sekali saat splash screen muncul
    _fetchMotivation();

    // Progress bar animasi 3 detik
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    // Navigasi ke LoginPage setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  Future<void> _fetchMotivation() async {
    String fetchedQuote = await ApiService.fetchRandomMotivation(maxLength: maxQuoteLength);
    setState(() {
      quote = fetchedQuote;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset("assets/images/logo.png", width: 120),
            ),
            const SizedBox(height: 40),
            const Text(
              "PersonaList",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Kata motivasi dari API
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                quote,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),
            // Progress bar
            SizedBox(
              width: 130,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}