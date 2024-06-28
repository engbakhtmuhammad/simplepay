import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:simplepay/screens/auth/verify.dart';
import 'package:simplepay/widgets/custom_btn.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;

import '../../../services/helper.dart';
import '../../../utils/constants.dart';
import '../../home/home_screen.dart';
import '../../loading_cubit.dart';
import '../authentication_bloc.dart';
import '../resetPasswordScreen/reset_password_screen.dart';
import 'login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  final GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String? email, password;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(''),
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(
                color: isDarkMode(context) ? Colors.white : Colors.black),
            elevation: 0.0,
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) async {
                  await context.read<LoadingCubit>().hideLoading();
                  if (state.authState == AuthState.authenticated) {
                    if (!mounted) return;
                    pushAndRemoveUntil(
                        context, VerifyScreen(user: state.user!), false);
                  } else {
                    if (!mounted) return;
                     MotionToast.error(
                          title: const Text("Error"),
                          description: Text( state.message ?? 'Couldn\'t login, Please try again.'))
                      .show(context);
                  }
                },
              ),
              BlocListener<LoginBloc, LoginState>(
                listener: (context, state) async {
                  if (state is ValidLoginFields) {
                    await context.read<LoadingCubit>().showLoading(
                        context, 'Logging in, Please wait...', false);
                    if (!mounted) return;
                    context.read<AuthenticationBloc>().add(
                          LoginWithEmailAndPasswordEvent(
                            email: email!,
                            password: password!,
                          ),
                        );
                  }
                },
              ),
            ],
            child: BlocBuilder<LoginBloc, LoginState>(
              buildWhen: (old, current) =>
                  current is LoginFailureState && old != current,
              builder: (context, state) {
                if (state is LoginFailureState) {
                  _validate = AutovalidateMode.onUserInteraction;
                }
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Form(
                    key: _key,
                    autovalidateMode: _validate,
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
                                  email = val;
                                },
                                style:  TextStyle(fontSize: 14.0,color: isDarkMode(context)?colorPrimaryLight:colorSecondary),
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: colorPrimary,
                                decoration: getInputDecoration(
                                    hint: 'Email Address',
                                    prefixIcon: const Icon(
                                      Icons.mail,
                                    ),
                                    darkMode: isDarkMode(context),
                                    errorColor: Theme.of(context).errorColor,
                                    context: context)),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              obscureText: true,
                              validator: validatePassword,
                              onSaved: (String? val) {
                                password = val;
                              },
                              onFieldSubmitted: (password) => context
                                  .read<LoginBloc>()
                                  .add(ValidateLoginFieldsEvent(_key)),
                              textInputAction: TextInputAction.done,
                              style:  TextStyle(fontSize: 14.0,color: isDarkMode(context)?colorPrimaryLight:colorSecondary),
                              cursorColor: colorPrimary,
                              decoration: getInputDecoration(
                                hint: 'Password',
                                darkMode: isDarkMode(context),
                                errorColor: Theme.of(context).errorColor,
                                prefixIcon: const Icon(
                                  Icons.lock,
                                ),
                                context: context,
                              ),
                            ),

                            /// forgot password text, navigates user to ResetPasswordScreen
                            /// and this is only visible when logging with email and password
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: 720, minWidth: 200),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 16, right: 24),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => push(
                                        context, const ResetPasswordScreen()),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                          color: colorGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          letterSpacing: 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20),
                              child: CustomBtn(
                                text: "Login",
                                onPressed: () => context
                                    .read<LoginBloc>()
                                    .add(ValidateLoginFieldsEvent(_key)),
                              ),
                            ),
                            FutureBuilder<bool>(
                              future: apple.TheAppleSignIn.isAvailable(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator
                                      .adaptive();
                                }
                                if (!snapshot.hasData ||
                                    (snapshot.data != true)) {
                                  return Container();
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        right: 40.0, left: 40.0, bottom: 20),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.5),
                                      child: apple.AppleSignInButton(
                                          cornerRadius: 25.0,
                                          type: apple.ButtonType.signIn,
                                          style: isDarkMode(context)
                                              ? apple.ButtonStyle.white
                                              : apple.ButtonStyle.black,
                                          onPressed: () async {
                                            await context
                                                .read<LoadingCubit>()
                                                .showLoading(
                                                    context,
                                                    'Logging in, Please wait...',
                                                    false);
                                            if (!mounted) return;
                                            context
                                                .read<AuthenticationBloc>()
                                                .add(LoginWithAppleEvent());
                                          }),
                                    ),
                                  );
                                }
                              },
                            ),
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
      }),
    );
  }
}
