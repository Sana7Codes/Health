import 'package:dio/dio.dart';

import 'token_storage.dart';

/// Service API singleton encapsulant l'instance Dio partagée.
/// Injecte automatiquement le Bearer token et gère le refresh sur 401.
class ApiService {
  static const String baseUrl = 'https://health.shrp.dev';

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(_buildInterceptor());
  }

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();
  bool _isRefreshing = false;

  Dio get dio => _dio;

  InterceptorsWrapper _buildInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Injection automatique du Bearer token si disponible.
        final token = await _tokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Tentative de rafraîchissement du token en cas d'erreur 401.
        final statusCode = error.response?.statusCode;
        final requestPath = error.requestOptions.path;

        final isAuthEndpoint = requestPath.contains('/auth/');
        if (statusCode == 401 && !isAuthEndpoint && !_isRefreshing) {
          final refreshToken = await _tokenStorage.getRefreshToken();
          if (refreshToken == null || refreshToken.isEmpty) {
            return handler.next(error);
          }

          _isRefreshing = true;
          try {
            final response = await Dio(BaseOptions(baseUrl: baseUrl)).post(
              '/auth/refresh',
              data: {
                'refresh_token': refreshToken,
                'mode': 'json',
              },
            );
            final data = response.data['data'] ?? response.data;
            final newAccess = data['access_token']?.toString();
            final newRefresh = data['refresh_token']?.toString();
            if (newAccess != null) {
              await _tokenStorage.updateAccessToken(newAccess);
              if (newRefresh != null) {
                await _tokenStorage.saveTokens(
                  accessToken: newAccess,
                  refreshToken: newRefresh,
                );
              }
              // Rejoue la requête originale avec le nouveau token.
              final retry = error.requestOptions;
              retry.headers['Authorization'] = 'Bearer $newAccess';
              final cloned = await _dio.fetch(retry);
              _isRefreshing = false;
              return handler.resolve(cloned);
            }
          } catch (_) {
            // Échec du refresh : on laisse passer l'erreur.
          }
          _isRefreshing = false;
        }

        handler.next(error);
      },
    );
  }
}
