import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gta_6_comapnion_app/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    controller.forward();

   Timer(const Duration(seconds: 3), () {
  if (!mounted) return;

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => const Homepage(),
    ),
  );
});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        children: [

          Positioned.fill(
            child: Image.asset(
              "assets/images/splash_bg.png",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.65),
            ),
          ),

          FadeTransition(

            opacity: fadeAnimation,

            child: Column(
            
              children: [
            
                const Spacer(),
            
                
            
                const SizedBox(height: 50),
            
                Text(
                  "GTA 6 Companion",
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            
                const SizedBox(height: 10),
            
                Text(
                  "News • Maps • Quiz • Characters",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 17,
                  ),
                ),
            
                const SizedBox(height: 50),
            
                SizedBox(
                  width: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const LinearProgressIndicator(
                      minHeight: 6,
                      color: Colors.pinkAccent,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
            
                const SizedBox(height: 15),
            
                Text(
                  "Loading...",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
            
                const Spacer(),
            
                Text(
                  "Version 1.0",
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                  ),
                ),
            
                const SizedBox(height: 5),
            
                Text(
                  "© 2026 GTA 6 Companion",
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                  ),
                ),
            
                const SizedBox(height: 3),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "This app is an unofficial fan-made companion and is not affiliated with Rockstar Games or Take-Two Interactive.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ),
            
                const SizedBox(height: 25),
            
              ],
            ),
          ),
        ],
      ),
    );
  }
}