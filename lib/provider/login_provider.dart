import 'package:flutter/material.dart';
import 'auth_provider.dart';

class LoginProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  String? email;
  String? password;

  void setEmail(String? email) {
    this.email = email;
    notifyListeners();
  }

  void setPassword(String? password) {
    this.password = password;
    notifyListeners();
  }

  bool validateLoginFields() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      return true;
    } else {
      autoValidateMode = AutovalidateMode.always;
      notifyListeners();
      return false;
    }
  }

  Future<void> loginWithFacebook(AuthenticationProvider authProvider) async {
    // Handle Facebook login logic here
    authProvider.notifyListeners();
  }

  Future<void> loginWithEmailAndPassword(AuthenticationProvider authProvider) async {
    if (validateLoginFields()) {
      await authProvider.loginWithEmailAndPassword(email!, password!);
    }
  }
}
