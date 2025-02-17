import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomButton extends StatelessWidget {
  final String textbutton;
  final void Function()? onPressed;

  const CustomButton({super.key, required this.textbutton, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 70 ,),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Colors.green,
        onPressed: onPressed,
        child: Text(
          textbutton,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'BebasNeue'
          ),
        ),
      ),
    );
  }
}
