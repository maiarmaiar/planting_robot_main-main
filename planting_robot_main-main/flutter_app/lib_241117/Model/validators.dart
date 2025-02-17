import 'package:get/get.dart';

String? validateInput(String val, int min, int max, String type) {
  val = val.trim(); // Trim leading and trailing spaces

  if (val.isEmpty) {
    print("$type is Required");
    return "$type is Required";
  }

  if (type == "email") {
    if (!GetUtils.isEmail(val)) {
      print("Enter Valid E-mail");
      return "Enter Valid E-mail";
    }
  }

  if (type == "password") {
    if (val.length < min) {
      print("Password must be at least $min characters");
      return "Password must be at least $min characters";
    }
  }

  print("$type is valid");
  return null; // No errors
}
