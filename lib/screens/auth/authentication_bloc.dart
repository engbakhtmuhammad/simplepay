import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../services/authenticate.dart';
import '../../utils/constants.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  User? user;
  late SharedPreferences prefs;
  late bool finishedOnBoarding;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  String? verificationId;

  AuthenticationBloc({this.user}) : super(const AuthenticationState.unauthenticated()) {
    on<CheckFirstRunEvent>((event, emit) async {
      prefs = await SharedPreferences.getInstance();
      finishedOnBoarding = prefs.getBool(finishedOnBoardingConst) ?? false;
      if (!finishedOnBoarding) {
        emit(const AuthenticationState.onboarding());
      } else {
        user = await FireStoreUtils.getAuthUser();
        if (user == null) {
          emit(const AuthenticationState.unauthenticated());
        } else {
          emit(AuthenticationState.authenticated(user!));
          add(SendOTPEvent(user!.phoneNumber)); // Automatically send OTP
        }
      }
    });

    on<FinishedOnBoardingEvent>((event, emit) async {
      await prefs.setBool(finishedOnBoardingConst, true);
      emit(const AuthenticationState.unauthenticated());
    });

    on<LoginWithEmailAndPasswordEvent>((event, emit) async {
      dynamic result = await FireStoreUtils.loginWithEmailAndPassword(
          event.email, event.password);
      if (result != null && result is User) {
        user = result;
        emit(AuthenticationState.authenticated(user!));
        add(SendOTPEvent(user!.phoneNumber)); // Automatically send OTP
      } else if (result != null && result is String) {
        emit(AuthenticationState.unauthenticated(message: result));
      } else {
        emit(const AuthenticationState.unauthenticated(
            message: 'Login failed, Please try again.'));
      }
    });

    on<LoginWithAppleEvent>((event, emit) async {
      dynamic result = await FireStoreUtils.loginWithApple();
      if (result != null && result is User) {
        user = result;
        emit(AuthenticationState.authenticated(user!));
        add(SendOTPEvent(user!.phoneNumber)); // Automatically send OTP
      } else if (result != null && result is String) {
        emit(AuthenticationState.unauthenticated(message: result));
      } else {
        emit(const AuthenticationState.unauthenticated(
            message: 'Apple login failed, Please try again.'));
      }
    });

    on<SendOTPEvent>((event, emit) async {
      await sendOTP(event.phoneNumber);
    });

    on<VerifyOTPEvent>((event, emit) async {
      final credential = auth.PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: event.otp);
      try {
        await _auth.signInWithCredential(credential);
        emit(AuthenticationState.authenticated(user!));
      } catch (e) {
        emit(AuthenticationState.unauthenticated(message: 'Invalid OTP. Please try again.'));
      }
    });

    on<LoginWithPhoneNumberEvent>((event, emit) async {
      dynamic result = await FireStoreUtils.loginOrCreateUserWithPhoneNumberCredential(
          credential: event.credential,
          phoneNumber: event.phoneNumber,
          firstName: event.firstName,
          lastName: event.lastName,
          imageData: event.imageData);
      if (result is User) {
        user = result;
        emit(AuthenticationState.authenticated(result));
      } else if (result is String) {
        emit(AuthenticationState.unauthenticated(message: result));
      }
    });

    on<SignupWithEmailAndPasswordEvent>((event, emit) async {
      dynamic result = await FireStoreUtils.signUpWithEmailAndPassword(
          emailAddress: event.emailAddress,
          password: event.password,
          imageData: event.imageData,
          phoneNumber: event.phoneNumber,
          firstName: event.firstName,
          lastName: event.lastName);
      if (result != null && result is User) {
        user = result;
        emit(AuthenticationState.authenticated(user!));
      } else if (result != null && result is String) {
        emit(AuthenticationState.unauthenticated(message: result));
      } else {
        emit(const AuthenticationState.unauthenticated(
            message: 'Couldn\'t sign up'));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await FireStoreUtils.logout();
      user = null;
      emit(const AuthenticationState.unauthenticated());
    });

    on<ResendOTPEvent>((event, emit) async {
      await sendOTP(user!.phoneNumber);
    });
  }

  Future<void> sendOTP(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (auth.PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        emit(AuthenticationState.authenticated(user!));
      },
      verificationFailed: (auth.FirebaseAuthException e) {
        emit(AuthenticationState.unauthenticated(message: 'Verification failed. Please try again.'));
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId;
        emit(AuthenticationState.codeSent(verificationId));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
        emit(AuthenticationState.codeAutoRetrievalTimeout(verificationId));
      },
    );
  }

  Future<void> verifyOTP(String otp) async {
    try {
      final credential = auth.PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: otp);
      await _auth.signInWithCredential(credential);
      emit(AuthenticationState.authenticated(user!));
    } catch (e) {
      emit(AuthenticationState.unauthenticated(message: 'Invalid OTP. Please try again.'));
    }
  }
}
