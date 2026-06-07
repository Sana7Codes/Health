import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/activities_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/patients_provider.dart';
import 'providers/psychic_provider.dart';
import 'routers/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientation portrait uniquement (format smartphone).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialisation des données de localisation française (intl).
  await initializeDateFormatting('fr_FR', null);

  final authProvider = AuthProvider();
  await authProvider.checkExistingSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => PatientsProvider()),
        ChangeNotifierProvider(create: (_) => ActivitiesProvider()),
        ChangeNotifierProvider(create: (_) => PsychicProvider()),
      ],
      child: const HealthApp(),
    ),
  );
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final router = buildRouter(auth);

    return MaterialApp.router(
      title: 'Application Santé',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D9E75)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1D9E75),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D9E75),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
