import 'package:flutter/material.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/current_location_logic.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/places_logic.dart';
import 'location_text_field.dart';

class AutoPickupLocationField extends StatefulWidget {
  final Function(PlaceDetails) onPlaceSelected;

  const AutoPickupLocationField({super.key, required this.onPlaceSelected});

  @override
  State<AutoPickupLocationField> createState() =>
      _AutoPickupLocationFieldState();
}

// 1. Add WidgetsBindingObserver mixin
class _AutoPickupLocationFieldState extends State<AutoPickupLocationField>
    with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  bool _loadingAddress = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 2. Add observer
    _setInitialPickupLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 3. Remove observer
    _controller.dispose();
    super.dispose();
  }

  // 4. Implement lifecycle observer method to handle app resume
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-run location detection when the app returns, ensuring it gets the
      // location if permission was just granted.
      _setInitialPickupLocation();
    }
  }

  Future<void> _setInitialPickupLocation() async {
    // Reset state to show loading indicator again
    setState(() {
      _loadingAddress = true;
      // Set a placeholder text while loading/re-detecting
      if (_controller.text.isEmpty) {
        _controller.text = "Detecting your location...";
      }
    });

    final details = await CurrentLocationLogic.getCurrentPlaceDetails();

    if (!mounted) return;

    if (details != null) {
      setState(() {
        _controller.text = details.formattedAddress;
        _loadingAddress = false;
      });

      // Notify parent HomeScreen
      widget.onPlaceSelected(details);
    } else {
      setState(() {
        // Only clear the text if it was the "Detecting..." placeholder or failed initially
        if (_controller.text == "Detecting your location..." ||
            _controller.text.isEmpty) {
          _controller.text = '';
        }
        _loadingAddress = false;
      });
      // Location detection failed (likely permission denied or service disabled)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocationTextField(
          hintText: "Pick up Location",
          prefixIcon: const Icon(Icons.my_location, color: Colors.green),
          obscureText: false,
          controller: _controller,
          onPlaceSelected: widget.onPlaceSelected,
          // 🛑 FIX: 'readOnly' is not defined in LocationTextField.
          // Removed the problematic parameter call to fix compilation.
        ),

        // Show the loading text only when actively loading (for visual clarity)
        if (_loadingAddress)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Detecting your current location...",
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
