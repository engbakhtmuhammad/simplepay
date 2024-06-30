import 'package:flutter/material.dart';
import 'package:simplepay/screens/auth/resetPasswordScreen/reset_password_screen.dart';
import 'package:simplepay/screens/auth/verify.dart';
import '../screens/auth/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/launcherScreen/launcher_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LauncherScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LauncherScreen());
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case HomeScreen.routeName:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case ResetPasswordScreen.routeName:
      return MaterialPageRoute(builder: (context) =>  ResetPasswordScreen());
    case ResetPasswordScreen.routeName:
      return MaterialPageRoute(builder: (context) =>  VerifyScreen(user: null,));
    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
  }
}
