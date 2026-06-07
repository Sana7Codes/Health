import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/charts_screen.dart';
import '../screens/details_screen.dart';
import '../screens/login_screen.dart';
import '../screens/master_screen.dart';
import '../screens/profile_screen.dart';

/// Configuration du routeur Go Router avec garde d'authentification.
GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/patients',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuth = authProvider.isAuthenticated;
      final path = state.matchedLocation;

      // Garde : seul /profile nécessite obligatoirement une session.
      if (path == '/profile' && !isAuth) {
        return '/login';
      }
      // Si déjà connecté et qu'on revient sur /login, on redirige vers la liste.
      if (path == '/login' && isAuth) {
        return '/patients';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/patients',
        builder: (context, state) => const MasterScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return DetailsScreen(patientId: id);
            },
            routes: [
              GoRoute(
                path: 'charts',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return ChartsScreen(patientId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
