import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CameraControl extends StatefulWidget {
  const CameraControl({super.key});

  @override
  State<CameraControl> createState() => _CameraControlState();
}

class _CameraControlState extends State<CameraControl> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('Data');
  bool forwardStatus = false;
  bool backwardStatus = false;
  bool rightStatus = false;
  bool leftStatus = false;
  bool stopStatus = false;
  String imageUrl = '';
  String previousImageUrl = '';
  Timer? _imageRefreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchImage();
    _imageRefreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchImage();
    });
    forwardStatus = false;
    backwardStatus = false;
    rightStatus = false;
    leftStatus = false;
    stopStatus = false;
    _updateFirebaseStatus();
  }

  Future<String> _getImageUrl() async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('camera_frames/live_stream.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching image: $e');
      return '';
    }
  }

  void _fetchImage() async {
    final newImageUrl = await _getImageUrl();
    if (mounted) {
      setState(() {
        previousImageUrl = imageUrl;
        imageUrl = newImageUrl;
      });
    }
  }

  void _updateFirebaseStatus() {
    _databaseReference.child('cam_up').set(forwardStatus);
    _databaseReference.child('cam_down').set(backwardStatus);
    _databaseReference.child('cam_left').set(leftStatus);
    _databaseReference.child('cam_right').set(rightStatus);
    _databaseReference.child('cam_center').set(stopStatus);
  }

  void _resetStatusAfterDelay() {
    Timer(const Duration(seconds: 1), () {
      setState(() {
        forwardStatus = false;
        backwardStatus = false;
        leftStatus = false;
        rightStatus = false;
        stopStatus = false;
      });
      _updateFirebaseStatus();
    });
  }

  void _toggleForward() {
    setState(() {
      forwardStatus = true;
    });
    _updateFirebaseStatus();
    _resetStatusAfterDelay();
  }

  void _toggleBackward() {
    setState(() {
      backwardStatus = true;
    });
    _updateFirebaseStatus();
    _resetStatusAfterDelay();
  }

  void _toggleLeft() {
    setState(() {
      leftStatus = true;
    });
    _updateFirebaseStatus();
    _resetStatusAfterDelay();
  }

  void _toggleRight() {
    setState(() {
      rightStatus = true;
    });
    _updateFirebaseStatus();
    _resetStatusAfterDelay();
  }

  void _toggleStop() {
    setState(() {
      stopStatus = true;
    });
    _updateFirebaseStatus();
    _resetStatusAfterDelay();
  }

  @override
  void dispose() {
    _imageRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        title: const Text('Camera Feed'),
        backgroundColor: Colors.lightGreen[200],
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final containerWidth = (constraints.maxWidth < 600)
              ? (constraints.maxWidth * 0.9).toDouble()
              : 600.0;

          return Center(
            child: Container(
              width: containerWidth,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightGreen[100]!,
                    Colors.lightGreen[300]!,
                    Colors.lightGreen[500]!,
                    Colors.green[600]!,
                    Colors.green[800]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade700, blurRadius: 4)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (previousImageUrl.isNotEmpty)
                            Image.network(
                              previousImageUrl,
                              key: UniqueKey(),
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          if (imageUrl.isNotEmpty)
                            Image.network(
                              imageUrl,
                              key: UniqueKey(),
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          if (imageUrl.isEmpty)
                            const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            onPressed: _toggleForward,
                            icon: const Icon(Icons.arrow_circle_up),
                            color: forwardStatus ? Colors.yellow : Colors.white,
                            iconSize: 50,
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _toggleLeft,
                                icon: const Icon(Icons.arrow_circle_left),
                                color:
                                    leftStatus ? Colors.yellow : Colors.white,
                                iconSize: 50,
                              ),
                              IconButton(
                                onPressed: _toggleStop,
                                icon: const Icon(Icons.stop),
                                color: stopStatus ? Colors.red : Colors.white,
                                iconSize: 50,
                              ),
                              IconButton(
                                onPressed: _toggleRight,
                                icon: const Icon(Icons.arrow_circle_right),
                                color:
                                    rightStatus ? Colors.yellow : Colors.white,
                                iconSize: 50,
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: _toggleBackward,
                            icon: const Icon(Icons.arrow_circle_down),
                            color:
                                backwardStatus ? Colors.yellow : Colors.white,
                            iconSize: 50,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
