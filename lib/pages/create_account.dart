import 'package:flutter/material.dart';
import 'package:tourist_app/pages/database.dart';

class TravelTideApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CreateAccountScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  String? errorMessage;

  bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  void _validateAndSubmit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final name = nameController.text.trim();
    final country = countryController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        name.isEmpty ||
        country.isEmpty) {
      setState(() {
        errorMessage = 'All fields are required';
      });
      return;
    }

    if (!isValidEmail(email)) {
      setState(() {
        errorMessage = 'Invalid email format';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      errorMessage = null;
    });

    try {
      final isEmailTaken = await DatabaseHelper.instance.isEmailExists(email);
      if (isEmailTaken) {
        setState(() {
          errorMessage = 'Email already exists. Please use a different email.';
        });
        return;
      }

      await DatabaseHelper.instance.insertUser({
        'email': email,
        'password': password,
        'name': name,
        'country': country,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      nameController.clear();
      countryController.clear();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to create account: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final users = await DatabaseHelper.instance.getAllUsers();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Database Content'),
                        content: SingleChildScrollView(
                          child: Text(users.isNotEmpty
                              ? users
                                  .map((user) => user.toString())
                                  .join('\n\n')
                              : 'No users found in the database.'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching data: $e')),
                    );
                  }
                },
                child: const Text('Show Database Content'),
              ),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              _buildTextField(emailController, 'Email'),
              const SizedBox(height: 20),
              _buildTextField(passwordController, 'Password',
                  obscureText: true),
              const SizedBox(height: 20),
              _buildTextField(confirmPasswordController, 'Confirm Password',
                  obscureText: true),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),
              _buildTextField(nameController, 'Name'),
              const SizedBox(height: 20),
              _buildTextField(countryController, 'Country/Region'),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 9, 9, 216),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Center(
                  child: Text(
                    'Sign up',
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
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 221, 238, 239),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
    );
  }
}
