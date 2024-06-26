import 'package:flutter/material.dart';
import 'package:simplepay/utils/constants.dart';

class customBtn extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;
  final String text;
  VoidCallback? onPressed;
  customBtn(
      {super.key,
      required this.text,
      this.backgroundColor,
      this.onPressed,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size.fromWidth(MediaQuery.of(context).size.width / 1.5),
        backgroundColor: backgroundColor ?? colorPrimary,
        textStyle: TextStyle(color: textColor ?? colorWhite),
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: const BorderSide(color: colorPrimary)),
      ),
      onPressed: onPressed ?? () {},
      child: Text(
        text,
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor ?? colorWhite),
      ),
    );
  }
}
