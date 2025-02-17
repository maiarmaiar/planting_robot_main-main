import 'package:dunes/Components/routname.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class LoginController extends GetxController {
  void login();
  void gosignup();
}

class LogincontrollerImp extends LoginController {
  static LogincontrollerImp get to => Get.find(); // For easy access
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Unique key for login form
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void login() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        errorMessage.value = "";  // Clear any previous error messages

        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Navigate to home page after successful login
        Get.offAllNamed(AppRoute.Home);
        isLoading.value = false;

      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        if (e.code == 'user-not-found') {
          errorMessage.value = "No user found for that email.";
        } else if (e.code == 'wrong-password') {
          errorMessage.value = "Wrong password provided.";
        } else {
          errorMessage.value = "An error occurred. Please try again.";
        }
      }
    }
  }


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void gosignup() {
    Get.delete<LogincontrollerImp>(); 
    Get.toNamed(AppRoute.signup); 
  }
}
