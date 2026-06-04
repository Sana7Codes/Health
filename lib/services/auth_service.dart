import 'package:dio/dio.dart';

import '../models/auth_user.dart';
import 'api_service.dart';
import 'token_storage.dart';

/// Service d'authentification (login / logout / refresh).
class AuthService {
  final Dio _dio = ApiService().dio;
  final TokenStorage _storage = TokenStorage();

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data['data'] ?? response.data;
    final access = data['access_token']?.toString() ?? '';
    final refresh = data['refresh_token']?.toString() ?? '';
    if (access.isEmpty || refresh.isEmpty) {
      throw Exception('Réponse d\'authentification invalide.');
    }
    await _storage.saveTokens(
      accessToken: access,
      refreshToken: refresh,
      email: email,
    );
    return AuthUser(email: email, accessToken: access, refreshToken: refresh);
  }

  Future<void> logout() async {
    final refresh = await _storage.getRefreshToken();
    try {
      if (refresh != null && refresh.isNotEmpty) {
        await _dio.post('/auth/logout', data: {'refresh_token': refresh});
      }
    } catch (_) {
      // On ignore l'erreur de logout côté serveur.
    } finally {
      await _storage.clear();
    }
  }
}
