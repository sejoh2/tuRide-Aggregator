import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/places_logic.dart';

class ScheduledRide {
  final String? id;
  final String userId; // Add this field
  final String pickupName;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String destinationName;
  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;
  final String? platform;
  final String distance;
  final String duration;
  final double estimatedPrice;
  final String currency;
  final DateTime scheduledAt;
  final String status; // 'scheduled', 'completed', 'cancelled'

  ScheduledRide({
    this.id,
    required this.userId, // Add this parameter
    required this.pickupName,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationName,
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
    this.platform,
    required this.distance,
    required this.duration,
    required this.estimatedPrice,
    this.currency = 'KES',
    required this.scheduledAt,
    this.status = 'scheduled',
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // Add this field
      'pickupName': pickupName,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'destinationName': destinationName,
      'destinationAddress': destinationAddress,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'platform': platform,
      'distance': distance,
      'duration': duration,
      'estimatedPrice': estimatedPrice,
      'currency': currency,
      'scheduledAt': scheduledAt,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document with null safety
  factory ScheduledRide.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Helper function to safely parse numbers
    double safeParseDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    String safeParseString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      return value.toString();
    }

    DateTime safeParseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now(); // Fallback to current time
    }

    String safeParseStatus(dynamic value) {
      if (value == null) return 'scheduled';
      final status = value.toString().toLowerCase();
      if (status == 'completed' || status == 'cancelled') {
        return status;
      }
      return 'scheduled';
    }

    return ScheduledRide(
      id: doc.id,
      userId: safeParseString(data['userId'], ''), // Add this line
      pickupName: safeParseString(data['pickupName'], 'Unknown Location'),
      pickupAddress: safeParseString(
        data['pickupAddress'],
        'Address not available',
      ),
      pickupLat: safeParseDouble(data['pickupLat'], 0.0),
      pickupLng: safeParseDouble(data['pickupLng'], 0.0),
      destinationName: safeParseString(
        data['destinationName'],
        'Unknown Destination',
      ),
      destinationAddress: safeParseString(
        data['destinationAddress'],
        'Address not available',
      ),
      destinationLat: safeParseDouble(data['destinationLat'], 0.0),
      destinationLng: safeParseDouble(data['destinationLng'], 0.0),
      platform: safeParseString(data['platform'], 'Unknown Platform'),
      distance: safeParseString(data['distance'], '0 km'),
      duration: safeParseString(data['duration'], '0 mins'),
      estimatedPrice: safeParseDouble(data['estimatedPrice'], 0.0),
      currency: safeParseString(data['currency'], 'KES'),
      scheduledAt: safeParseTimestamp(data['scheduledAt']),
      status: safeParseStatus(data['status']),
    );
  }
}

class ScheduleRideLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId; // Add this field

  // Add constructor that accepts userId
  ScheduleRideLogic({this.userId});

  // Save scheduled ride to Firestore
  Future<String?> saveScheduledRide(ScheduledRide ride) async {
    try {
      final docRef = await _firestore
          .collection('scheduledRides')
          .add(ride.toMap());
      print('Ride scheduled successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving scheduled ride: $e');
      return null;
    }
  }

  // Get all scheduled rides for current user only
  Stream<List<ScheduledRide>> getScheduledRides() {
    if (userId == null || userId!.isEmpty) {
      print('No user ID provided. Returning empty stream.');
      return Stream.value([]);
    }

    return _firestore
        .collection('scheduledRides')
        .where('userId', isEqualTo: userId) // Add this filter
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => ScheduledRide.fromFirestore(doc))
                .toList();
          } catch (e) {
            print('Error parsing scheduled rides: $e');
            return <ScheduledRide>[]; // Return empty list on error
          }
        });
  }

  // Update ride status
  Future<bool> updateRideStatus(String rideId, String status) async {
    try {
      await _firestore.collection('scheduledRides').doc(rideId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating ride status: $e');
      return false;
    }
  }

  // Delete scheduled ride
  Future<bool> deleteScheduledRide(String rideId) async {
    try {
      await _firestore.collection('scheduledRides').doc(rideId).delete();
      return true;
    } catch (e) {
      print('Error deleting scheduled ride: $e');
      return false;
    }
  }
}
