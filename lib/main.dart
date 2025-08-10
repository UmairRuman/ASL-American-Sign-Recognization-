import 'package:asl_alphabet_recognition/asl_home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ASLApp());
}

class ASLApp extends StatelessWidget {
  const ASLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASL Alphabet Recognition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
      home: const ASLHomePage(),
    );
  }
}
