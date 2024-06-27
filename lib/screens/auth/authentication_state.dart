part of 'authentication_bloc.dart';

enum AuthState { firstRun, authenticated, unauthenticated, codeSent }

class AuthenticationState {
  final AuthState authState;
  final User? user;
  final String? message;
  final String? verificationId;

  const AuthenticationState._(this.authState, {this.user, this.message, this.verificationId});

  const AuthenticationState.authenticated(User user)
      : this._(AuthState.authenticated, user: user);

  const AuthenticationState.unauthenticated({String? message})
      : this._(AuthState.unauthenticated, message: message ?? 'Unauthenticated');

  const AuthenticationState.onboarding() : this._(AuthState.firstRun);

  const AuthenticationState.codeSent(String verificationId)
      : this._(AuthState.unauthenticated, verificationId: verificationId);

  const AuthenticationState.codeAutoRetrievalTimeout(String verificationId)
      : this._(AuthState.unauthenticated, verificationId: verificationId);
}
