import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:donstep/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _loading = true;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;

  AuthProvider() {
    _authService.authState.listen((user) {
      _user = user;
      _loading = false;
      notifyListeners();
    });
  }

  Future<String?> register(String email, String password, {String? name}) async {
    try {
      await _authService.register(email, password, name: name);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Ошибка регистрации';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _authService.login(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Ошибка входа';
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
