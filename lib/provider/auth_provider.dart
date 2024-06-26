import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _verificationId;
  String? errorMessage;

  User? get user => _user;

  Future<void> register(String email, String password, String phone) async {
    try {
      _user = await _authService.registerWithEmailPassword(email, password, phone);
      if (_user != null) {
        await _authService.sendVerificationCode(phone);
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      _user = await _authService.signInWithEmailPassword(email, password);
      if (_user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(_user?.uid).get();
        String phone = snapshot['phone'];
        await _authService.sendVerificationCode(phone);
      }
    } catch (e) {
      print("ERROR: >>>>>>>>>>>>>> ${e.toString()}");
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> verifyCode(String smsCode) async {
    if (_verificationId != null) {
      await _authService.verifyCode(_verificationId!, smsCode);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void clearErrorMessage() {
    errorMessage = null;
    notifyListeners();
  }
}
