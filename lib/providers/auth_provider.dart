import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TokenStorage _storage = TokenStorage();

  bool _isAuthenticated = false;
  String? _userEmail;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Restaure une session existante au démarrage de l'application.
  Future<void> checkExistingSession() async {
    final token = await _storage.getAccessToken();
    final email = await _storage.getEmail();
    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      _userEmail = email;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _authService.login(email: email, password: password);
      _isAuthenticated = true;
      _userEmail = user.email;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAuthenticated = false;
      _userEmail = null;
      _error = 'Identifiants invalides ou erreur réseau.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _userEmail = null;
    _error = null;
    notifyListeners();
  }
}
