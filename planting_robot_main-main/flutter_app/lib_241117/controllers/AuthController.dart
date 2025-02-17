
import 'package:dunes/views/SwitchScreen.dart';
import 'package:dunes/views/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthStreamBuilder extends StatelessWidget {
  const AuthStreamBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Log the current connection state, error status, and data presence
        print('Connection State: ${snapshot.connectionState}');
        print('Has Error: ${snapshot.hasError}');
        print('Has Data: ${snapshot.hasData}');
        
        // Show a loading indicator while waiting for the authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Waiting for authentication state...");
          return const Center(child: CircularProgressIndicator());
        }

        // If an error occurred, display an error message
        if (snapshot.hasError) {
          print("Error occurred: ${snapshot.error}");
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // If the user is logged in, show the homepage
        if (snapshot.hasData) {
          print("User is logged in: ${snapshot.data?.email}");
          return MainScreen();
        } else {
          // If no user is logged in, show the login page
          print("No user logged in, showing login page.");
          return  Login();
        }
      },
    );
  }
}
