import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'logic/places_logic.dart';

class GoogleMapsService {
  // Existing location functionality
  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // New route drawing functionality
  static Future<RouteData?> getRoute({
    required PlaceDetails origin,
    required PlaceDetails destination,
  }) async {
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$apiKey'
        '&mode=driving'
        '&alternatives=true',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          return RouteData.fromJson(data['routes'][0], origin, destination);
        }
      }
    } catch (e) {
      print('Error getting route: $e');
    }

    return null;
  }

  static Set<Marker> createMarkers({
    required PlaceDetails pickup,
    required PlaceDetails destination,
  }) {
    return {
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickup.latitude, pickup.longitude),
        infoWindow: InfoWindow(title: 'Pickup Location', snippet: pickup.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(destination.latitude, destination.longitude),
        infoWindow: InfoWindow(title: 'Destination', snippet: destination.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  static LatLngBounds calculateBounds({
    required PlaceDetails pickup,
    required PlaceDetails destination,
  }) {
    final double minLat = pickup.latitude < destination.latitude
        ? pickup.latitude
        : destination.latitude;
    final double maxLat = pickup.latitude > destination.latitude
        ? pickup.latitude
        : destination.latitude;
    final double minLng = pickup.longitude < destination.longitude
        ? pickup.longitude
        : destination.longitude;
    final double maxLng = pickup.longitude > destination.longitude
        ? pickup.longitude
        : destination.longitude;

    return LatLngBounds(
      southwest: LatLng(minLat - 0.01, minLng - 0.01),
      northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
    );
  }
}

class RouteData {
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;
  final LatLngBounds bounds;

  RouteData({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
    required this.bounds,
  });

  factory RouteData.fromJson(
    Map<String, dynamic> json,
    PlaceDetails origin,
    PlaceDetails destination,
  ) {
    final points = <LatLng>[];
    final polyline = json['overview_polyline']['points'];

    // Decode polyline points
    points.addAll(_decodePolyline(polyline));

    final leg = json['legs'][0];
    final distance = leg['distance']['text'];
    final duration = leg['duration']['text'];

    final bounds = GoogleMapsService.calculateBounds(
      pickup: origin,
      destination: destination,
    );

    return RouteData(
      polylinePoints: points,
      distance: distance,
      duration: duration,
      bounds: bounds,
    );
  }

  static List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
