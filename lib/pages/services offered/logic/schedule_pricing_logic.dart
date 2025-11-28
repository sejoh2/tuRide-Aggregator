class PricingLogic {
  // Pricing configurations for different platforms in KENYA (KES)
  static const Map<String, PlatformPricing> _platformPricing = {
    'Uber': PlatformPricing(
      baseFare: 100.0,
      costPerKm: 60.0,
      costPerMinute: 5.0,
      minimumFare: 200.0,
      serviceFee: 50.0,
      surgeMultiplier: 1.0,
    ),
    'Bolt': PlatformPricing(
      baseFare: 80.0,
      costPerKm: 55.0,
      costPerMinute: 4.0,
      minimumFare: 180.0,
      serviceFee: 40.0,
      surgeMultiplier: 1.0,
    ),
    'Little': PlatformPricing(
      baseFare: 70.0,
      costPerKm: 50.0,
      costPerMinute: 3.5,
      minimumFare: 150.0,
      serviceFee: 35.0,
      surgeMultiplier: 1.0,
    ),
    'UberX': PlatformPricing(
      baseFare: 120.0,
      costPerKm: 70.0,
      costPerMinute: 6.0,
      minimumFare: 250.0,
      serviceFee: 60.0,
      surgeMultiplier: 1.0,
    ),
  };

  // Calculate estimated price based on distance, duration, and platform
  static EstimatedPrice calculatePrice({
    required String platform,
    required String distance,
    required String duration,
  }) {
    final pricing = _platformPricing[platform] ?? _platformPricing['Uber']!;

    // Parse distance (convert to km if in meters)
    final double distanceInKm = _parseDistance(distance);

    // Parse duration (convert to minutes)
    final double durationInMinutes = _parseDuration(duration);

    // Calculate fare components using actual ride-sharing formulas
    final double distanceCost = distanceInKm * pricing.costPerKm;
    final double timeCost = durationInMinutes * pricing.costPerMinute;

    // Calculate subtotal (base + distance + time)
    double subtotal = pricing.baseFare + distanceCost + timeCost;

    // Apply minimum fare
    if (subtotal < pricing.minimumFare) {
      subtotal = pricing.minimumFare;
    }

    // Apply surge pricing (random for demo, in real app this would come from API)
    final double surgeSubtotal = subtotal * pricing.surgeMultiplier;

    // Add service fee
    final double total = surgeSubtotal + pricing.serviceFee;

    return EstimatedPrice(
      platform: platform,
      baseFare: pricing.baseFare,
      distanceCost: distanceCost,
      timeCost: timeCost,
      serviceFee: pricing.serviceFee,
      subtotal: subtotal,
      total: total,
      surgeMultiplier: pricing.surgeMultiplier,
      currency: 'KES',
    );
  }

  // Parse distance string like "10.5 km" or "1500 m"
  static double _parseDistance(String distance) {
    try {
      final cleaned = distance.toLowerCase().replaceAll(' ', '');

      if (cleaned.contains('km')) {
        final value = double.parse(cleaned.replaceAll('km', ''));
        return value;
      } else if (cleaned.contains('m')) {
        final value = double.parse(cleaned.replaceAll('m', ''));
        return value / 1000; // Convert meters to km
      } else if (cleaned.contains('mi')) {
        final value = double.parse(cleaned.replaceAll('mi', ''));
        return value * 1.60934; // Convert miles to km
      }

      // Default: try to parse as number assuming km
      return double.parse(distance);
    } catch (e) {
      print('Error parsing distance: $distance, error: $e');
      return 5.0; // Default fallback distance
    }
  }

  // Parse duration string like "15 mins" or "1 hour 5 mins"
  static double _parseDuration(String duration) {
    try {
      final cleaned = duration.toLowerCase();
      double totalMinutes = 0;

      // Handle hours
      if (cleaned.contains('hour')) {
        final hourMatch = RegExp(r'(\d+)\s*hour').firstMatch(cleaned);
        if (hourMatch != null) {
          totalMinutes += double.parse(hourMatch.group(1)!) * 60;
        }
      }

      // Handle minutes
      if (cleaned.contains('min')) {
        final minMatch = RegExp(r'(\d+)\s*min').firstMatch(cleaned);
        if (minMatch != null) {
          totalMinutes += double.parse(minMatch.group(1)!);
        }
      }

      // If no hours/minutes found, try to extract just numbers
      if (totalMinutes == 0) {
        final numberMatch = RegExp(r'(\d+)').firstMatch(cleaned);
        if (numberMatch != null) {
          totalMinutes = double.parse(numberMatch.group(1)!);
        }
      }

      return totalMinutes == 0
          ? 15.0
          : totalMinutes; // Default fallback: 15 minutes
    } catch (e) {
      print('Error parsing duration: $duration, error: $e');
      return 15.0; // Default fallback duration
    }
  }

  // Get all available platforms
  static List<String> getAvailablePlatforms() {
    return _platformPricing.keys.toList();
  }
}

class PlatformPricing {
  final double baseFare;
  final double costPerKm;
  final double costPerMinute;
  final double minimumFare;
  final double serviceFee;
  final double surgeMultiplier;

  const PlatformPricing({
    required this.baseFare,
    required this.costPerKm,
    required this.costPerMinute,
    required this.minimumFare,
    required this.serviceFee,
    this.surgeMultiplier = 1.0,
  });
}

class EstimatedPrice {
  final String platform;
  final double baseFare;
  final double distanceCost;
  final double timeCost;
  final double serviceFee;
  final double subtotal;
  final double total;
  final double surgeMultiplier;
  final String currency;

  EstimatedPrice({
    required this.platform,
    required this.baseFare,
    required this.distanceCost,
    required this.timeCost,
    required this.serviceFee,
    required this.subtotal,
    required this.total,
    required this.currency,
    this.surgeMultiplier = 1.0,
  });

  String get formattedTotal {
    return 'KES ${total.toStringAsFixed(0)}';
  }

  String get formattedBreakdown {
    return 'Base: KES ${baseFare.toStringAsFixed(0)} | '
        'Distance: KES ${distanceCost.toStringAsFixed(0)} | '
        'Time: KES ${timeCost.toStringAsFixed(0)} | '
        'Fee: KES ${serviceFee.toStringAsFixed(0)}';
  }

  bool get hasSurgePricing {
    return surgeMultiplier > 1.0;
  }
}
