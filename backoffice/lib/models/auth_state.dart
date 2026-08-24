import 'user.dart';

class AuthState {
  final String? token;
  final User? user;
  final bool isInitializing;

  const AuthState({this.token, this.user, this.isInitializing = false});

  const AuthState.initial() : token = null, user = null, isInitializing = true;
  const AuthState.unauthenticated()
      : token = null, user = null, isInitializing = false;

  bool get isAuthenticated => token != null && user != null;
  bool get isAdminAuthenticated => isAuthenticated && (user?.isAdmin ?? false);
}
