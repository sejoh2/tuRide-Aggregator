import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:turide_aggregator/pages/Auth/ui/my_button.dart';
import 'package:turide_aggregator/pages/Finding%20best%20prices/ui/finding_best_prices_tile.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/logic/places_logic.dart';
import 'package:turide_aggregator/pages/Home/Maps/ui/location_text_field.dart';
import 'package:turide_aggregator/pages/Home/ui/schedule_ride_tile.dart';
import 'package:turide_aggregator/pages/Home/ui/suggestions_tile.dart';
import 'package:turide_aggregator/pages/Home/Maps/ui/google_map_widget.dart';
import 'package:turide_aggregator/pages/rides/ui/rides_result.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 👇 Add `with RouteAware`
class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();

  PlaceDetails? selectedPickupPlace;
  PlaceDetails? selectedDestinationPlace;

  String userName = '';
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userName = doc['name'] ?? 'User';
          isLoadingUser = false; // 🔹 stop shimmer
        });
      }
    } else {
      setState(() {
        userName = 'User';
        isLoadingUser = false; // 🔹 stop shimmer
      });
    }
  }

  @override
  void dispose() {
    // 👇 Always dispose controllers to prevent memory leaks
    pickupController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: isLoadingUser
            ? Shimmer.fromColors(
                baseColor: Colors.white54,
                highlightColor: Colors.white,
                child: Container(width: 150, height: 20, color: Colors.grey),
              )
            : Text('Welcome $userName'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: screenWidth,
              height: screenHeight * 0.36,
              child: const GoogleMapWidget(),
            ),

            const SizedBox(height: 20),

            LocationTextField(
              hintText: 'Pick up Location',
              prefixIcon: Icon(Icons.location_pin),
              controller: pickupController,
              obscureText: false,
              onPlaceSelected: (PlaceDetails details) {
                setState(() {
                  selectedPickupPlace = details;
                });
                print('Pickup selected: ${details.formattedAddress}');
                print('Coordinates: ${details.latitude}, ${details.longitude}');
              },
            ),

            const SizedBox(height: 10),

            LocationTextField(
              hintText: 'Destination',
              prefixIcon: Icon(Icons.location_pin),
              controller: destinationController,
              obscureText: false,
              onPlaceSelected: (PlaceDetails details) {
                setState(() {
                  selectedDestinationPlace = details;
                });
                print('Destination selected: ${details.formattedAddress}');
                print('Coordinates: ${details.latitude}, ${details.longitude}');
              },
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('SUGGESTIONS'),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SuggestionTile(),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MyButton(
                text: 'Search Rides',
                onTap: () async {
                  // Validate that both locations are selected
                  if (selectedPickupPlace == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a pickup location'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Show the dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const FindingBestPricesDialog(),
                  );

                  // Simulate some loading time (e.g., API call)
                  await Future.delayed(const Duration(seconds: 3));

                  if (selectedDestinationPlace == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a destination'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Close the dialog after loading
                  Navigator.pop(context);

                  // Navigate to results page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RidesResult(
                        pickupPlace: selectedPickupPlace!,
                        destinationPlace: selectedDestinationPlace!,
                      ),
                    ),
                  ).then((_) {
                    // 👇 Clear text fields when returning to HomeScreen
                    pickupController.clear();
                    destinationController.clear();

                    // 👇 Reset selected places so validation works properly next time
                    setState(() {
                      selectedPickupPlace = null;
                      selectedDestinationPlace = null;
                    });
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ScheduleRideTile(),
            ),
          ],
        ),
      ),
    );
  }
}
