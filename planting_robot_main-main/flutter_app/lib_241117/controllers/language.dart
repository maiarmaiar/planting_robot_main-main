
import 'package:dunes/Components/Button.dart';
import 'package:dunes/Components/localization/changelocal.dart';
import 'package:dunes/Components/routname.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Language extends GetView<LocalController> {
  const Language({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Text(
                style: TextStyle(
                    color: Colors.amber.shade900,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BebasNeue'),
                "1".tr),
           
            const SizedBox(
              height: 60,
            ),
            CustomButton(
              textbutton: "English",
              onPressed: () {
                controller.changeLanguage("en");
                Get.toNamed(AppRoute.onBoard);
              },
            ),
            const SizedBox(
              height: 40,
            ),
            CustomButton(
              textbutton: "العربيه",
              onPressed: () {
                controller.changeLanguage("ar");
                Get.toNamed(AppRoute.onBoard);
              },
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
