import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import 'supabase_config.dart';

// Placeholder screens - Debes crear estos archivos en features
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
// import '../../features/home/presentation/pages/home_page.dart';
// import '../../features/mascotas/presentation/pages/mascotas_page.dart';
// import '../../features/citas/presentation/pages/citas_page.dart';

/// Provider del router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.splashRoute,
    redirect: (context, state) {
      final isAuthenticated = supabase.auth.currentUser != null;
      final isGoingToAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');

      // Si no está autenticado y no va a auth, redirigir a login
      if (!isAuthenticated && !isGoingToAuth && state.matchedLocation != '/') {
        return AppConstants.loginRoute;
      }

      // Si está autenticado y va a login/register, redirigir a home
      if (isAuthenticated && isGoingToAuth) {
        return AppConstants.homeRoute;
      }

      return null; // No hay redirección
    },
    routes: [
      // Splash
      GoRoute(
        path: AppConstants.splashRoute,
        builder: (context, state) => const SplashPage(),
      ),

      // Auth routes
      GoRoute(
        path: AppConstants.loginRoute,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppConstants.registerRoute,
        builder: (context, state) => const RegisterPage(),
      ),

      // Home routes
      GoRoute(
        path: AppConstants.homeRoute,
        builder: (context, state) => const PlaceholderPage(title: 'Home'),
      ),

      // Mascotas routes
      GoRoute(
        path: AppConstants.mascotasRoute,
        builder: (context, state) => const PlaceholderPage(title: 'Mascotas'),
      ),

      // Citas routes
      GoRoute(
        path: AppConstants.citasRoute,
        builder: (context, state) => const PlaceholderPage(title: 'Citas'),
      ),

      // Historial routes
      GoRoute(
        path: AppConstants.historialRoute,
        builder: (context, state) => const PlaceholderPage(title: 'Historial'),
      ),

      // Perfil routes
      GoRoute(
        path: AppConstants.perfilRoute,
        builder: (context, state) => const PlaceholderPage(title: 'Perfil'),
      ),

      // Ajustes routes
      GoRoute(
        path: AppConstants.ajustesRoute,
        builder: (context, state) => const PlaceholderPage(title: 'Ajustes'),
      ),
    ],
    errorBuilder: (context, state) => const PlaceholderPage(title: 'Error 404'),
  );
});

/// Página placeholder temporal
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$title - En desarrollo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
