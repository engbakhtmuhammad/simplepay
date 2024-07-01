import 'package:flutter/material.dart';
import 'package:simplepay/screens/auth/resetPasswordScreen/reset_password_screen.dart';
import 'package:simplepay/screens/auth/verify.dart';
import '../models/user.dart';
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
      return MaterialPageRoute(builder: (context) => ResetPasswordScreen());
    case VerifyScreen.routeName:
      var args = settings.arguments;
      if (args is User) {
        return MaterialPageRoute(builder: (context) => VerifyScreen(user: args));
      }
      // Handle error case where arguments are not of expected type
      return _errorRoute();
    
    default:
      return _errorRoute();
  }
}

Route<dynamic> _errorRoute() {
  return MaterialPageRoute(
    builder: (context) => Scaffold(
      body: Center(
        child: Text('No route defined or invalid arguments'),
      ),
    ),
  );
}
