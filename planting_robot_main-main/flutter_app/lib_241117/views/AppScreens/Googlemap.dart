import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  _GoogleMapsScreenState createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  String _address = "Getting address...";
  bool _isLoading = false; // Loading indicator state
  StreamSubscription<Position>? _positionStreamSubscription;
  Marker? _currentMarker;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndTrackLocation();
  }

  Future<void> _checkPermissionsAndTrackLocation() async {
    if (!await _checkLocationServices()) return;
    if (!await _checkPermissions()) return;
    _startPositionStream();
  }

  Future<bool> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showAlert('GPS Disabled', 'Please enable GPS to use this feature.');
      return false;
    }
    return true;
  }

  Future<bool> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
        _showAlert('Permission Denied', 'Location permission is required.');
        return false;
      }
    } else if (permission == LocationPermission.deniedForever) {
      _showAlert('Permission Denied Forever', 'Location permission is required. Please enable it in settings.');
      return false;
    }
    return true;
  }

  void _startPositionStream() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _updateLocation(position);
    }, onError: (error) {
      _showAlert('Error', 'Failed to get location updates: $error');
    });
  }

  void _updateLocation(Position position) {
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _updateMarker(_currentLocation!);
      _animateCameraToLocation();
      _getAddressFromLatLng(position.latitude, position.longitude);
    });
  }

  void _updateMarker(LatLng position) {
    // Update the existing marker
    setState(() {
      if (_currentMarker == null) {
        _currentMarker = Marker(markerId: const MarkerId('currentLocation'), position: position);
      } else {
        _currentMarker = _currentMarker!.copyWith(positionParam: position);
      }
    });
  }

  void _animateCameraToLocation() {
    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLocation!, zoom: 19),
        ),
      );
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _address = "${placemarks[0].name}, ${placemarks[0].locality}, "
              "${placemarks[0].administrativeArea}, ${placemarks[0].country}";
        });
      }
    } catch (e) {
      setState(() {
        _address = "Address not available";
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accurate Location')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                if (_currentLocation != null) {
                  _animateCameraToLocation();
                }
              },
              initialCameraPosition: const CameraPosition(target: LatLng(0, 0), zoom: 2),
              markers: _currentMarker != null ? {_currentMarker!} : {},
            ),
          ),
          if (_isLoading) // Show loading indicator if fetching address
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _address,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkPermissionsAndTrackLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
