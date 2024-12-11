import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  FirebaseAuth auth = FirebaseAuth.instance;
  User? currentUser;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    currentUser = auth.currentUser; // Get the current user
  }

  Future<void> _pickImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          setState(() {
            profileImage = reader.result as String;
          });
        });

        reader.readAsDataUrl(files[0]);
      }
    });
  }

  signOut() async {
    await auth.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage())
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
          // Background Image with color overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/img_1.png'),
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
                      Text(
                        'Choose an option from the menu',
                        style: const TextStyle(
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

  // Side Drawer with Profile, Menu, and Logout Button
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
                backgroundImage: profileImage != null
                    ? NetworkImage(profileImage!)
                    : null,
                backgroundColor: Colors.blue,
                child: profileImage == null
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
                Navigator.pushNamed(context, '/assistant'); // Navigate to Assistant
              },
            ),
          ]),
          const Divider(),
          ListTile(
            title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              signOut();
            },
          ),
        ],
      ),
    );
  }

  // Menu Section for ANN, CNN, RNN, etc.
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

  // Menu Item
  Widget _menuItem(BuildContext context, String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }

  // Extract initials from name
  String _getUserInitials(String? name) {
    if (name == null || name.isEmpty) return "U";
    List<String> names = name.split(" ");
    String initials = names.map((name) => name[0]).join();
    return initials.length > 2 ? initials.substring(0, 2).toUpperCase() : initials.toUpperCase();
  }
}
