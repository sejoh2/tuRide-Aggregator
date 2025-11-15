import 'dart:math';

double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  const R = 6371;
  final dLat = (lat2 - lat1) * pi / 180;
  final dLng = (lng2 - lng1) * pi / 180;
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLng / 2) *
          sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

int calculateEstimatedDuration(double distance) {
  final hour = DateTime.now().hour;
  final isPeak = (hour >= 7 && hour <= 10) || (hour >= 17 && hour <= 20);
  final avgSpeed = isPeak ? 15 : 25; // km/h
  return (distance / avgSpeed * 60).ceil();
}

String generateRouteHash(
  double pickupLat,
  double pickupLng,
  double dropoffLat,
  double dropoffLng,
) {
  return "${(pickupLat * 100).round() / 100},${(pickupLng * 100).round() / 100}-"
      "${(dropoffLat * 100).round() / 100},${(dropoffLng * 100).round() / 100}";
}
