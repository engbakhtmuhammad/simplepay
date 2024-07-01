import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pinput/pinput.dart';
import '../../models/user.dart';
import '../../provider/auth_provider.dart';
import '../../services/helper.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';
import '../../widgets/custom_btn.dart';

class VerifyScreen extends StatefulWidget {
  static const String routeName = '/verify';
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
        }
      });
    });
  }

  void _resendCode(BuildContext context,User user) {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.sendOTP(user);
    setState(() {
      _remainingSeconds = 60;
    });
    _startCountdownTimer();
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

    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.authState == AuthState.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const HomeScreen()),
              (route) => false,
            );
          });
        } else if (authProvider.authState == AuthState.unauthenticated) {
          MotionToast.error(
              title: const Text("Error"),
              description: Text(authProvider.errorMessage ?? 'Authentication failed.')
          ).show(context);
        } else if (authProvider.authState == AuthState.codeSent) {
          MotionToast.success(
              title: const Text("Success"),
              description: Text(authProvider.errorMessage ?? 'Code Sent')
          ).show(context);
        }

        return Scaffold(
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
                      "We need to verify your phone\n${widget.user!.phoneNumber}",
                      style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode(context) ? Colors.grey : colorGrey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Pinput(
                      length: 6,
                      controller: _otpController,
                      showCursor: true,
                      onCompleted: (pin) => _verifyOTP(context, pin),
                    ),
                    const SizedBox(height: 20),
                    CustomBtn(
                      text: "Verify OTP",
                      onPressed: () => _verifyOTP(context, _otpController.text),
                    ),
                    const SizedBox(height: 20),
                    _remainingSeconds > 0
                        ? Text(
                            'Time remaining: $_remainingSeconds seconds',
                            style: TextStyle(
                              color: isDarkMode(context) ? colorPrimaryLight : colorSecondary,
                              fontSize: 16,
                            ),
                          )
                        : GestureDetector(
                            onTap: () => _resendCode(context,widget.user),
                            child: Text(
                              'Resend Code',
                              style: TextStyle(
                                color: isDarkMode(context) ? colorPrimaryLight : colorSecondary,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                                decorationColor: isDarkMode(context) ? colorPrimaryLight : colorSecondary,
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _verifyOTP(BuildContext context, String otp) {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTP(otp);
  }
}
