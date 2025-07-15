import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:CustoWheel/screens/home_screen.dart';
import 'package:CustoWheel/screens/login_screen.dart'; // Ensure you have this

class ImageSplash extends StatefulWidget {
  const ImageSplash({super.key});

  @override
  State<ImageSplash> createState() => _ImageSplashState();
}

class _ImageSplashState extends State<ImageSplash> {
  @override
  @override
void initState() {
  super.initState();
  Timer(const Duration(seconds: 3), () {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginDemo1()),
      );
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B33),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
         children: [
  Image.asset('assets/images/logo.png'),
  SizedBox(height: 10),
  Text(
  "CustoWheel",
  style: GoogleFonts.roboto( // Using GoogleFonts.roboto()
    fontSize: 40,
    color: Colors.white,
    fontWeight: FontWeight.bold, // You can easily add more styles
  ),
),
  SizedBox(height: 30),
  Text(
    "DEVELOPED BY A.S.E.P ❤️ ",
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white, // 👈 Changed to white
    ),
  ),
],

        ),
      ),
    );
  }
}
