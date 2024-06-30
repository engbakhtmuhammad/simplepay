import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pinput/pinput.dart';
import '../../models/user.dart';
import '../../services/helper.dart';
import '../../utils/constants.dart';
import '../auth/authentication_bloc.dart';
import '../home/home_screen.dart';
import '../../widgets/custom_btn.dart';
import 'login/login_screen.dart';

class VerifyScreen extends StatefulWidget {
  final User user;

  const VerifyScreen({super.key, required this.user});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  late Timer _timer;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
          _navigateToLoginScreen();
        }
      });
    });
  }

  void _navigateToLoginScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20, color: colorSecondary, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: colorWhite),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.authState == AuthState.authenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(user: widget.user)),
            (route) => false,
          );
        } else if (state.authState == AuthState.unauthenticated) {
          MotionToast.error(
                  title: const Text("Error"),
                  description: Text(state.message ?? 'Authentication failed.'))
              .show(context);
        } else if (state.authState == AuthState.codeSent) {
          // Handle code sent state if needed
          MotionToast.success(
                  title: const Text("Success"),
                  description: Text(state.message ?? 'Code Sent'))
              .show(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: const Text(""),
          centerTitle: true,
          iconTheme: IconThemeData(
              color: isDarkMode(context) ? Colors.white : Colors.black),
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
                  Text(
                    "2 Factor Authentication",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode(context)
                            ? colorPrimaryLight
                            : colorSecondary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We need to verify your phone\n${widget.user.phoneNumber}",
                    style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode(context) ? Colors.grey : colorGrey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Pinput(
                    length: 6,
                    controller: _otpController,
                    // defaultPinTheme: defaultPinTheme,
                    // focusedPinTheme: focusedPinTheme,
                    // submittedPinTheme: submittedPinTheme,
                    showCursor: true,
                    onCompleted: (pin) => _verifyOTP(context, pin),
                  ),
                  const SizedBox(height: 20),
                  CustomBtn(
                    text: "Verify OTP",
                    onPressed: () => _verifyOTP(context, _otpController.text),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Time remaining: $_remainingSeconds seconds',
                    style: const TextStyle(
                      color: colorSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _verifyOTP(BuildContext context, String otp) {
    final authBloc = context.read<AuthenticationBloc>();
    authBloc.add(VerifyOTPEvent(otp: otp));
  }
}
