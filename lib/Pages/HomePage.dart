import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
// NO 'dart:io' import for web

import 'package:ai_deploy/Pages/LoginPage.dart';
import 'package:ai_deploy/Pages/Ann.dart';
import 'package:ai_deploy/Pages/Cnn.dart';
import 'package:ai_deploy/Pages/Rnn.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? currentUser;

  /// Instead of storing the file path, we store a MemoryImage
  /// for Flutter Web usage.
  MemoryImage? _profileImage;

  @override
  void initState() {
    super.initState();
    currentUser = auth.currentUser;
  }

  /// Picks an image from the gallery using the image_picker plugin (Web-compatible).
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // For Web, read the bytes and create a MemoryImage
      final imageBytes = await pickedFile.readAsBytes();

      setState(() {
        _profileImage = MemoryImage(imageBytes);
      });
    }
  }

  /// Signs the user out and navigates back to LoginPage.
  Future<void> signOut() async {
    await auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/img_1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Row(
            children: [
              // Side Drawer
              _buildSideDrawer(context),
              // Main Content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome, ${currentUser?.displayName ?? "User"}!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Choose an option from the menu',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the side drawer with profile image, menus, and logout.
  Widget _buildSideDrawer(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(2, 0),
            blurRadius: 20,
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentUser?.displayName ?? "User Name"),
            accountEmail: Text(currentUser?.email ?? "user@example.com"),
            currentAccountPicture: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                // For web, use MemoryImage if available
                backgroundImage: _profileImage,
                child: _profileImage == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _buildMenuSection('Image Classification', Icons.image, [
            _menuItem(context, 'ANN', Icons.category, const AnnPage()),
            _menuItem(context, 'CNN', Icons.category, const CnnPage()),
            _menuItem(context, 'RNN', Icons.category, const RnnPage()),
          ]),
          _buildMenuSection('Assistant Vocal', Icons.mic, [
            ListTile(
              leading: const Icon(Icons.mic, color: Colors.indigo),
              title: const Text('Start Assistant'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/assistant');
              },
            ),
          ]),
          const Divider(),
          ListTile(
            title: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            onTap: () {
              Navigator.pop(context);
              signOut();
            },
          ),
        ],
      ),
    );
  }

  /// Builds an expandable menu section with sub-items.
  Widget _buildMenuSection(String title, IconData icon, List<Widget> children) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: children,
    );
  }

  /// Builds a single menu item that navigates to a given page.
  Widget _menuItem(BuildContext context, String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
