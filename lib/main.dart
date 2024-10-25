// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tourist_app/pages/create_account.dart';
import 'package:tourist_app/pages/edit_profile.dart';
import 'package:tourist_app/pages/entertainment.dart';
import 'package:tourist_app/pages/home.dart';
import 'package:tourist_app/pages/home_screen.dart';
import 'package:tourist_app/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => home(
              title: '',
            ),
        "/login": (context) => LoginScreen(),
        "/create_account": (context) => CreateAccountScreen(),
        "/home_screen": (context) => HomeScreen(),
        '/splash_screen': (context) => SplashScreen(),
        "/edit_profile": (context) => EditProfileScreen(),
        "/entertainment": (context) => EntertainmentTripPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
