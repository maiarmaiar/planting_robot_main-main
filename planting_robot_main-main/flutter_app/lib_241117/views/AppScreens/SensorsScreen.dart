import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LedControlScreen extends StatefulWidget {
  const LedControlScreen({super.key});

  @override
  State<LedControlScreen> createState() => _LedControlScreenState();
}

class _LedControlScreenState extends State<LedControlScreen> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('Data');
  double temperature = 0;
  double humidity = 0;
  int mq7 = 0;
  double distance = 0;

  @override
  void initState() {
    super.initState();
    _getTemp();
    _getDistance();
    _getGas();
    _getHum();
  }

  void _getTemp() {
    _databaseReference.child('Temp').onValue.listen((event) {
      final double temp = (event.snapshot.value as double?) ?? 0.0;
      setState(() {
        temperature = temp;
      });
    });
  }

  void _getGas() {
    _databaseReference.child('MQ').onValue.listen((event) {
      final int Mq = (event.snapshot.value as int?) ?? 0;
      setState(() {
        mq7 = Mq;
      });
    });
  }

  void _getDistance() {
    _databaseReference.child('Distance').onValue.listen((event) {
      final double Dis = (event.snapshot.value as double?) ?? 0;
      setState(() {
        distance = Dis;
      });
    });
  }

  void _getHum() {
    _databaseReference.child('Hum').onValue.listen((event) {
      final double hum = (event.snapshot.value as double?) ?? 0;
      setState(() {
        humidity = hum;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        title: const Text('S E N S O R S'),
        backgroundColor: Colors.lightGreen[200],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 600 ? screenWidth * 0.08 : 200,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'D  H  T   S  E  N  S  O  R',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // Container for Row with Temperature and Humidity
                  _buildShadowedContainer(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildSensorCircle(
                            'Temperature',
                            temperature,
                            Icons.thermostat,
                            Colors.purple,
                            temperature / 100,
                            '°',
                          ),
                        ),
                        const SizedBox(width: 10), // Adjusted space
                        Expanded(
                          child: _buildSensorCircle(
                            'Humidity',
                            humidity,
                            Icons.water_drop,
                            Colors.blue,
                            humidity / 100,
                            '°',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'D U S T      &        M Q 7',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // Container for Row with Distance and Air Quality
                  _buildShadowedContainer(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildSensorCircle(
                            'Dust',
                            distance,
                            Icons.social_distance_sharp,
                            Colors.pink,
                            distance / 100,
                            '',
                          ),
                        ),
                        const SizedBox(width: 10), // Adjusted space
                        Expanded(
                          child: _buildSensorCircle(
                            'Air Quality',
                            mq7,
                            Icons.gas_meter,
                            Colors.orange,
                            mq7 == 1 ? 1.0 : mq7 / 100,
                            mq7 == 0 ? 'S' : 'D',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to wrap each row with a shadowed container with a gradient background
  Widget _buildShadowedContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade300, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // Helper method for circular indicators
  Widget _buildSensorCircle(String label, dynamic value, IconData icon, Color color, double percent, String unit) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 66.0,
            lineWidth: 15.0,
            percent: percent.clamp(0.0, 1.0),
            center: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 30.0, color: color),
                const SizedBox(width: 5),
                Text(
                  '$value$unit',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            progressColor: color,
            backgroundColor: Colors.grey[300]!,
          ),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
