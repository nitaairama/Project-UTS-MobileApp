import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'pages/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB(); // Inisialisasi SQLite
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Dominan biru
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashPage(),
    );
  }
}