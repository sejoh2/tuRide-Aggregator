import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/google_maps_service.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  final GoogleMapsService _mapsService = GoogleMapsService();
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    final position = await _mapsService.getCurrentLocation();
    if (position != null && mounted) {
      // ✅ check mounted
      setState(() => _currentPosition = position);
      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(position, 14));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition!,
        zoom: 14,
      ),
      onMapCreated: (controller) => _controller.complete(controller),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
    );
  }
}
