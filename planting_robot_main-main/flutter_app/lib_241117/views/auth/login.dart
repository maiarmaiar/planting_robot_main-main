
import 'package:dunes/Components/Button.dart';
import 'package:dunes/Components/UserField.dart';
import 'package:dunes/Model/validators.dart';
import 'package:dunes/controllers/loginController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login extends StatelessWidget {
  Login({super.key});

  // Use Get.put() to retrieve the existing controller instance
  final LogincontrollerImp loginController = Get.put(LogincontrollerImp());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 600 ? screenWidth * 0.08 : 200,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: loginController.formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 130),
                    const Icon(Icons.eco, color: Colors.green, size: 100),
                    Text(
                      'Dunes',
                      style: TextStyle(
                        color: Colors.green[300],
                        fontWeight: FontWeight.bold,
                        fontSize: 60,
                        fontFamily: 'BebasNeue',
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomAuthField(
                      hinttext: '12'.tr,  // Translated to "Enter Your Email"
                      icondata: Icons.person,
                      mycontroller: loginController.emailController,
                      isValid: (val) {
                        return validateInput(val!, 2, 100, "email");
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomAuthField(
                      hinttext: '13'.tr,  // Translated to "Enter Your Password"
                      icondata: Icons.lock_outline,
                      mycontroller: loginController.passwordController,
                      isValid: (val) {
                        return validateInput(val!, 6, 100, "password");
                      },
                    ),
                    const SizedBox(height: 30),
                    Obx(
                      () => CustomButton(
                        textbutton: loginController.isLoading.value
                            ? 'Loading...'.tr // Consider adding this key if you need translation
                            : '15'.tr, // Translated to "Sign In"
                        onPressed: loginController.isLoading.value
                            ? null
                            : () {
                                if (loginController.formKey.currentState?.validate() == true) {
                                  loginController.login();
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "16".tr, // Translated to "Don't have an account?"
                          style: TextStyle(
                            color: Colors.green[300],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'BebasNeue',
                          ),
                        ),
                        InkWell(
                          child: Text(
                            '17'.tr, // Translated to "Create Account"
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'BebasNeue',
                            ),
                          ),
                          onTap: () {
                            loginController.gosignup();
                          },
                        ),
                      ],
                    ),
                    Obx(
                      () => Text(
                        loginController.errorMessage.value.tr, // Ensure error messages are translated
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
