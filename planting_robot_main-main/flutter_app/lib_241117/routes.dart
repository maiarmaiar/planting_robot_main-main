import 'package:dunes/Components/middleware/middleware.dart';
import 'package:dunes/Components/routname.dart';
import 'package:dunes/views/auth/Profile.dart';
import 'package:dunes/views/SwitchScreen.dart';
import 'package:dunes/controllers/language.dart';
import 'package:dunes/views/auth/login.dart';
import 'package:dunes/views/auth/signup.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(
      name: "/", page: () => const Language(), middlewares: [MyMiddleWare()]),
  GetPage(name: AppRoute.login, page: () => Login()),
  GetPage(name: AppRoute.signup, page: () => Signup()),
  GetPage(name: AppRoute.Home, page: () => MainScreen()),
  GetPage(name: AppRoute.Profile, page: () => const Profile()),
];
