import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:simplepay/screens/home/home_screen.dart';
import 'package:simplepay/screens/loading_cubit.dart';

import '../../../models/user.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/login_provider.dart';
import '../../../services/authenticate.dart';
import '../../../services/helper.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_btn.dart';
import '../resetPasswordScreen/reset_password_screen.dart';
import '../signUp/sign_up_screen.dart';
import '../verify.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginProvider>(
      create: (context) => LoginProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(
              color: isDarkMode(context) ? Colors.white : Colors.black),
          elevation: 0.0,
        ),
        body: Consumer2<LoginProvider, AuthenticationProvider>(
          builder: (context, loginProvider, authProvider, child) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Form(
                key: loginProvider.formKey,
                autovalidateMode: loginProvider.autoValidateMode,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/login.png',
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          validator: validateEmail,
                          onSaved: (String? val) {
                            loginProvider.setEmail(val);
                          },
                          style: TextStyle(
                              fontSize: 14.0,
                              color: isDarkMode(context)
                                  ? colorPrimaryLight
                                  : colorSecondary),
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: colorPrimary,
                          decoration: getInputDecoration(
                              hint: 'Email Address',
                              prefixIcon: const Icon(
                                Icons.mail,
                              ),
                              darkMode: isDarkMode(context),
                              errorColor: colorError,
                              context: context),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          obscureText: true,
                          validator: validatePassword,
                          onSaved: (String? val) {
                            loginProvider.setPassword(val);
                          },
                          onFieldSubmitted: (password) {
                            loginProvider.validateLoginFields();
                            _performLogin(context, loginProvider, authProvider);
                          },
                          style: TextStyle(
                              fontSize: 14.0,
                              color: isDarkMode(context)
                                  ? colorPrimaryLight
                                  : colorSecondary),
                          cursorColor: colorPrimary,
                          decoration: getInputDecoration(
                              hint: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              darkMode: isDarkMode(context),
                              errorColor: colorError,
                              context: context),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: () => push(context, ResetPasswordScreen()),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    color: isDarkMode(context)
                                        ? colorPrimaryLight
                                        : colorSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomBtn(
                          onPressed: () {
                            _performLogin(context, loginProvider, authProvider);
                          },
                          text: 'Log In',
                        ),
                        const SizedBox(height: 20),
                        if (authProvider.authState == AuthState.codeSent)
                          OTPVerificationWidget(authProvider),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const Text(
                                'Do not have an account?',
                                style: TextStyle(color: Colors.grey),
                              ),
                              GestureDetector(
                                onTap: () {
                                  push(context, const SignUpScreen());
                                },
                                child: Text(
                                  ' Sign Up',
                                  style: TextStyle(
                                      color: isDarkMode(context)
                                          ? colorPrimaryLight
                                          : colorSecondary,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _performLogin(BuildContext context, LoginProvider loginProvider,
      AuthenticationProvider authProvider) async {
    if (loginProvider.validateLoginFields()) {
      await context
          .read<LoadingCubit>()
          .showLoading(context, 'Logging in, Please wait...', false);

      bool success = await authProvider.loginWithEmailAndPassword(
          loginProvider.email!, loginProvider.password!);
      print(">>>>>>>>>>> UID: ${authProvider.user!.userID}");

      if (success) {
        print(">>>>>>>>>>>>>>> Successfully Login");

        try {
          // Fetch current user data from FirestoreUtils
          User? currentUser =
              await FireStoreUtils.getCurrentUser(authProvider.user!.userID);

          if (currentUser != null) {
            print(">>>>>>>>>>>>>>PhoneNo: ${currentUser.phoneNumber}");

            // Send OTP after successful login
            authProvider.sendOTP(currentUser);

            Navigator.pushReplacementNamed(context, VerifyScreen.routeName,
                arguments: currentUser);
          } else {
            // Handle case where currentUser is null
            MotionToast.error(
              title: const Text("Error"),
              description: Text("User data not found."),
            ).show(context);
          }
        } catch (e) {
          print("Error fetching user data: $e");
          MotionToast.error(
            title: const Text("Error"),
            description: Text("Failed to fetch user data."),
          ).show(context);
        }
      } else {
        // Show error message if login fails
        MotionToast.error(
          title: const Text("Error"),
          description: Text(authProvider.errorMessage ??
              'Couldn\'t login, Please try again.'),
        ).show(context);
      }

      // Hide loading overlay after login attempt
      await context.read<LoadingCubit>().hideLoading();
    }
  }
}

class OTPVerificationWidget extends StatelessWidget {
  final AuthenticationProvider authProvider;

  const OTPVerificationWidget(this.authProvider);

  @override
  Widget build(BuildContext context) {
    TextEditingController _otpController = TextEditingController();

    return Column(
      children: [
        TextField(
          controller: _otpController,
          decoration: InputDecoration(hintText: 'Enter OTP'),
          keyboardType: TextInputType.number,
        ),
        CustomBtn(
          onPressed: () {
            authProvider.verifyOTP(_otpController.text);
          },
          text: 'Verify OTP',
        ),
        if (authProvider.errorMessage != null)
          Text(
            authProvider.errorMessage!,
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}
