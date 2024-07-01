import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplepay/screens/auth/verify.dart';
import '../../models/user.dart';
import '../../services/authenticate.dart';
import '../../utils/constants.dart';

enum AuthState {
  unauthenticated,
  authenticated,
  firstRun,
  codeSent,
}

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  String? verificationId;
  String? errorMessage;
  AuthState authState = AuthState.unauthenticated;
  User? user;
  late SharedPreferences prefs;
  late bool finishedOnBoarding;

  AuthenticationProvider() {
    checkFirstRun();
  }

  Future<void> checkFirstRun() async {
    prefs = await SharedPreferences.getInstance();
    finishedOnBoarding = prefs.getBool(finishedOnBoardingConst) ?? false;
    if (!finishedOnBoarding) {
      authState = AuthState.firstRun;
      notifyListeners();
    } else {
      user = await FireStoreUtils.getAuthUser();
      if (user == null) {
        authState = AuthState.unauthenticated;
        notifyListeners();
      } else {
        authState = AuthState.authenticated;
        notifyListeners();
      }
    }
  }

  Future<void> completeOnBoarding() async {
    await prefs.setBool(finishedOnBoardingConst, true);
    authState = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      auth.UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        user = User(
          userID: firebaseUser.uid,
          email: firebaseUser.email!,
          phoneNumber: firebaseUser.phoneNumber ?? '',
          // other fields you want to map
        );
        authState = AuthState.authenticated;
        notifyListeners();
        // await sendOTP();
        return true;
      } else {
        errorMessage = 'Login failed.';
        authState = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Login failed: $e';
      authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> loginWithApple() async {
    dynamic result = await FireStoreUtils.loginWithApple();
    if (result != null && result is User) {
      user = result;
      authState = AuthState.authenticated;
      notifyListeners();
      sendOTP(user!);
    } else if (result != null && result is String) {
      authState = AuthState.unauthenticated;
      errorMessage = result;
      notifyListeners();
    } else {
      authState = AuthState.unauthenticated;
      errorMessage = 'Apple login failed, Please try again.';
      notifyListeners();
    }
  }

  Future<void> sendOTP(User user) async {
    if (user.phoneNumber == null || user.phoneNumber.isEmpty) {
      errorMessage = 'Phone number is empty. Please set a valid phone number.';
      notifyListeners();
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: user.phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (auth.PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        authState = AuthState.authenticated;
        notifyListeners();
      },
      verificationFailed: (auth.FirebaseAuthException e) {
        authState = AuthState.unauthenticated;
        errorMessage = 'Verification failed. Please try again.';
        notifyListeners();
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId;
        authState = AuthState.codeSent;
        notifyListeners();
        print(">>>>>>>>>>>>>> OTP SENT");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
        notifyListeners();
      },
    );
  }

  Future<void> verifyOTP(String otp) async {
    final credential = auth.PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: otp);
    try {
      await _auth.signInWithCredential(credential);
      authState = AuthState.authenticated;
      notifyListeners();
    } catch (e) {
      authState = AuthState.unauthenticated;
      errorMessage = 'Invalid OTP. Please try again.';
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await FireStoreUtils.logout();
    user = null;
    authState = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> loginWithPhoneNumber(
      auth.PhoneAuthCredential credential,
      String phoneNumber,
      String? firstName,
      String? lastName,
      Uint8List? imageData) async {
    dynamic result =
        await FireStoreUtils.loginOrCreateUserWithPhoneNumberCredential(
            credential: credential,
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            imageData: imageData);
    if (result is User) {
      user = result;
      authState = AuthState.authenticated;
      notifyListeners();
    } else if (result is String) {
      authState = AuthState.unauthenticated;
      errorMessage = result;
      notifyListeners();
    }
  }

  Future<void> signupWithEmailAndPassword(
      String emailAddress,
      String password,
      Uint8List? imageData,
      String phoneNumber,
      String? firstName,
      String? lastName) async {
    dynamic result = await FireStoreUtils.signUpWithEmailAndPassword(
        emailAddress: emailAddress,
        password: password,
        imageData: imageData,
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName);
    if (result != null && result is User) {
      user = result;
      authState = AuthState.authenticated;
      notifyListeners();
    } else if (result != null && result is String) {
      authState = AuthState.unauthenticated;
      errorMessage = result;
      notifyListeners();
    } else {
      authState = AuthState.unauthenticated;
      errorMessage = 'Couldn\'t sign up';
      notifyListeners();
    }
  }
}
