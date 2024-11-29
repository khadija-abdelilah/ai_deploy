import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_deploy/Pages/LoginPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = auth.currentUser; // Get the current user
  }

  signOut() async {
    await auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        // Use BoxDecoration for a full background image
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/img.png'),
            fit: BoxFit.cover, // Ensure the entire image fits the background
          ),
        ),
        child: Column(
          children: [
            const Spacer(), // Pushes content to the middle of the screen
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Explore our Models',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white, // Ensure text is visible
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(currentUser?.displayName ?? "User Name"),
              accountEmail: Text(currentUser?.email ?? "user@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  _getUserInitials(currentUser?.displayName),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.indigo,
              ),
            ),
            ExpansionTile(
              title: const Text('Image Classification'),
              leading: const Icon(Icons.image),
              children: [
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('ANN'),
                  onTap: () {
                    Navigator.pushNamed(context, '/ann');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('CNN'),
                  onTap: () {
                    Navigator.pushNamed(context, '/cnn');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('RNN'),
                  onTap: () {
                    Navigator.pushNamed(context, '/rnn');
                  },
                ),
              ],
            ),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: () {
                signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to extract initials
  String _getUserInitials(String? name) {
    if (name == null || name.isEmpty) return "U";
    List<String> names = name.split(" ");
    String initials = names.map((name) => name[0]).join();
    return initials.length > 2 ? initials.substring(0, 2).toUpperCase() : initials.toUpperCase();
  }
}
