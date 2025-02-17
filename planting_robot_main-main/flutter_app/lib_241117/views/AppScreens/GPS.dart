import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'dart:convert';
import 'dart:async';

class FindGps extends StatefulWidget {
  const FindGps({super.key});

  @override
  State<FindGps> createState() => _FindGpsState();
}

class _FindGpsState extends State<FindGps> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('Data');
  bool forwardStatus = false; // Local state for planting
  bool backwardStatus = false; // Local state for seeding
  final LatLng _defaultLocation = const LatLng(51.5, -0.09);
  LatLng? _currentLocation;
  LatLng? _tappedLocation;
  double _zoomLevel = 15.0;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  final List<LatLng> _selectedLocations = []; // List for selected locations
  bool _isDragging = false;
  bool _fourLocationMode = false; // New state for enabling 4-location mode

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _trackLocation();
    _loadInitialStatuses(); // Load initial statuses from Firebase
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialStatuses() async {
    _databaseReference.child('planting').onValue.listen((event) {
      final data = event.snapshot.value as bool?;
      if (data != null) {
        setState(() {
          forwardStatus = data;
        });
      }
    });

    _databaseReference.child('seeding').onValue.listen((event) {
      final data = event.snapshot.value as bool?;
      if (data != null) {
        setState(() {
          backwardStatus = data;
        });
      }
    });
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _currentLocation = _currentLocation ?? _defaultLocation;
      });
      return;
    }

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _searchResults = data.map((place) {
          final lat = double.parse(place['lat']);
          final lon = double.parse(place['lon']);
          final displayName = place['display_name'] ?? 'Unknown Place';
          return {'lat': lat, 'lon': lon, 'name': displayName};
        }).toList();
      });
    } else {
      throw Exception('Failed to load place');
    }
  }

  void _moveToLocation(double latitude, double longitude) {
    LatLng newLocation = LatLng(latitude, longitude);
    setState(() {
      _currentLocation = newLocation;
    });
    _mapController.move(newLocation, _zoomLevel);
    _searchResults.clear();
  }

  void _toggleForward() {
    setState(() {
      forwardStatus = !forwardStatus;
    });
    _databaseReference.child('planting').set(forwardStatus);
  }

  void _toggleBackward() {
    setState(() {
      backwardStatus = !backwardStatus;
    });
    _databaseReference.child('seeding').set(backwardStatus);
  }

  // Method to clear selected locations
  void _clearSelectedLocations() {
    setState(() {
      _selectedLocations.clear(); // Clear the selected locations
      _tappedLocation = null; // Clear the tapped location as well
    });
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _fetchLocation();
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _fetchLocation();
      }
    } else if (permission == LocationPermission.deniedForever) {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _fetchLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _zoomLevel = 18.0;
    });
    _mapController.move(_currentLocation!, _zoomLevel);
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
              'Location permission is permanently denied. Please enable location permission from the settings.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _trackLocation() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (!_isDragging) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _mapController.move(_currentLocation!, _zoomLevel);
        });
      }
    });
  }

  void _showLocationDetails({LatLng? tappedLocation}) {
    setState(() {
      _tappedLocation = tappedLocation;
    });
    if (_tappedLocation != null) {
      _addLocationToSelected();
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_currentLocation != null) ...[
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Current Location:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text('Latitude: ${_currentLocation!.latitude}'),
                Text('Longitude: ${_currentLocation!.longitude}'),
                const SizedBox(height: 10),
              ],
              if (tappedLocation != null) ...[
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Tapped Location:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text('Latitude: ${tappedLocation.latitude}'),
                Text('Longitude: ${tappedLocation.longitude}'),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addLocationToSelected() {
    if (_tappedLocation != null &&
        !_selectedLocations.contains(_tappedLocation)) {
      setState(() {
        _selectedLocations.add(_tappedLocation!);
        _tappedLocation = null;
      });

      if (_selectedLocations.length == 4) {
        _showConfirmationDialog();
      }
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
              'You have selected 4 locations. Do you want to Start Seeding?'),
          actions: [
            TextButton(
              onPressed: () {
                _sendLocationsToFirebase();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seeding Started Successfully')),
                );
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                _clearSelectedLocations(); // Clear selected locations if No is pressed
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _sendLocationsToFirebase() {
    final locationsData = _selectedLocations.map((location) {
      return {
        'latitude': location.latitude,
        'longitude': location.longitude,
      };
    }).toList();

    _databaseReference.child('selected_locations').set(locationsData).then((_) {
      print("Locations sent to Firebase successfully!");
    }).catchError((error) {
      print("Failed to send locations to Firebase: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text('M A P'),
        backgroundColor: Colors.green[200],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width > 600
                    ? 700
                    : double.infinity, // Set max width for larger screens
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchPlace,
                  decoration: InputDecoration(
                    hintText: 'Search for a place',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20.0),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchResults.clear();
                        _moveToCurrentLocation(); // Return to current location when cleared
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Show search results if available
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final place = _searchResults[index];
                  return ListTile(
                    title: Text(place['name'] ?? 'Unknown'),
                    subtitle:
                        Text('Lat: ${place['lat']}, Lon: ${place['lon']}'),
                    onTap: () {
                      _moveToLocation(place['lat'], place['lon']);
                    },
                  );
                },
              ),
            ),
          // Main Map Display
          if (_searchResults.isEmpty)
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation ?? _defaultLocation,
                      initialZoom: _zoomLevel,
                      onPositionChanged: (position, hasGesture) {
                        setState(() {
                          _isDragging = hasGesture;
                        });
                      },
                      onTap: (tapPosition, latlng) {
                        if (_fourLocationMode) {
                          _showLocationDetails(tappedLocation: latlng);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        tileProvider: CancellableNetworkTileProvider(),
                      ),
                      MarkerLayer(
                        markers: [
                          if (_currentLocation != null)
                            Marker(
                              point: _currentLocation!,
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                          if (_tappedLocation != null)
                            Marker(
                              point: _tappedLocation!,
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ..._selectedLocations.map((location) => Marker(
                                point: location,
                                width: 80,
                                height: 80,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.green,
                                  size: 40,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                  // Floating Action Button
                  // Floating Action Button
                  Positioned(
                    right: 16.0,
                    bottom: 16.0,
                    child: AnimatedFloatingActionButton(
                      fabButtons: <Widget>[
                        FloatingActionButton(
                          onPressed: _toggleFourLocationMode,
                          tooltip: 'Toggle 4-Location Mode',
                          child: Icon(
                            Icons.location_searching,
                            color:
                                _fourLocationMode ? Colors.green : Colors.black,
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: _clearSelectedLocations,
                          tooltip: 'Clear Selected Locations',
                          child: const Icon(Icons.location_disabled_outlined,
                              color: Colors.red),
                        ),
                      ],
                      animatedIconData: AnimatedIcons.menu_close,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      setState(() {
        _tappedLocation = null; // Clear tapped location
      });
      _mapController.move(_currentLocation!, _zoomLevel);
    }
  }

  void _toggleFourLocationMode() {
    setState(() {
      _fourLocationMode = !_fourLocationMode; // Toggle the mode
    });
  }
}
