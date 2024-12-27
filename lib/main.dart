import 'dart:async';
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';




import 'package:animated_text_kit/animated_text_kit.dart';
import 'firstscreen.dart';
import 'homepage.dart';
// import 'package:weather_app/homepage.dart';

void main() {
  // debugPaintSizeEnabled = true; // Enables debug paint
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WeatherApp()));
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //bacground imge
          Positioned.fill(
            child: Image.asset(
              "assets/bg.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.15, // Adjust as needed
            left: 50, // Adjust as neededjo
            right: 50, // Adjust as needed
    child: AnimatedTextKit(
      animatedTexts: [

        TyperAnimatedText('The Weather App',
          textStyle: GoogleFonts.pacifico
            (
            fontSize: 33,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),),
      ],
      onTap: () {
        print("I am executing");
      },
    ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0, // Ensures the button is horizontally centered
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>WeatherApp()));

                  },

                  child: Text("Get Started",style: GoogleFonts.nunito(
                      textStyle: TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.bold)
                  ),),
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}
