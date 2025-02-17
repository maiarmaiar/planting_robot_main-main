

import 'package:dunes/Components/apptheme.dart';
import 'package:dunes/Components/services/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalController extends GetxController {
  Locale? language;
  MyServices myServices = Get.find();
  ThemeData appTheme = themeEnglish;

  changeLanguage(langcode) {
    Locale locale = Locale(langcode);
    myServices.sharedPreferences.setString("lang", langcode);
    appTheme = langcode == "ar" ? themeArabic : themeEnglish;
    Get.changeTheme(appTheme);
    Get.updateLocale(locale);
  }

  @override
  void onInit() {
    String? sharedprefLang = myServices.sharedPreferences.getString("lang");

    if (sharedprefLang == "Arabic") {
      language = const Locale("ar");
       appTheme = themeArabic;
    } else if (sharedprefLang == "English")  {
      language = const Locale("en");
      appTheme = themeEnglish;
    } else {

      language = Locale(Get.deviceLocale!.languageCode);
      appTheme = themeEnglish;
    }
    super.onInit();
  }
}
