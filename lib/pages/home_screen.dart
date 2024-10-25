// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 11, 1, 45),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Name"),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud),
              title: Text('Weather'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.translate),
              title: Text('Translator'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.pushNamed(context, "/edit_profile");
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 11, 1, 45),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu_open_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Center(
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: buildCategoryCard(
                      context,
                      title: 'Entertainment',
                      color: Colors.blue,
                      widthFactor: 1.0,
                      info: 'Information about Entertainment',
                      onTap: () {
                        Navigator.pushNamed(context, "/entertainment");
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 100,
                    child: buildCategoryCard(
                      context,
                      title: 'Historical',
                      color: Colors.pink,
                      widthFactor: 0.85,
                      info: 'Information about Historical',
                      onTap: () {},
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 200,
                    child: buildCategoryCard(
                      context,
                      title: 'Cultural',
                      color: Colors.orange,
                      widthFactor: 0.7,
                      info: 'Information about Cultural',
                      onTap: () {},
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 300,
                    child: buildCategoryCard(
                      context,
                      title: 'Religion',
                      color: Colors.blueAccent,
                      widthFactor: 0.55,
                      info: 'Information about Religion',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Mic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'FAQ\'s',
          ),
        ],
      ),
    );
  }

  Widget buildCategoryCard(BuildContext context,
      {required String title,
      required Color color,
      required double widthFactor,
      required String info,
      required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * widthFactor,
        height: 150,
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('$title Info'),
                      content: Text(info),
                      actions: [
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
