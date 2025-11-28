import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:turide_aggregator/pages/rides/ui/filter_tabs.dart';
import 'package:turide_aggregator/pages/rides/ui/location_card.dart';
import 'package:turide_aggregator/pages/rides/ui/ride_tile.dart';
import 'package:turide_aggregator/pages/rides/ui/sort_filter_bar.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/places_logic.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/google_maps_service.dart';
import 'package:turide_aggregator/services/ride_pricing_service.dart';

class RidesResult extends StatefulWidget {
  final PlaceDetails pickupPlace;
  final PlaceDetails destinationPlace;

  const RidesResult({
    super.key,
    required this.pickupPlace,
    required this.destinationPlace,
  });

  @override
  State<RidesResult> createState() => _RidesResultState();
}

class _RidesResultState extends State<RidesResult> {
  GoogleMapController? _controller;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _isLoading = true;
  RouteData? _routeData;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create markers
      _markers = GoogleMapsService.createMarkers(
        pickup: widget.pickupPlace,
        destination: widget.destinationPlace,
      );

      // Get route data
      final routeData = await GoogleMapsService.getRoute(
        origin: widget.pickupPlace,
        destination: widget.destinationPlace,
      );

      if (routeData != null) {
        _routeData = routeData;

        // Create polyline
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: routeData.polylinePoints,
            color: Colors.blue,
            width: 5,
            patterns: [],
          ),
        };

        // Fit camera to show entire route
        if (_controller != null) {
          await _controller!.animateCamera(
            CameraUpdate.newLatLngBounds(routeData.bounds, 100.0),
          );
        }
      }
    } catch (e) {
      print('Error loading route: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshRides() async {
    setState(() {
      _isLoading = true;
    });

    // Reload route + polyline + markers
    await _loadRoute();

    // Rebuild FutureBuilder for ride prices by triggering setState
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Rides'))),
      body: SafeArea(
        child: Column(
          children: [
            // MAP SECTION - Now with real Google Maps
            SizedBox(
              width: screenWidth,
              height: screenHeight * 0.38,
              child: Stack(
                children: [
                  // Real Google Map with route
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        widget.pickupPlace.latitude,
                        widget.pickupPlace.longitude,
                      ),
                      zoom: 12,
                    ),
                    polylines: _polylines,
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;

                      // If route is already loaded, fit camera
                      if (_routeData != null) {
                        controller.animateCamera(
                          CameraUpdate.newLatLngBounds(
                            _routeData!.bounds,
                            100.0,
                          ),
                        );
                      }
                    },
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),

                  // Loading indicator
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),

                  // Location card overlay
                  Positioned(
                    top: 20,
                    right: 0,
                    left: 0,
                    child: LocationCard(
                      pickupPlace: widget.pickupPlace,
                      destinationPlace: widget.destinationPlace,
                    ),
                  ),

                  // Route info overlay
                  if (_routeData != null && !_isLoading)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _routeData!.distance,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _routeData!.duration,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // SORT + FILTER BAR
            SortFilterBar(onRefresh: _refreshRides),

            // CATEGORY FILTER TABS
            // const FilterTabs(),
            const SizedBox(height: 10),

            const Text(
              "Updated just now",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 10),

            // LIST OF RIDE OPTIONS
            Expanded(
              child: FutureBuilder<List<RidePrice>>(
                future: RidePricingService().estimateRidePrice(
                  {
                    'lat': widget.pickupPlace.latitude,
                    'lng': widget.pickupPlace.longitude,
                  },
                  {
                    'lat': widget.destinationPlace.latitude,
                    'lng': widget.destinationPlace.longitude,
                  },
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No rides available.'));
                  }

                  final rides = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: rides.length,
                    itemBuilder: (context, index) {
                      final ride = rides[index];
                      return RideTile(
                        name: ride.name,
                        passengers: "1-4",
                        wait: "${ride.duration} min",
                        price: "KES ${ride.price}",
                        oldPrice: "KES ${(ride.price * 1.25).round()}",
                        // <-- Add these four parameters
                        pickupLat: widget.pickupPlace.latitude,
                        pickupLng: widget.pickupPlace.longitude,
                        dropoffLat: widget.destinationPlace.latitude,
                        dropoffLng: widget.destinationPlace.longitude,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
