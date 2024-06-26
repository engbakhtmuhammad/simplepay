import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simplepay/widgets/custom_btn.dart';

import '../../services/helper.dart';
import '../../utils/constants.dart';
import '../auth/login/login_screen.dart';
import '../auth/signUp/sign_up_screen.dart';
import 'welcome_bloc.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WelcomeBloc>(
      create: (context) => WelcomeBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: BlocListener<WelcomeBloc, WelcomeInitial>(
              listener: (context, state) {
                switch (state.pressTarget) {
                  case WelcomePressTarget.login:
                    push(context, const LoginScreen());
                    break;
                  case WelcomePressTarget.signup:
                    push(context, const SignUpScreen());
                    break;
                  default:
                    break;
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/icons/simplepay.png',
                      width: 150.0,
                      height: 150.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                        left: 16, top: 32, right: 16, bottom: 8),
                    child: Text(
                      'Say Hello To Simple Pay!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: colorPrimary,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    child: Text(
                      'Experience the future of financial management. SimplePay simplifies your financial life with cutting-edge tools and features.',
                      style: TextStyle(fontSize: 18, color: colorGrey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
                    child: customBtn(
                      onPressed: () =>
                          context.read<WelcomeBloc>().add(LoginPressed()),
                      text: 'Login',
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
                    child: customBtn(
                      backgroundColor: colorWhite,
                      textColor: colorPrimary,
                      onPressed: () =>
                          context.read<WelcomeBloc>().add(SignupPressed()),
                      text: 'Register',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
