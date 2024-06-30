part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {}

class LoginWithEmailAndPasswordEvent extends AuthenticationEvent {
  String email;
  String password;

  LoginWithEmailAndPasswordEvent({required this.email, required this.password});
}

class LoginWithFacebookEvent extends AuthenticationEvent {}

class LoginWithAppleEvent extends AuthenticationEvent {}

class LoginWithPhoneNumberEvent extends AuthenticationEvent {
  auth.PhoneAuthCredential credential;
  String phoneNumber;
  String? firstName, lastName;
  Uint8List? imageData;

  LoginWithPhoneNumberEvent({
    required this.credential,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.imageData,
  });
}

class SignupWithEmailAndPasswordEvent extends AuthenticationEvent {
  String emailAddress;
  String password;
  Uint8List? imageData;
  String? firstName;
  String? lastName;
  String phoneNumber;

  SignupWithEmailAndPasswordEvent({
    required this.emailAddress,
    required this.password,
    this.imageData,
    required this.phoneNumber,
    this.firstName = 'Anonymous',
    this.lastName = 'User',
  });
}

class LogoutEvent extends AuthenticationEvent {
  LogoutEvent();
}

class FinishedOnBoardingEvent extends AuthenticationEvent {}

class CheckFirstRunEvent extends AuthenticationEvent {}

class SendOTPEvent extends AuthenticationEvent {
  final String phoneNumber;

  SendOTPEvent(this.phoneNumber);
}

class VerifyOTPEvent extends AuthenticationEvent {
  final String otp;

  VerifyOTPEvent({required this.otp});
}

class ResendOTPEvent extends AuthenticationEvent {}
