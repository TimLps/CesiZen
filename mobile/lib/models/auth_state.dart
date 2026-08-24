import 'user.dart';

class AuthState {
  final String? token;
  final User? user;
  final bool isInitializing;

  const AuthState({this.token, this.user, this.isInitializing = false});

  const AuthState.initial() : token = null, user = null, isInitializing = true;
  const AuthState.unauthenticated() : token = null, user = null, isInitializing = false;

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({String? token, User? user, bool? isInitializing}) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
      isInitializing: isInitializing ?? this.isInitializing,
    );
  }
}
