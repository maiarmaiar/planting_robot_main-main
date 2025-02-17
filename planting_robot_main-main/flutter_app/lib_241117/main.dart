import 'package:dunes/Components/localization/changelocal.dart';
import 'package:dunes/Components/localization/translate.dart';
import 'package:dunes/Components/services/services.dart';
import 'package:dunes/controllers/AuthController.dart';
import 'package:dunes/firebase_options.dart';
import 'package:dunes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initialServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    LocalController controller = Get.put(LocalController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      smartManagement: SmartManagement.full,
      home: const AuthStreamBuilder(),
      translations: MyTranslation(),
      title: 'Dunes',
      locale: controller.language,
      theme: controller.appTheme,
      getPages: routes,
    );
  }
}
