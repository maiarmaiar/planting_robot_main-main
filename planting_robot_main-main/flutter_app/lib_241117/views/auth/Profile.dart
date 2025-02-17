import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dunes/Components/Button.dart';
import 'package:dunes/Components/routname.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String username = '';
  String email = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        username = userDoc['username'] ?? 'No Name'; // Fetch username
        email = userDoc['email'] ?? 'No Email'; // Fetch email
        isLoading = false; // Data loaded
      });
    }
  }

  Future<void> logout() async {

    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Get.offAllNamed(AppRoute.login); // Navigate to login page using named route
    } catch (e) {
      // Handle specific logout errors
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = "User not found. Please try again.";
            break;
          case 'network-request-failed':
            errorMessage = "Network error. Please check your connection.";
            break;
          default:
            errorMessage = "Logout failed. Please try again.";
        }
      } else {
        errorMessage = "Logout failed. Please try again.";
      }
      _showErrorDialog(errorMessage); // Show error dialog
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width

    return Scaffold(
      backgroundColor: Colors.lightGreen[200],
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 60),
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.green[700],
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator() // Show loading indicator while fetching data
                  : Text(
                      username,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
              isLoading
                  ? const SizedBox() // Placeholder for spacing
                  : Text(
                      email,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // Adjust padding for responsiveness
                child: SizedBox(
                  width: screenWidth < 600 ? double.infinity : 250, // Adjust button width based on screen size
                  child: CustomButton(
                    textbutton: 'Logout',
                    onPressed: logout, // Call logout function when pressed
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
