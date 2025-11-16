import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PlacesLogic {
  static Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$query'
        '&key=$apiKey'
        '&types=establishment|geocode'
        '&components=country:ke', // Changed to Kenya (KE)
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return (data['predictions'] as List)
              .map((prediction) => PlaceSuggestion.fromJson(prediction))
              .toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=name,formatted_address,geometry'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        }
      }
    } catch (e) {
      print('Error getting place details: $e');
    }

    return null;
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']['main_text'],
      secondaryText: json['structured_formatting']['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      name: json['name'],
      formattedAddress: json['formatted_address'],
      latitude: json['geometry']['location']['lat'].toDouble(),
      longitude: json['geometry']['location']['lng'].toDouble(),
    );
  }
}
