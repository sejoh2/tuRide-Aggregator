import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turide_aggregator/pages/Auth/ui/my_button.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/places_logic.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/google_maps_service.dart';
import 'package:turide_aggregator/pages/Home/Maps/ui/google_map_widget.dart';
import 'package:turide_aggregator/pages/Home/Maps/ui/location_text_field.dart';
import 'package:turide_aggregator/pages/services%20offered/logic/schedule_deeplink.dart';
import 'package:turide_aggregator/pages/services%20offered/logic/schedule_pricing_logic.dart';
import 'package:turide_aggregator/pages/services%20offered/ui/platform_dropdown.dart';
import 'package:turide_aggregator/pages/services%20offered/logic/schedule_ride_logic.dart';

class ScheduleRide extends StatefulWidget {
  const ScheduleRide({super.key});

  @override
  State<ScheduleRide> createState() => _ScheduleRideState();
}

class _ScheduleRideState extends State<ScheduleRide> {
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();
  final ScheduleRideLogic _scheduleLogic = ScheduleRideLogic();

  PlaceDetails? selectedPickupPlace;
  PlaceDetails? selectedDestinationPlace;
  RouteData? routeData;
  String? selectedPlatform;
  EstimatedPrice? estimatedPrice;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isLoadingRoute = false;
  bool isSavingRide = false;

  // Method to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Method to show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Get formatted date string
  String get formattedDate {
    if (selectedDate == null) return 'Select Date';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  // Get formatted time string
  String get formattedTime {
    if (selectedTime == null) return 'Select Time';
    return selectedTime!.format(context);
  }

  // Combine date and time into DateTime
  DateTime get scheduledDateTime {
    if (selectedDate == null || selectedTime == null) {
      return DateTime.now();
    }
    return DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
  }

  void _onPickupSelected(PlaceDetails details) {
    setState(() {
      selectedPickupPlace = details;
    });
    print('Pickup selected: ${details.formattedAddress}');
    print('Coordinates: ${details.latitude}, ${details.longitude}');

    // Calculate route automatically when both locations are selected
    _calculateRouteIfBothLocationsSelected();
  }

  void _onDestinationSelected(PlaceDetails details) {
    setState(() {
      selectedDestinationPlace = details;
    });
    print('Destination selected: ${details.formattedAddress}');
    print('Coordinates: ${details.latitude}, ${details.longitude}');

    // Calculate route automatically when both locations are selected
    _calculateRouteIfBothLocationsSelected();
  }

  void _calculateRouteIfBothLocationsSelected() {
    if (selectedPickupPlace != null && selectedDestinationPlace != null) {
      _calculateRoute();
    } else {
      // Clear route if one location is missing
      setState(() {
        routeData = null;
        estimatedPrice = null;
      });
    }
  }

  void _updateEstimatedPrice() {
    if (routeData != null && selectedPlatform != null) {
      setState(() {
        estimatedPrice = PricingLogic.calculatePrice(
          platform: selectedPlatform!,
          distance: routeData!.distance,
          duration: routeData!.duration,
        );
      });
    } else {
      setState(() {
        estimatedPrice = null;
      });
    }
  }

  Future<void> _calculateRoute() async {
    if (selectedPickupPlace == null || selectedDestinationPlace == null) {
      return;
    }

    setState(() {
      isLoadingRoute = true;
    });

    try {
      final route = await GoogleMapsService.getRoute(
        origin: selectedPickupPlace!,
        destination: selectedDestinationPlace!,
      );

      setState(() {
        routeData = route;
      });

      if (route != null) {
        print('Route calculated: ${route.distance}, ${route.duration}');
        // Update estimated price after route calculation
        _updateEstimatedPrice();
      } else {
        print('Failed to calculate route');
      }
    } catch (e) {
      print('Error calculating route: $e');
    } finally {
      setState(() {
        isLoadingRoute = false;
      });
    }
  }

  Future<void> _saveRideToFirestore() async {
    if (selectedPickupPlace == null ||
        selectedDestinationPlace == null ||
        routeData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for route calculation to complete'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate date and time
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time for your ride'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate that selected date/time is in the future
    final now = DateTime.now();
    final scheduledTime = scheduledDateTime;
    if (scheduledTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSavingRide = true;
    });

    try {
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      final scheduledRide = ScheduledRide(
        userId: currentUserId,
        pickupName: selectedPickupPlace!.name,
        pickupAddress: selectedPickupPlace!.formattedAddress,
        pickupLat: selectedPickupPlace!.latitude,
        pickupLng: selectedPickupPlace!.longitude,
        destinationName: selectedDestinationPlace!.name,
        destinationAddress: selectedDestinationPlace!.formattedAddress,
        destinationLat: selectedDestinationPlace!.latitude,
        destinationLng: selectedDestinationPlace!.longitude,
        platform: selectedPlatform,
        distance: routeData!.distance,
        duration: routeData!.duration,
        estimatedPrice: estimatedPrice?.total ?? 0.0,
        currency: 'KES',
        scheduledAt: scheduledDateTime, // Use the combined date and time
      );

      final rideId = await _scheduleLogic.saveScheduledRide(scheduledRide);

      if (rideId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ride scheduled successfully for $formattedDate at $formattedTime! Price: ${estimatedPrice?.formattedTotal ?? 'N/A'}',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Add 2-second delay before launching deep link
        await Future.delayed(const Duration(milliseconds: 50));

        // Launch the ride platform app with deep link
        try {
          await ScheduleDeepLink.launchRideApp(
            platform: selectedPlatform!,
            pickupLat: selectedPickupPlace!.latitude,
            pickupLng: selectedPickupPlace!.longitude,
            pickupAddress: selectedPickupPlace!.formattedAddress,
            destinationLat: selectedDestinationPlace!.latitude,
            destinationLng: selectedDestinationPlace!.longitude,
            destinationAddress: selectedDestinationPlace!.formattedAddress,
          );
        } catch (e) {
          print('Error launching ride app: $e');
          // Don't show error to user - it's optional functionality
        }

        // Clear the form after successful scheduling
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to schedule ride. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error saving ride to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isSavingRide = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      pickupController.clear();
      destinationController.clear();
      selectedPickupPlace = null;
      selectedDestinationPlace = null;
      routeData = null;
      selectedPlatform = null;
      estimatedPrice = null;
      selectedDate = null;
      selectedTime = null;
    });
  }

  void _onScheduleRide() async {
    if (selectedPickupPlace == null || selectedDestinationPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both pickup and destination locations'),
        ),
      );
      return;
    }

    if (routeData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for route calculation to complete'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPlatform == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a ride platform'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save to Firestore
    await _saveRideToFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Schedule your ride'))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: screenWidth,
              height: screenHeight * 0.36,
              child: Stack(
                children: [
                  GoogleMapWidget(
                    routeData: routeData,
                    pickup: selectedPickupPlace,
                    destination: selectedDestinationPlace,
                  ),
                  if (isLoadingRoute)
                    Container(
                      color: Colors.black54,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ALWAYS show the route info card (with placeholders when no data)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // First row: Distance and Estimated Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoColumn(
                            title: 'Distance',
                            value: routeData?.distance ?? '....',
                            isCalculated: routeData != null,
                          ),
                          _buildInfoColumn(
                            title: 'Est. Time',
                            value: routeData?.duration ?? '....',
                            isCalculated: routeData != null,
                          ),
                        ],
                      ),

                      // Divider between the two rows
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),

                      // Second row: Estimated Price
                      _buildPriceRow(
                        value: estimatedPrice?.formattedTotal ?? '....',
                        isCalculated: estimatedPrice != null,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            PlatformDropdown(
              value: selectedPlatform,
              onChanged: (val) {
                setState(() => selectedPlatform = val);
                // Update price when platform changes
                _updateEstimatedPrice();
              },
            ),

            const SizedBox(height: 10),

            // Date and Time Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Date Picker
                  Expanded(
                    child: _buildDateTimeButton(
                      icon: Icons.calendar_today,
                      text: formattedDate,
                      onTap: () => _selectDate(context),
                      isSelected: selectedDate != null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Time Picker
                  Expanded(
                    child: _buildDateTimeButton(
                      icon: Icons.access_time,
                      text: formattedTime,
                      onTap: () => _selectTime(context),
                      isSelected: selectedTime != null,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            LocationTextField(
              hintText: 'Pick Up Location',
              prefixIcon: const Icon(Icons.location_pin),
              controller: pickupController,
              obscureText: false,
              onPlaceSelected: _onPickupSelected,
            ),

            const SizedBox(height: 10),

            LocationTextField(
              hintText: 'Destination',
              prefixIcon: const Icon(Icons.location_pin),
              controller: destinationController,
              obscureText: false,
              onPlaceSelected: _onDestinationSelected,
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: MyButton(
                text: isSavingRide ? 'Scheduling...' : 'Schedule Ride',
                onTap: isSavingRide ? null : _onScheduleRide,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.grey.shade400 : Colors.grey.shade600,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.black : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn({
    required String title,
    required String value,
    required bool isCalculated,
  }) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isCalculated ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow({required String value, required bool isCalculated}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.attach_money, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        Text(
          'Estimated Price: ',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isCalculated ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
