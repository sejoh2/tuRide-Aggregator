import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/google_maps_service.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/places_logic.dart';

class GoogleMapWidget extends StatefulWidget {
  final RouteData? routeData;
  final PlaceDetails? pickup;
  final PlaceDetails? destination;

  const GoogleMapWidget({
    super.key,
    this.routeData,
    this.pickup,
    this.destination,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget>
    with WidgetsBindingObserver {
  final GoogleMapsService _mapsService = GoogleMapsService();

  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isDisposed = false;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initMap();
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update map when new route data or locations are provided
    if (widget.pickup != oldWidget.pickup ||
        widget.destination != oldWidget.destination ||
        widget.routeData != oldWidget.routeData) {
      _updateMap();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted && !_isDisposed) {
      _initMap();
    }
  }

  Future<void> _initMap() async {
    if (_currentPosition != null && mounted && !_isDisposed) {
      setState(() => _currentPosition = null); // show shimmer
    }

    final position = await _mapsService.getCurrentLocation();

    if (position != null && mounted && !_isDisposed) {
      // Ensure position is properly typed as LatLng
      final LatLng currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() => _currentPosition = currentLocation);

      // Update map with any existing route data
      _updateMap();

      // Animate camera safely
      if (_mapController != null) {
        try {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(currentLocation, 14),
          );
        } catch (e) {
          // ignore if disposed
          print("Camera animate cancelled: $e");
        }
      }
    }
  }

  void _updateMap() {
    if (!mounted || _isDisposed) return;

    final markers = <Marker>{};
    final polylines = <Polyline>{};

    // Add pickup and destination markers if available
    if (widget.pickup != null && widget.destination != null) {
      markers.addAll(
        GoogleMapsService.createMarkers(
          pickup: widget.pickup!,
          destination: widget.destination!,
        ),
      );
    }

    // Add current location marker if no pickup/destination
    if (_currentPosition != null && markers.isEmpty) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Add polyline if route data is available
    if (widget.routeData != null) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: widget.routeData!.polylinePoints,
          color: Colors.blue,
          width: 4,
        ),
      );

      // Adjust camera to show the entire route
      _adjustCameraToRoute();
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  void _adjustCameraToRoute() async {
    if (widget.routeData != null && _mapController != null) {
      try {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(widget.routeData!.bounds, 50),
        );
      } catch (e) {
        print("Error adjusting camera: $e");
      }
    } else if (widget.pickup != null && widget.destination != null) {
      // If no route data but we have locations, calculate bounds
      final bounds = GoogleMapsService.calculateBounds(
        pickup: widget.pickup!,
        destination: widget.destination!,
      );
      try {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      } catch (e) {
        print("Error adjusting camera: $e");
      }
    } else if (_currentPosition != null) {
      // Fallback to current position
      try {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 14),
        );
      } catch (e) {
        print("Error adjusting camera: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null && widget.pickup == null) {
      return _buildShimmerPlaceholder();
    }

    // Determine initial camera position - fix the type issue
    final LatLng initialPosition;
    if (widget.pickup != null) {
      initialPosition = LatLng(
        widget.pickup!.latitude,
        widget.pickup!.longitude,
      );
    } else {
      initialPosition = _currentPosition!;
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 14),
      onMapCreated: (controller) {
        _mapController = controller;
        // Adjust camera after map is created if we have route data
        if (widget.routeData != null || widget.pickup != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _adjustCameraToRoute();
          });
        }
      },
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }
}
