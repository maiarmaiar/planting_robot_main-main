import 'package:dunes/Components/Button.dart';
import 'package:dunes/Components/UserField.dart';
import 'package:dunes/Model/validators.dart';
import 'package:dunes/controllers/signupController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Signup extends StatelessWidget {
  final SignupControllerImp signupController = Get.put(SignupControllerImp());

  Signup({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.eco, color: Colors.green, size: 100),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '41'.tr, // Translated to "Create Your Account"
                  style: TextStyle(
                    color: Colors.green[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'BebasNeue',
                  ),
                ),
              ),
              Form(
                key: signupController.signupFormKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            screenWidth < 600 ? screenWidth * 0.08 : 200,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: CustomAuthField(
                          hinttext:
                              '20'.tr, // Translated to "Enter Your Username"
                          icondata: Icons.person,
                          mycontroller: signupController.usernameController,
                          isValid: (val) {
                            return validateInput(val!, 2, 100, "fname");
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            screenWidth < 600 ? screenWidth * 0.08 : 200,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: CustomAuthField(
                          hinttext: '21'
                              .tr, // Translated to "Enter Your Phone Number"
                          icondata: Icons.phone,
                          mycontroller: signupController.phoneController,
                          isValid: (val) {
                            return validateInput(val!, 2, 100, "phone");
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            screenWidth < 600 ? screenWidth * 0.08 : 200,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: CustomAuthField(
                          hinttext: '12'.tr, // Translated to "Enter Your Email"
                          icondata: Icons.email_outlined,
                          mycontroller: signupController.emailController,
                          isValid: (val) {
                            return validateInput(val!, 2, 100, "email");
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            screenWidth < 600 ? screenWidth * 0.08 : 200,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: CustomAuthField(
                          hinttext:
                              '13'.tr, // Translated to "Enter Your Password"
                          icondata: Icons.lock_outline,
                          mycontroller: signupController.passwordController,
                          isValid: (val) {
                            return validateInput(val!, 2, 100, "password");
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          return Checkbox(
                            value: signupController.isAcceptedTerms.value,
                            onChanged: (bool? value) {
                              signupController.isAcceptedTerms.value = value!;
                            },
                          );
                        }),
                        Text('40'
                            .tr), // Translated to "I accept the terms and conditions"
                      ],
                    ),
                    Obx(() {
                      return signupController.errorMessage.isNotEmpty
                          ? Text(
                              signupController.errorMessage.value,
                              style: const TextStyle(color: Colors.red),
                            )
                          : Container();
                    }),
                    const SizedBox(height: 10),
                    Obx(() {
                      return signupController.isLoading.value
                          ? const CircularProgressIndicator()
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth < 600
                                    ? screenWidth * 0.08
                                    : 200,
                              ),
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 500),
                                child: CustomButton(
                                  textbutton:
                                      '26'.tr, // Translated to "Create Account"
                                  onPressed: signupController
                                          .isAcceptedTerms.value
                                      ? signupController.signup
                                      : null, // Disable button if terms not accepted
                                ),
                              ),
                            );
                    }),
                    const SizedBox(height: 15),
                    InkWell(
                      child: Text(
                        '25'.tr, // Translated to "Login"
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                      onTap: () {
                        signupController.gologin();
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
