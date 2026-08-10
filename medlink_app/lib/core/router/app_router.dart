import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/providers.dart';
import 'routes.dart';

// Placeholder screens (will be built in later phases)
class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Dashboard')),
      body: const Center(child: Text('Patient Dashboard')),
    );
  }
}

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Dashboard')),
      body: const Center(child: Text('Doctor Dashboard')),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(child: Text('Admin Dashboard')),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateProvider.notifier).stream),
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final user = authState.value;
      final isAuthenticated = user != null;

      final isLoginRoute = state.matchedLocation == Routes.login;
      final isRegisterRoute = state.matchedLocation == Routes.register;
      final isAuthRoute = isLoginRoute || isRegisterRoute;

      // Still loading - show nothing or a splash screen
      if (isLoading) {
        return null;
      }

      // Not authenticated - redirect to login unless already on auth route
      if (!isAuthenticated) {
        return isAuthRoute ? null : Routes.login;
      }

      // Authenticated but on auth route - redirect to appropriate dashboard
      if (isAuthRoute) {
        return _getDashboardRoute(user.role);
      }

      // Check role-based access
      final currentPath = state.matchedLocation;
      if (!_hasAccessToRoute(currentPath, user.role)) {
        return _getDashboardRoute(user.role);
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Patient Routes
      GoRoute(
        path: Routes.patientDashboard,
        builder: (context, state) => const PatientDashboardScreen(),
      ),

      // Doctor Routes
      GoRoute(
        path: Routes.doctorDashboard,
        builder: (context, state) => const DoctorDashboardScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: Routes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
});

String _getDashboardRoute(UserRole role) {
  switch (role) {
    case UserRole.patient:
      return Routes.patientDashboard;
    case UserRole.doctor:
      return Routes.doctorDashboard;
    case UserRole.admin:
      return Routes.adminDashboard;
  }
}

bool _hasAccessToRoute(String path, UserRole role) {
  if (path.startsWith('/patient') && role != UserRole.patient) {
    return false;
  }
  if (path.startsWith('/doctor') && role != UserRole.doctor) {
    return false;
  }
  if (path.startsWith('/admin') && role != UserRole.admin) {
    return false;
  }
  return true;
}

// Helper class to make GoRouter reactive to auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}