import 'package:flutter/material.dart';
import 'package:simplepay/services/helper.dart';
import 'package:simplepay/utils/constants.dart';

class CustomBtn extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;
  final String text;
  final VoidCallback? onPressed;

  CustomBtn({
    Key? key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size.fromWidth(MediaQuery.of(context).size.width),
        backgroundColor: backgroundColor ?? colorSecondary,
        textStyle: TextStyle(color: textColor ?? colorWhite),
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: colorSecondary),
        ),
        elevation: 5, // Adjust elevation as needed
        shadowColor: isDarkMode(context)?colorBlack.withOpacity(.5):colorGrey, // Shadow color
      ),
      onPressed: onPressed ?? () {},
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor ?? colorWhite,
        ),
      ),
    );
  }
}
