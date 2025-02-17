import 'package:flutter/material.dart';

class CustomAuthField extends StatelessWidget {
  final String hinttext;
  final IconData icondata;
  final TextEditingController mycontroller;
  final String? Function(String?) isValid;

  const CustomAuthField({
    super.key,
    required this.hinttext,
    required this.icondata,
    required this.mycontroller,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: mycontroller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.green
, // Light steel blue / grey-blue background
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        hintText: hinttext,
        hintStyle: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.normal
        ),
        prefixIcon: Icon(
          icondata,
          color: Colors.white,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5), // Rectangle shape
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color:Color(0xFF6091BE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFF6091BE)),
        ),
      ),
      validator: isValid,
    );
  }
}
