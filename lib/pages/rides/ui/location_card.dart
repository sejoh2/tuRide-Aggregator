import 'package:flutter/material.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/logic/places_logic.dart';

class LocationCard extends StatelessWidget {
  final PlaceDetails? pickupPlace;
  final PlaceDetails? destinationPlace;

  const LocationCard({super.key, this.pickupPlace, this.destinationPlace});

  @override
  Widget build(BuildContext context) {
    // Don't show the card if neither location is selected
    if (pickupPlace == null && destinationPlace == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pickup Location Row
          if (pickupPlace != null) ...[
            Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickupPlace!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        pickupPlace!.formattedAddress,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (destinationPlace != null) const SizedBox(height: 8),
          ],

          // Destination Location Row
          if (destinationPlace != null) ...[
            Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.purpleAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destinationPlace!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        destinationPlace!.formattedAddress,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
