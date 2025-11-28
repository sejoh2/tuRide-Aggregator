import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:turide_aggregator/firebase_options.dart';
import 'package:turide_aggregator/pages/Home/ui/home_screen.dart';
import 'package:turide_aggregator/pages/landingpage.dart';

import 'package:turide_aggregator/pages/services%20offered/ui/schedule.dart';
import 'package:turide_aggregator/pages/services%20offered/ui/scheduled_ride_history.dart';

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
        '/scheduleridehistory': (context) => const ScheduledRideHistory(),
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is logged in → go to HomeScreen
          return const HomeScreen();
        }

        // User is NOT logged in → show LandingPage
        return const LandingPage();
      },
    );
  }
}
