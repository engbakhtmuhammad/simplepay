import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:simplepay/widgets/custom_btn.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/helper.dart';
import '../../../utils/constants.dart';
import '../../home/home_screen.dart';
import '../../loading_cubit.dart';
import '../authentication_bloc.dart';
import 'sign_up_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  Uint8List? _imageData;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  String? firstName, lastName, email, password, confirmPassword, phone;
  AutovalidateMode _validate = AutovalidateMode.disabled;
  bool acceptEULA = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpBloc>(
      create: (context) => SignUpBloc(),
      child: Builder(
        builder: (context) {
          if (!kIsWeb && Platform.isAndroid) {
            context.read<SignUpBloc>().add(RetrieveLostDataEvent());
          }
          return MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  context.read<LoadingCubit>().hideLoading();
                  if (state.authState == AuthState.authenticated) {
                    pushAndRemoveUntil(
                        context, HomeScreen(user: state.user!), false);
                  } else {
                    MotionToast.error(
                            title: const Text("Error"),
                            description: Text(state.message ??
                            'Couldn\'t sign up, Please try again.'))
                        .show(context);
                  }
                },
              ),
              BlocListener<SignUpBloc, SignUpState>(
                listener: (context, state) async {
                  if (state is ValidFields) {
                    await context.read<LoadingCubit>().showLoading(
                        context, 'Creating new account, Please wait...', false);
                    if (!mounted) return;
                    context.read<AuthenticationBloc>().add(
                        SignupWithEmailAndPasswordEvent(
                            emailAddress: email!,
                            password: password!,
                            imageData: _imageData,
                            lastName: lastName,
                            firstName: firstName,
                            phoneNumber: phone!));
                  } else if (state is SignUpFailureState) {
                    MotionToast.error(
                            title: const Text("Error"),
                            description: Text(state.errorMessage))
                        .show(context);
                  }
                },
              ),
            ],
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                title: Text(
                  "Create Account",
                  style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Colors.black),
                ),
                centerTitle: true,
                iconTheme: IconThemeData(
                    color: isDarkMode(context) ? Colors.white : Colors.black),
              ),
              body: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (old, current) =>
                      current is SignUpFailureState && old != current,
                  builder: (context, state) {
                    if (state is SignUpFailureState) {
                      _validate = AutovalidateMode.onUserInteraction;
                    }
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Form(
                        key: _key,
                        autovalidateMode: _validate,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, top: 32, right: 8, bottom: 8),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  BlocBuilder<SignUpBloc, SignUpState>(
                                    buildWhen: (old, current) =>
                                        current is PictureSelectedState &&
                                        old != current,
                                    builder: (context, state) {
                                      if (state is PictureSelectedState) {
                                        _imageData = state.imageData;
                                      }
                                      return state is PictureSelectedState
                                          ? SizedBox(
                                              height: 130,
                                              width: 130,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(65),
                                                  child: state.imageData == null
                                                      ? Image.asset(
                                                          'assets/images/placeholder.jpg',
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.memory(
                                                          state.imageData!,
                                                          fit: BoxFit.cover,
                                                        )),
                                            )
                                          : SizedBox(
                                              height: 130,
                                              width: 130,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(65),
                                                child: Image.asset(
                                                  'assets/images/placeholder.jpg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            );
                                    },
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
                                        color: isDarkMode(context)
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  )
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
                                      : colorSecondary),
                              onSaved: (String? val) {
                                firstName = val;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: getInputDecoration(
                                  hint: 'First Name',
                                  prefixIcon: const Icon(
                                    Icons.person_2_rounded,
                                  ),
                                  darkMode: isDarkMode(context),
                                  errorColor: colorError,
                                  context: context),
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
                                      : colorSecondary),
                              onSaved: (String? val) {
                                lastName = val;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: getInputDecoration(
                                  hint: 'Last Name',
                                  prefixIcon: const Icon(
                                    Icons.person_2_rounded,
                                  ),
                                  darkMode: isDarkMode(context),
                                  errorColor: colorError,
                                  context: context),
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
                                      : colorSecondary),
                              onSaved: (String? val) {
                                email = val;
                              },
                              decoration: getInputDecoration(
                                  hint: 'Email',
                                  prefixIcon: const Icon(
                                    Icons.email,
                                  ),
                                  darkMode: isDarkMode(context),
                                  errorColor: colorError,
                                  context: context),
                            ),
                            const SizedBox(height: verticalPadding),
                            TextFormField(
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              controller: _passwordController,
                              validator: validatePassword,
                              onSaved: (String? val) {
                                password = val;
                              },
                              style: TextStyle(
                                  height: 0.8,
                                  fontSize: 14.0,
                                  color: isDarkMode(context)
                                      ? colorPrimaryLight
                                      : colorSecondary),
                              cursorColor: colorPrimary,
                              decoration: getInputDecoration(
                                  hint: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                  ),
                                  darkMode: isDarkMode(context),
                                  errorColor: colorError,
                                  context: context),
                            ),
                            const SizedBox(height: verticalPadding),
                            TextFormField(
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  context.read<SignUpBloc>().add(
                                        ValidateFieldsEvent(_key,
                                            acceptEula: acceptEULA),
                                      ),
                              obscureText: true,
                              validator: (val) => validateConfirmPassword(
                                  _passwordController.text, val),
                              onSaved: (String? val) {
                                confirmPassword = val;
                              },
                              style: TextStyle(
                                  height: 0.8,
                                  fontSize: 14.0,
                                  color: isDarkMode(context)
                                      ? colorPrimaryLight
                                      : colorSecondary),
                              cursorColor: colorPrimary,
                              decoration: getInputDecoration(
                                  hint: 'Confirm Password',
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                  ),
                                  darkMode: isDarkMode(context),
                                  errorColor: colorError,
                                  context: context),
                            ),
                            const SizedBox(height: verticalPadding),
                            TextFormField(
                              textInputAction: TextInputAction.next,
                              controller: _phoneController,
                              validator: validatePhoneNumber,
                              onSaved: (String? val) {
                                phone = val;
                              },
                              style: TextStyle(
                                  height: 0.8,
                                  fontSize: 14.0,
                                  color: isDarkMode(context)
                                      ? colorPrimaryLight
                                      : colorSecondary),
                              cursorColor: colorPrimary,
                              decoration: getInputDecoration(
                                  hint: 'Enter Phone Number',
                                  prefixIcon: const Icon(
                                    Icons.phone,
                                  ),
                                  darkMode: isDarkMode(context),
                                  errorColor: colorError,
                                  context: context),
                            ),
                            const SizedBox(height: verticalPadding),
                            ListTile(
                              trailing: BlocBuilder<SignUpBloc, SignUpState>(
                                buildWhen: (old, current) =>
                                    current is EulaToggleState &&
                                    old != current,
                                builder: (context, state) {
                                  if (state is EulaToggleState) {
                                    acceptEULA = state.eulaAccepted;
                                  }
                                  return Checkbox(
                                    checkColor: isDarkMode(context)
                                        ? colorBlack
                                        : colorGrey,
                                    onChanged: (value) =>
                                        context.read<SignUpBloc>().add(
                                              ToggleEulaCheckboxEvent(
                                                eulaAccepted: value!,
                                              ),
                                            ),
                                    activeColor: isDarkMode(context)
                                        ? colorPrimaryLight
                                        : colorSecondary,
                                    value: acceptEULA,
                                  );
                                },
                              ),
                              title: RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'By creating an account you agree to our ',
                                      style: TextStyle(
                                          color: isDarkMode(context)
                                              ? Colors.grey
                                              : colorGrey),
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
                                          if (await canLaunchUrl(
                                              Uri.parse(eula))) {
                                            await launchUrl(
                                              Uri.parse(eula),
                                            );
                                          }
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: verticalPadding),
                            CustomBtn(
                              text: "Register",
                              onPressed: () => context.read<SignUpBloc>().add(
                                    ValidateFieldsEvent(_key,
                                        acceptEula: acceptEULA),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _onCameraClick(BuildContext context) {
    if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      context.read<SignUpBloc>().add(ChooseImageFromGalleryEvent());
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
              context.read<SignUpBloc>().add(ChooseImageFromGalleryEvent());
            },
            child: const Text('Choose from gallery'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () async {
              Navigator.pop(context);
              context.read<SignUpBloc>().add(CaptureImageByCameraEvent());
            },
            child: const Text('Take a picture'),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context)),
      );
      showCupertinoModalPopup(context: context, builder: (context) => action);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _imageData = null;
    super.dispose();
  }
}
