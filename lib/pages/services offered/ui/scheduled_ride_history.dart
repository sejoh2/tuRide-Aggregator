import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turide_aggregator/pages/services%20offered/logic/schedule_ride_logic.dart';

class ScheduledRideHistory extends StatefulWidget {
  const ScheduledRideHistory({super.key});

  @override
  State<ScheduledRideHistory> createState() => _ScheduledRideHistoryState();
}

class _ScheduledRideHistoryState extends State<ScheduledRideHistory> {
  late ScheduleRideLogic _scheduleLogic;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> _statusFilters = [
    'All',
    'Scheduled',
    'Completed',
    'Cancelled',
  ];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  // Use a GlobalKey to safely show SnackBars
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _initializeScheduleLogic();
  }

  void _initializeScheduleLogic() {
    final User? user = _auth.currentUser;
    if (user != null) {
      // Use REAL user ID
      final String currentUserId = user.uid;
      _scheduleLogic = ScheduleRideLogic(userId: currentUserId);
      print('Initialized ScheduleRideLogic with user ID: $currentUserId');
    } else {
      // No user logged in - create logic with null userId (will return empty)
      _scheduleLogic = ScheduleRideLogic(userId: null);
      print('No user logged in - returning empty schedule logic');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking auth
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scheduled Rides History'),
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Check if user is logged in
    final User? user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scheduled Rides History'),
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Please log in to view your rides',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'You need to be logged in to see your scheduled rides',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen or show login dialog
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scheduled Rides History'),
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black,
        ),
        body: StreamBuilder<List<ScheduledRide>>(
          stream: _scheduleLogic.getScheduledRides(),
          builder: (context, snapshot) {
            print('StreamBuilder state: ${snapshot.connectionState}');
            print('StreamBuilder has data: ${snapshot.hasData}');
            print('StreamBuilder has error: ${snapshot.hasError}');

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print('Stream error: ${snapshot.error}');
              print('Stack trace: ${snapshot.stackTrace}');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading rides',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              print('No rides found for user: ${user.uid}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🥲', style: TextStyle(fontSize: 42)),
                    SizedBox(height: 16),
                    Text(
                      'No scheduled rides yet.',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Schedule your first ride to see it here!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            final rides = snapshot.data!;
            print('Found ${rides.length} rides for user: ${user.uid}');

            return Column(
              children: [
                // Filter chips
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statusFilters.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = selected ? filter : 'All';
                              });
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: Colors.grey.shade300,
                            checkmarkColor: Colors.grey.shade500,
                            labelStyle: TextStyle(
                              color: _selectedFilter == filter
                                  ? Colors.black
                                  : Colors.grey[700],
                              fontWeight: _selectedFilter == filter
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Rides list
                Expanded(
                  child: ListView.builder(
                    itemCount: rides.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final ride = rides[index];

                      // Filter rides based on selected filter
                      if (_selectedFilter != 'All' &&
                          ride.status.toLowerCase() !=
                              _selectedFilter.toLowerCase()) {
                        return const SizedBox.shrink();
                      }

                      return _buildRideCard(ride, context);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRideCard(ScheduledRide ride, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with platform and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ride.platform ?? 'Unknown Platform',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ride.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ride.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Scheduled date and time
            _buildScheduleInfo(ride),

            const SizedBox(height: 12),

            // Route information
            _buildRouteInfo(ride),

            const SizedBox(height: 12),

            // Ride details
            _buildRideDetails(ride),

            const SizedBox(height: 12),

            // Actions
            if (ride.status == 'scheduled')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelRide(ride.id!),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Cancel Ride'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _viewRideDetails(ride),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(
                          color: Colors.grey.shade500, // border color
                          width: 1, // border width
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _viewRideDetails(ride),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey.shade500, width: 1),
                  ),
                  child: const Text('View Details'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfo(ScheduledRide ride) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          _formatDateOnly(ride.scheduledAt),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          _formatTimeOnly(ride.scheduledAt),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(ScheduledRide ride) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pickup
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pickup',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    ride.pickupName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ride.pickupAddress,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Destination
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Destination',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    ride.destinationName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ride.destinationAddress,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRideDetails(ScheduledRide ride) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Distance',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                ride.distance,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                'Duration',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                ride.duration,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                'Price',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'KES ${ride.estimatedPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.grey.shade600;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _cancelRide(String rideId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(context);

              // Then perform the operation
              final success = await _scheduleLogic.updateRideStatus(
                rideId,
                'cancelled',
              );

              // Use the scaffold key to show SnackBar safely
              if (success) {
                _scaffoldKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Ride cancelled successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                _scaffoldKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to cancel ride'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _viewRideDetails(ScheduledRide ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildRideDetailsSheet(ride),
    );
  }

  Widget _buildRideDetailsSheet(ScheduledRide ride) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ride Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Platform', ride.platform ?? 'Not specified'),
          _buildDetailRow('Status', ride.status),
          _buildDetailRow('Pickup', ride.pickupAddress),
          _buildDetailRow('Destination', ride.destinationAddress),
          _buildDetailRow('Distance', ride.distance),
          _buildDetailRow('Duration', ride.duration),
          _buildDetailRow(
            'Price',
            'KES ${ride.estimatedPrice.toStringAsFixed(0)}',
          ),
          _buildDetailRow('Scheduled Date', _formatDateOnly(ride.scheduledAt)),
          _buildDetailRow('Scheduled Time', _formatTimeOnly(ride.scheduledAt)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey.shade500, width: 1),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateOnly(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeOnly(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}
