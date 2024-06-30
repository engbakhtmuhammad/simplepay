import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplepay/widgets/custom_btn.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/signup_provider.dart';
import '../../../services/helper.dart';
import '../../../utils/constants.dart';
import '../../loading_cubit.dart'; // Import your LoadingCubit

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final signUpProvider = Provider.of<SignUpProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Create Account",
          style: TextStyle(
            color: isDarkMode(context) ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDarkMode(context) ? Colors.white : Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Form(
          key: signUpProvider.formKey,
          autovalidateMode: signUpProvider.validateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  top: 32,
                  right: 8,
                  bottom: 8,
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      height: 130,
                      width: 130,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(65),
                        child: signUpProvider.imageData == null
                            ? Image.asset(
                                'assets/images/placeholder.jpg',
                                fit: BoxFit.cover,
                              )
                            : Image.memory(
                                signUpProvider.imageData!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: FloatingActionButton(
                        backgroundColor: isDarkMode(context)
                            ? colorPrimaryLight
                            : colorSecondary,
                        mini: true,
                        onPressed: () => _onCameraClick(context),
                        child: Icon(
                          Icons.camera_alt,
                          color: isDarkMode(context) ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: horizontalPadding),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                validator: validateName,
                style: TextStyle(
                  height: 0.8,
                  fontSize: 14.0,
                  color: isDarkMode(context)
                      ? colorPrimaryLight
                      : colorSecondary,
                ),
                onSaved: (String? val) {
                  signUpProvider.firstName = val;
                },
                textInputAction: TextInputAction.next,
                decoration: getInputDecoration(
                  hint: 'First Name',
                  prefixIcon: const Icon(Icons.person_2_rounded),
                  darkMode: isDarkMode(context),
                  errorColor: colorError,
                  context: context,
                ),
              ),
              const SizedBox(height: verticalPadding),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                validator: validateName,
                style: TextStyle(
                  height: 0.8,
                  fontSize: 14.0,
                  color: isDarkMode(context)
                      ? colorPrimaryLight
                      : colorSecondary,
                ),
                onSaved: (String? val) {
                  signUpProvider.lastName = val;
                },
                textInputAction: TextInputAction.next,
                decoration: getInputDecoration(
                  hint: 'Last Name',
                  prefixIcon: const Icon(Icons.person_2_rounded),
                  darkMode: isDarkMode(context),
                  errorColor: colorError,
                  context: context,
                ),
              ),
              const SizedBox(height: verticalPadding),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: validateEmail,
                style: TextStyle(
                  height: 0.8,
                  fontSize: 14.0,
                  color: isDarkMode(context)
                      ? colorPrimaryLight
                      : colorSecondary,
                ),
                onSaved: (String? val) {
                  signUpProvider.email = val;
                },
                decoration: getInputDecoration(
                  hint: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  darkMode: isDarkMode(context),
                  errorColor: colorError,
                  context: context,
                ),
              ),
              const SizedBox(height: verticalPadding),
              TextFormField(
                obscureText: true,
                textInputAction: TextInputAction.next,
                controller: signUpProvider.passwordController,
                validator: validatePassword,
                onSaved: (String? val) {
                  signUpProvider.password = val;
                },
                style: TextStyle(
                  height: 0.8,
                  fontSize: 14.0,
                  color: isDarkMode(context)
                      ? colorPrimaryLight
                      : colorSecondary,
                ),
                cursorColor: colorPrimary,
                decoration: getInputDecoration(
                  hint: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  darkMode: isDarkMode(context),
                  errorColor: colorError,
                  context: context,
                ),
              ),
              const SizedBox(height: verticalPadding),
              TextFormField(
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) =>
                    signUpProvider.validateFields(context),
                obscureText: true,
                validator: (val) => validateConfirmPassword(
                  signUpProvider.passwordController.text,
                  val,
                ),
                onSaved: (String? val) {
                  signUpProvider.confirmPassword = val;
                },
                style: TextStyle(
                  height: 0.8,
                  fontSize: 14.0,
                  color: isDarkMode(context)
                      ? colorPrimaryLight
                      : colorSecondary,
                ),
                cursorColor: colorPrimary,
                decoration: getInputDecoration(
                  hint: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock),
                  darkMode: isDarkMode(context),
                  errorColor: colorError,
                  context: context,
                ),
              ),
              const SizedBox(height: verticalPadding),
              TextFormField(
                textInputAction: TextInputAction.next,
                controller: signUpProvider.phoneController,
                validator: validatePhoneNumber,
                onSaved: (String? val) {
                  signUpProvider.phone = val;
                },
                style: TextStyle(
                  height: 0.8,
                  fontSize: 14.0,
                  color: isDarkMode(context)
                      ? colorPrimaryLight
                      : colorSecondary,
                ),
                cursorColor: colorPrimary,
                decoration: getInputDecoration(
                  hint: 'Enter Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  darkMode: isDarkMode(context),
                  errorColor: colorError,
                  context: context,
                ),
              ),
              const SizedBox(height: verticalPadding),
              ListTile(
                trailing: Checkbox(
                  checkColor:
                      isDarkMode(context) ? colorBlack : colorGrey,
                  onChanged: (value) => signUpProvider.toggleEulaCheckbox(value!),
                  activeColor: isDarkMode(context)
                      ? colorPrimaryLight
                      : colorSecondary,
                  value: signUpProvider.eulaAccepted,
                ),
                title: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'By creating an account you agree to our ',
                        style: TextStyle(
                          color: isDarkMode(context)
                              ? Colors.grey
                              : colorGrey,
                        ),
                      ),
                      TextSpan(
                        style: TextStyle(
                          color: isDarkMode(context)
                              ? colorPrimaryLight
                              : colorSecondary,
                        ),
                        text: 'Terms of Use',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            if (await canLaunchUrl(Uri.parse(eula))) {
                              await launchUrl(Uri.parse(eula));
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: verticalPadding),
              CustomBtn(text: "Register",onPressed: () async {
                  // Show loading state using LoadingCubit
                  await context.read<LoadingCubit>().showLoading(
                    context,
                    'Creating new account, Please wait...',
                    false,
                  );

                  signUpProvider.validateFields(context);

                  // Hide loading state when done (if not automatically handled by LoadingCubit)
                  context.read<LoadingCubit>().hideLoading();
                },)
            ],
          ),
        ),
      ),
    );
  }

  void _onCameraClick(BuildContext context) {
    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);

    if (kIsWeb ||
        Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux) {
      signUpProvider.chooseImageFromGallery();
    } else {
      final action = CupertinoActionSheet(
        title: const Text(
          'Add Profile Picture',
          style: TextStyle(fontSize: 15.0),
        ),
        actions: [
          CupertinoActionSheetAction(
            isDefaultAction: false,
            onPressed: () async {
              Navigator.pop(context);
              signUpProvider.chooseImageFromGallery();
            },
            child: const Text('Choose from gallery'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () async {
              Navigator.pop(context);
              signUpProvider.captureImageByCamera();
            },
            child: const Text('Take a picture'),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      );
      showCupertinoModalPopup(
        context: context,
        builder: (context) => action,
      );
    }
  }
}
