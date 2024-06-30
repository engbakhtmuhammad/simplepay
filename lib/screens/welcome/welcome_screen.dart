import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplepay/widgets/custom_btn.dart';

import '../../provider/welcome_provider.dart';
import '../../services/helper.dart';
import '../../utils/constants.dart';
import '../auth/login/login_screen.dart';
import '../auth/signUp/sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WelcomeProvider>(
      create: (context) => WelcomeProvider(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Consumer<WelcomeProvider>(
              builder: (context, welcomeProvider, child) {
                if (welcomeProvider.pressTarget != null) {
                  switch (welcomeProvider.pressTarget) {
                    case WelcomePressTarget.login:
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        push(context,  LoginScreen());
                        welcomeProvider.resetPressTarget();
                      });
                      break;
                    case WelcomePressTarget.signup:
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                        push(context, const SignUpScreen());
                        welcomeProvider.resetPressTarget();
                      });
                      break;
                    default:
                      break;
                  }
                }

                return Column(
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
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, top: 32, right: 16, bottom: 8),
                      child: Text(
                        'Say Hello To Simple Pay!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isDarkMode(context)
                                ? colorPrimaryLight
                                : colorSecondary,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      child: Text(
                        'Experience the future of financial management. SimplePay simplifies your financial life with cutting-edge tools and features.',
                        style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode(context) ? Colors.grey : colorGrey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 40.0, left: 40.0, top: 40),
                      child: CustomBtn(
                        onPressed: () =>
                            context.read<WelcomeProvider>().loginPressed(),
                        text: 'Login',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 40.0, left: 40.0, top: 20),
                      child: CustomBtn(
                        backgroundColor: colorWhite,
                        textColor: colorPrimary,
                        onPressed: () =>
                            context.read<WelcomeProvider>().signupPressed(),
                        text: 'Register',
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
