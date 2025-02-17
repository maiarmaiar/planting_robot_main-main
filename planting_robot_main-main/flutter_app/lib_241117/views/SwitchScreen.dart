
import 'package:dunes/views/AppScreens/Camera.dart';
import 'package:dunes/views/AppScreens/ControlDirction.dart';
import 'package:dunes/views/AppScreens/GPS.dart';
import 'package:dunes/views/auth/Profile.dart';
import 'package:dunes/views/AppScreens/SensorsScreen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    LedControlScreen(),     // Assuming this is the name of your Sensors screen
    Directions(),        // Assuming this is the name of your Directions screen
    CameraControl(),     // Assuming this is the name of your Camera screen          
    FindGps(),
    Profile()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
           BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Sensors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.motorcycle),
            label: 'Directions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gps_fixed),
            label: 'map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
      ),
    );
  }
}
