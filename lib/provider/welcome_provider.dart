import 'package:flutter/material.dart';

class WelcomeProvider with ChangeNotifier {
  WelcomePressTarget? _pressTarget;

  WelcomePressTarget? get pressTarget => _pressTarget;

  void loginPressed() {
    _pressTarget = WelcomePressTarget.login;
    notifyListeners();
  }

  void signupPressed() {
    _pressTarget = WelcomePressTarget.signup;
    notifyListeners();
  }

  void resetPressTarget() {
    _pressTarget = null;
    notifyListeners();
  }
}

enum WelcomePressTarget { login, signup }
