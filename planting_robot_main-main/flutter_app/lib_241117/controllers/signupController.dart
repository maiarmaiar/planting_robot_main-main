import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dunes/Components/routname.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class SignupController extends GetxController {
  void signup();
  void gologin();
}

class SignupControllerImp extends SignupController {
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>(); // Unique key for signup form
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();

  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;
  RxBool isAcceptedTerms = false.obs; // For terms acceptance

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void signup() async {
    if (signupFormKey.currentState!.validate()) {

      if (!isAcceptedTerms.value) {
        errorMessage.value = "You must accept the terms and conditions!";
        return;
      }

      try {
        isLoading.value = true;
        errorMessage.value = "";

        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Storing user data in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': usernameController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
          
          'uid': userCredential.user!.uid,
        });

        Get.offAllNamed(AppRoute.Home); // Navigate to home page after successful signup

      } on FirebaseAuthException catch (e) {
        errorMessage.value = (e.code == 'email-already-in-use')
            ? "The email is already in use."
            : "An error occurred. Please try again.";
      } catch (e) {
        errorMessage.value = "An unexpected error occurred. Please try again.";
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void gologin() {
    Get.delete<SignupControllerImp>(); // Deletes the instance of SignupControllerImp
    Get.offAllNamed(AppRoute.login); // Navigate to login page
  }
}
