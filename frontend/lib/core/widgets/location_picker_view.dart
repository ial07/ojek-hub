import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ojekhub_mobile/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerView extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerView({Key? key, this.initialLocation}) : super(key: key);

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  // Jakarta coordinates as default
  late LatLng _currentCenter;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Default to Rejang Lebong, Bengkulu (-3.4644, 102.5298)
    _currentCenter = widget.initialLocation ?? const LatLng(-3.4644, 102.5298);

    if (widget.initialLocation == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _moveToCurrentLocation();
      });
    }
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentCenter = latLng;
      });
      _mapController.move(latLng, 15.0);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _onConfirm() {
    Get.back(result: _currentCenter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onConfirm,
          )
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 13.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _currentCenter = camera.center;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ojekhub_mobile',
              ),
              // We don't strictly need a MarkerLayer if we put a fixed icon in the center of the Stack
              // This is often smoother for "pick location" UX
            ],
          ),
          // Fixed center pin
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0), // Adjust for pin tip
              child: Icon(
                Icons.location_on,
                color: AppColors.primaryGreen,
                size: 50,
              ),
            ),
          ),
          // My Location Button
          Positioned(
            bottom: 240,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'my_location_btn',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _moveToCurrentLocation,
              child:
                  const Icon(Icons.my_location, color: AppColors.primaryGreen),
            ),
          ),

          // Location details overlay (optional)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Geser peta untuk menentukan titik',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_currentCenter.latitude.toStringAsFixed(6)}, ${_currentCenter.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _onConfirm,
                        child: const Text('Pilih Lokasi Ini'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
