// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import 'package:tourist_app/pages/home.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? errorMessage;

  Future<bool> _updatePassword(String email, String newPassword) async {
    final dbPath = await getDatabasesPath();
    final path = "$dbPath/app.db";

    final db = await openDatabase(path);
    final result =
        await db.query('users', where: 'email = ?', whereArgs: [email]);

    if (result.isNotEmpty) {
      await db.update(
        'users',
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [email],
      );
      return true;
    }
    return false;
  }

  void _handlePasswordReset() async {
    final email = emailController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = 'All fields are required';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    final isUpdated = await _updatePassword(email, newPassword);

    if (isUpdated) {
      setState(() {
        errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully!')),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        errorMessage = 'Email does not exist';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Reset Password",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your email and new password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Email field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 221, 238, 239),
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  // New Password field
                  TextField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 221, 238, 239),
                      hintText: 'New Password',
                      hintStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password field
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 221, 238, 239),
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 40),
                  // Save button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handlePasswordReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 9, 9, 216),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
