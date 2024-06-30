import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

import '../services/authenticate.dart';

enum ResetPasswordState {
  initial,
  sending,
  sent,
  failure,
}

class ResetPasswordProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>(); // Define form key here
  ResetPasswordState _state = ResetPasswordState.initial;
  String? _emailAddress;
  String? _errorMessage;

  ResetPasswordState get state => _state;
  String? get errorMessage => _errorMessage;

  void setEmailAddress(String email) {
    _emailAddress = email;
  }

  bool validateEmail(String value) {
    // Replace with your email validation logic
    return value.isNotEmpty && value.contains('@');
  }

  Future<void> resetPassword(BuildContext context) async {
    try {
      _state = ResetPasswordState.sending;
      notifyListeners();

      // Replace with your reset password logic (e.g., FirestoreUtils.resetPassword)
      await FireStoreUtils.resetPassword(_emailAddress!);

      _state = ResetPasswordState.sent;
      notifyListeners();

      // Optionally show success message and navigate back
      MotionToast.success(
        title: const Text("Success"),
        description: const Text('Reset password email has been sent. Please check your email.'),
      ).show(context);

      Navigator.pop(context);
    } catch (error) {
      _state = ResetPasswordState.failure;
      _errorMessage = 'Failed to send reset password email. Please try again later.';
      notifyListeners();
    }
  }

  void checkValidField(BuildContext context, GlobalKey<FormState> key) {
    if (key.currentState?.validate() ?? false) {
      key.currentState!.save();
      _errorMessage = null;
      notifyListeners();
      resetPassword(context); // Automatically trigger reset password if fields are valid
    } else {
      _state = ResetPasswordState.failure;
      _errorMessage = 'Invalid email address.';
      notifyListeners();
    }
  }
}
