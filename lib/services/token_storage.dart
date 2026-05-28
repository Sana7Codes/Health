import 'package:shared_preferences/shared_preferences.dart';

/// Stockage local des jetons d'authentification via SharedPreferences.
class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _emailKey = 'user_email';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, accessToken);
    await prefs.setString(_refreshKey, refreshToken);
    if (email != null) {
      await prefs.setString(_emailKey, email);
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> updateAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, accessToken);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_emailKey);
  }
}
