import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../services/authenticate.dart';
import '../../utils/constants.dart';

class AuthenticationProvider extends ChangeNotifier {
  User? user;
  late SharedPreferences prefs;
  late bool finishedOnBoarding;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  String? verificationId;
  String? errorMessage;
  AuthState authState = AuthState.unauthenticated;

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
        sendOTP(user!.phoneNumber);
      }
    }
  }

  Future<void> completeOnBoarding() async {
    await prefs.setBool(finishedOnBoardingConst, true);
    authState = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    dynamic result = await FireStoreUtils.loginWithEmailAndPassword(email, password);
    if (result != null && result is User) {
      user = result;
      authState = AuthState.authenticated;
      notifyListeners();
      sendOTP(user!.phoneNumber);
      return true;
    } else if (result != null && result is String) {
      authState = AuthState.unauthenticated;
      errorMessage = result;
      notifyListeners();
      return false;
    } else {
      authState = AuthState.unauthenticated;
      errorMessage = 'Login failed, Please try again.';
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
      sendOTP(user!.phoneNumber);
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

  Future<void> sendOTP(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
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
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
        notifyListeners();
      },
    );
  }

  Future<void> verifyOTP(String otp) async {
    final credential = auth.PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: otp);
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

  Future<void> loginWithPhoneNumber(auth.PhoneAuthCredential credential, String phoneNumber, String? firstName, String? lastName, Uint8List? imageData) async {
    dynamic result = await FireStoreUtils.loginOrCreateUserWithPhoneNumberCredential(
        credential: credential, phoneNumber: phoneNumber, firstName: firstName, lastName: lastName, imageData: imageData);
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

  Future<void> signupWithEmailAndPassword(String emailAddress, String password, Uint8List? imageData, String phoneNumber, String? firstName, String? lastName) async {
    dynamic result = await FireStoreUtils.signUpWithEmailAndPassword(
        emailAddress: emailAddress, password: password, imageData: imageData, phoneNumber: phoneNumber, firstName: firstName, lastName: lastName);
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

  Future<void> resendOTP() async {
    sendOTP(user!.phoneNumber);
  }
}

enum AuthState { firstRun, authenticated, unauthenticated, codeSent }
