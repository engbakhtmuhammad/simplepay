import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:simplepay/models/user.dart';
import 'package:simplepay/services/helper.dart';
import 'package:simplepay/utils/constants.dart';
import 'package:simplepay/widgets/custom_btn.dart';

import '../home/home_screen.dart';

class VerifyScreen extends StatefulWidget {
  final User user;

  const VerifyScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  late String enteredOTP = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text(""),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDarkMode(context) ? Colors.white : Colors.black,
        ),
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/2fa.png',
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 25),
                const Text(
                  "2 Factor Authentication",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "We need to verify your phone\n+ ${widget.user.phoneNumber}",
                  style: TextStyle(fontSize: 16, color: colorGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Pinput(
                  length: 6,
                  onChanged: (value) {
                    enteredOTP = value;
                  },
                ),
                const SizedBox(height: 20),
                customBtn(
                  text: "Verify OTP",
                  onPressed: () {
                    // Validate entered OTP
                    if (enteredOTP == '123456') { // Replace with actual validation logic
                      // Navigate to HomeScreen or any other screen
                      pushAndRemoveUntil(context, HomeScreen(user: widget.user), false);
                    } else {
                      showSnackBar(context, 'Invalid OTP, please try again');
                    }
                  },
                ),
                const SizedBox(height: 20),
                // You can add a button to edit phone number if needed
                // GestureDetector(
                //   onTap: () {
                //     Navigator.pop(context); // Go back to previous screen
                //   },
                //   child: const Text(
                //     "Edit Phone Number?",
                //     style: TextStyle(color: Colors.black),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
