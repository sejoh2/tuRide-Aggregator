import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:turide_aggregator/main.dart';

class HomeDrawer extends StatelessWidget {
  final String? userName;
  const HomeDrawer({super.key, this.userName});

  // String userName = '';
  @override
  Widget build(BuildContext context) {
    final displayName = userName?.isNotEmpty == true ? userName! : 'User';

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFFC4FF00)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        displayName,
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Text(
                        'Welcome back!',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Schedule Ride'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/scheduleride');
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Scheduled Rides History'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/scheduleridehistory');
                  },
                ),
              ],
            ),
          ),

          // 🔥 Logout stays at bottom naturally
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => AuthWrapper()),
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
