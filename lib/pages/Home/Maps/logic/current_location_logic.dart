import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:turide_aggregator/pages/Home/Maps/logic/google_maps_service.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/places_logic.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrentLocationLogic {
  /// Get the user's real-time current location and convert to PlaceDetails
  static Future<PlaceDetails?> getCurrentPlaceDetails() async {
    final position = await GoogleMapsService().getCurrentLocation();
    if (position == null) return null;

    // Reverse Geocode the coordinates
    final details = await getPlaceDetailsFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return details;
  }

  /// Reverse-geocode lat/lng → PlaceDetails
  static Future<PlaceDetails?> getPlaceDetailsFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$lat,$lng'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final result = data['results'][0];

          return PlaceDetails(
            name: result['formatted_address'],
            formattedAddress: result['formatted_address'],
            latitude: lat,
            longitude: lng,
          );
        }
      }
    } catch (e) {
      print("Reverse geocode error: $e");
    }

    return null;
  }
}
