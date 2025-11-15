import 'package:flutter/material.dart';
import 'package:turide_aggregator/services/deep_link_service.dart';

class RideTile extends StatelessWidget {
  final String name;
  final String passengers;
  final String wait;
  final String price;
  final String oldPrice;

  // Coordinates for pickup and dropoff
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;

  const RideTile({
    super.key,
    required this.name,
    required this.passengers,
    required this.wait,
    required this.price,
    required this.oldPrice,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
  });

  // Map ride names to online image URLs
  String _getRideIconUrl(String rideName) {
    switch (rideName.toLowerCase()) {
      case 'bolt':
        return 'https://pnghdpro.com/wp-content/themes/pnghdpro/download/social-media-and-brands/bolt-taxi-app-icon.png';
      case 'uber':
        return 'https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/uber-icon.png';
      case 'lyft':
        return 'https://pnghdpro.com/wp-content/themes/pnghdpro/download/social-media-and-brands/lyft-app-icon.png';
      default:
        return 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Question_mark_alternate.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconUrl = _getRideIconUrl(name);

    return GestureDetector(
      onTap: () {
        // Open the corresponding ride app
        DeepLinkService.openRideApp(
          name,
          pickupLat,
          pickupLng,
          dropoffLat,
          dropoffLng,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Use ClipOval + Image.network for better fit
                ClipOval(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.network(
                      iconUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.directions_car, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "$passengers | wait $wait",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
