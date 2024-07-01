import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  bool get loading => _loading;

  // Future<User?> registerWithEmailPassword(String email, String password, String phone, String? firstName, String? lastName, Uint8List? imageData) async {
  //   try {
  //     _loading = true;
  //     notifyListeners();

  //     UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  //     User? user = result.user;
  //     await _firestore.collection('users').doc(user?.uid).set({'phone': phone});

  //     _loading = false;
  //     notifyListeners();

  //     return user;
  //   } catch (e) {
  //     _loading = false;
  //     notifyListeners();
  //     print(e);
  //     return null;
  //   }
  // }
  Future<User?> registerWithEmailPassword(
      String email, String password, String phone, String? firstName, String? lastName, Uint8List? imageData) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phone,
          'profilePictureURL': imageData,
          'userID': user.uid
        });

        return user;
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();

      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      _loading = false;
      notifyListeners();

      return user;
    } catch (e) {
      _loading = false;
      notifyListeners();
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendVerificationCode(String phoneNumber) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verificationId for later use
          _loading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _loading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _loading = false;
      notifyListeners();
      print(e);
    }
  }

  Future<void> verifyCode(String verificationId, String smsCode) async {
    try {
      _loading = true;
      notifyListeners();

      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      await _auth.signInWithCredential(credential);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      notifyListeners();
      print(e);
    }
  }
}
