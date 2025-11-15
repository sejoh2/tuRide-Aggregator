import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:turide_aggregator/firebase_options.dart';
import 'package:turide_aggregator/pages/Auth/sign_up_or_sign_in_toggle.dart';
import 'package:turide_aggregator/pages/Home/ui/home_screen.dart';
import 'package:turide_aggregator/pages/services%20offered/ui/schedule.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'tuRide',
      home: const AuthWrapper(), // 👈 handle login state here
      routes: {
        '/homescreen': (context) => const HomeScreen(),
        '/scheduleride': (context) => const ScheduleRide(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // 👈 watches auth state
      builder: (context, snapshot) {
        // 🕐 Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 👤 User is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // 🚪 User is NOT logged in
        return const LoginOrRegisterPage();
      },
    );
  }
}
