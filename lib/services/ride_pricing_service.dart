import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ride_utils.dart';

class RidePrice {
  final String platform;
  final String name;
  final int price;
  final String currency;
  final int duration;
  final double distance;
  final String source;

  RidePrice({
    required this.platform,
    required this.name,
    required this.price,
    this.currency = 'KES',
    required this.duration,
    required this.distance,
    required this.source,
  });
}

class RidePricingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<String> platforms = [
    'uber',
    'bolt',
    'faras',
    'yego',
    'bolt-bike',
    'little',
    'lyft',
  ];

  // Step 1: Cache
  Future<List<RidePrice>?> getCachedPricing(
    Map<String, double> pickup,
    Map<String, double> dropoff,
  ) async {
    final routeHash = generateRouteHash(
      pickup['lat']!,
      pickup['lng']!,
      dropoff['lat']!,
      dropoff['lng']!,
    );
    final docRef = await _db
        .collection('route_pricing_cache')
        .where('routeHash', isEqualTo: routeHash)
        .get();

    if (docRef.docs.isEmpty) return null;

    final distance = calculateDistance(
      pickup['lat']!,
      pickup['lng']!,
      dropoff['lat']!,
      dropoff['lng']!,
    );
    final duration = calculateEstimatedDuration(distance);

    return docRef.docs.map((doc) {
      final data = doc.data();
      return RidePrice(
        platform: data['platform'],
        name: data['platform'][0].toUpperCase() + data['platform'].substring(1),
        price: (data['avgPrice'] as num).round(),
        duration: duration,
        distance: distance,
        source: 'cache',
      );
    }).toList();
  }

  // Step 4: Formula fallback
  int applyPlatformFormula(
    String platform,
    double distance,
    int duration, [
    double surgeMultiplier = 1.0,
  ]) {
    final models = {
      'uber': {'base': 100, 'km': 50, 'min': 3, 'minFare': 150},
      'bolt': {'base': 80, 'km': 45, 'min': 2.5, 'minFare': 130},
      'faras': {'base': 85, 'km': 47, 'min': 2.8, 'minFare': 140},
      'yego': {'base': 50, 'km': 35, 'min': 2, 'minFare': 100},
      'bolt-bike': {'base': 40, 'km': 32, 'min': 1.8, 'minFare': 90},
      'little': {'base': 90, 'km': 48, 'min': 2.7, 'minFare': 135},
    };
    final m = models[platform] ?? models['uber']!;
    var price = m['base']! + distance * m['km']! + duration * m['min']!;
    price = max(price, m['minFare']!) * surgeMultiplier;
    return price.round();
  }

  // Full pipeline simplified for now: cache → formula → AI fallback
  Future<List<RidePrice>> estimateRidePrice(
    Map<String, double> pickup,
    Map<String, double> dropoff,
  ) async {
    List<RidePrice>? prices = await getCachedPricing(pickup, dropoff);

    final distance = calculateDistance(
      pickup['lat']!,
      pickup['lng']!,
      dropoff['lat']!,
      dropoff['lng']!,
    );
    final duration = calculateEstimatedDuration(distance);

    if (prices != null && prices.isNotEmpty) return prices;

    return platforms.map((p) {
      return RidePrice(
        platform: p,
        name: p[0].toUpperCase() + p.substring(1),
        price: applyPlatformFormula(p, distance, duration),
        duration: duration,
        distance: distance,
        source: 'formula',
      );
    }).toList();
  }
}
