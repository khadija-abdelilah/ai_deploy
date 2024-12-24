import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

// Import de vos pages
import 'Pages/HomePage.dart';
import 'Pages/LoginPage.dart';
import 'Pages/AudioRecorderPage.dart';
import 'Pages/Ann.dart';
import 'Pages/Cnn.dart';
import 'Pages/Rnn.dart';
import 'Services/otp_page.dart';
import 'Services/reset_password.dart';
import 'Pages/CreateProfilePage.dart';
import 'Pages/SignupPage.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Deploy',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      // Première page à afficher
      initialRoute: '/',
      // Déclarer ici toutes les routes nommées
      routes: {
        '/': (context) => const AuthWrapper(),            // Authentification initiale
        '/home': (context) => const MyHomePage(title: "HomePage"),
        '/assistant': (context) => AudioRecorderPage(),
        '/ann': (context) => const AnnPage(),
        '/cnn': (context) => const CnnPage(),
        '/rnn': (context) => const RnnPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/createProfile': (context) => CreateProfilePage(),
        '/resetPassword': (context) => RESETpasswordPage(),

        // Pour l’OTP, on peut passer des arguments dynamiques.
        // Exemple : Navigator.pushNamed(context, '/otp', arguments: {...});
        '/otp': (context) => const OTPPage(
          id: null,     // param par défaut, on injectera via `arguments`
          phone: '',
        ),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          // User is logged in
          return const MyHomePage(title: "HomePage");
        }
        // User is not logged in
        return const LoginPage();
      },
    );
  }
}
