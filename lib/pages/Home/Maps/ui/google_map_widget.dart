import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/google_maps_service.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget>
    with WidgetsBindingObserver {
  final GoogleMapsService _mapsService = GoogleMapsService();

  GoogleMapController? _mapController; // direct reference
  LatLng? _currentPosition;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initMap();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose(); // safely dispose controller
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
      setState(() => _currentPosition = position);

      // Animate camera safely
      if (_mapController != null) {
        try {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(position, 14),
          );
        } catch (e) {
          // ignore if disposed
          print("Camera animate cancelled: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) return _buildShimmerPlaceholder();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition!,
        zoom: 14,
      ),
      onMapCreated: (controller) {
        _mapController = controller; // store controller directly
      },
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
