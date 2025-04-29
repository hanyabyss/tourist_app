// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:tourist_app/pages/attractions_page.dart';
import 'package:tourist_app/pages/create_account.dart';
import 'package:tourist_app/pages/edit_profile.dart';
import 'package:tourist_app/pages/home.dart';
import 'package:tourist_app/pages/home_screen.dart';
import 'package:tourist_app/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourist_app/pages/map.dart';
import 'package:tourist_app/pages/translator.dart';
import 'package:tourist_app/pages/weather.dart';
import 'package:tourist_app/pages/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initializeDatabase();
  print('Database initialized successfully.');

  // تحقق من حالة تسجيل الدخول
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getString('email') != null;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLoggedIn ? HomeScreen() : home(title: ''),
      routes: {
        //'/': (context) => home(title: ''),
        "/login": (context) => LoginScreen(),
        "/weather": (context) => WeatherPage(),
        "/map": (context) => MapScreen(),
        "/create_account": (context) => CreateAccountScreen(),
        "/translator_page": (context) => TranslatorApp(),
        "/home_screen": (context) => HomeScreen(),
        "/edit_profile": (context) {
          final user = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          if (user == null) {
            return Scaffold(
              body: Center(
                child: Text('No user data provided.'),
              ),
            );
          }
          return EditProfileScreen(user: user);
        },
        '/Entertainment': (ctx) => AttractionsPage(type: 'Entertainment'),
        '/Historical': (ctx) => AttractionsPage(type: 'Historical'),
        '/Cultural': (ctx) => AttractionsPage(type: 'Cultural'),
        '/Religion': (ctx) => AttractionsPage(type: 'Religion'),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
