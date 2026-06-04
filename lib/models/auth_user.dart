// Les données nécessaires à l'authentification d'un utilisateur (email + tokens).
class AuthUser {
  final String email;
  final String accessToken;
  final String refreshToken;

  AuthUser({
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });
}
