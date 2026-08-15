import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/widgets/login_screen.dart';
import '../../features/auth/presentation/widgets/register_screen.dart';
import '../../features/auth/presentation/widgets/providers.dart';
import 'routes.dart';
import '../../features/patient/book_appointment/presentation/doctor_search_screen.dart';
import '../../features/patient/book_appointment/presentation/slot_picker_screen.dart';
import '../../features/patient/book_appointment/presentation/booking_confirmation_screen.dart';
import '../../features/patient/book_appointment/presentation/booking_success_screen.dart';
import '../../features/patient/appointments/presentation/my_appointments_screen.dart';
import '../../features/doctor/dashboard/presentation/doctor_dashboard_screen.dart';
import '../../features/doctor/schedule/presentation/schedule_calendar_screen.dart';
import '../../features/doctor/patients/presentation/patient_list_screen.dart';
import '../../features/doctor/patients/presentation/patient_profile_screen.dart';
import '../../features/doctor/prescriptions/presentation/prescription_editor_screen.dart';
import '../../features/patient/dashboard/presentation/patient_dashboard_screen.dart';
import '../../features/patient/medical_records/presentation/medical_records_screen.dart';
import '../../features/patient/emergency/presentation/emergency_screen.dart';
import '../../features/doctor/reports/presentation/reports_dashboard_screen.dart';

// Placeholder screens (will be built in later phases)


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
      // Patient - Medical Records
GoRoute(
  path: Routes.patientMedicalRecords,
  builder: (context, state) => const MedicalRecordsScreen(),
),

// Patient - Emergency
GoRoute(
  path: Routes.patientEmergency,
  builder: (context, state) => const EmergencyScreen(),
),

// Doctor - Reports
GoRoute(
  path: Routes.doctorReports,
  builder: (context, state) => const ReportsDashboardScreen(),
),

      // Patient Routes
GoRoute(
  path: Routes.patientDashboard,
  builder: (context, state) => const PatientDashboardScreen(),
),
GoRoute(
  path: '/patient/book-appointment',
  builder: (context, state) => const DoctorSearchScreen(),
),
GoRoute(
  path: '/patient/book-appointment/slots',
  builder: (context, state) => const SlotPickerScreen(),
),
GoRoute(
  path: '/patient/book-appointment/confirm',
  builder: (context, state) => const BookingConfirmationScreen(),
),
GoRoute(
  path: '/patient/book-appointment/success',
  builder: (context, state) => const BookingSuccessScreen(),
),
GoRoute(
  path: Routes.patientAppointments,
  builder: (context, state) => const MyAppointmentsScreen(),
),

      // Doctor Routes
      GoRoute(
        path: Routes.doctorDashboard,
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
  path: Routes.doctorSchedule,
  builder: (context, state) => const ScheduleCalendarScreen(),
),
GoRoute(
  path: Routes.doctorPatients,
  builder: (context, state) => const PatientListScreen(),
),
GoRoute(
  path: '/doctor/patients/:id',
  builder: (context, state) {
    final patientId = state.pathParameters['id']!;
    return PatientProfileScreen(patientId: patientId);
  },
),
GoRoute(
  path: '/doctor/prescriptions/new',
  builder: (context, state) {
    final patientId = state.uri.queryParameters['patientId']!;
    final patientName = state.uri.queryParameters['patientName'];
    return PrescriptionEditorScreen(
      patientId: patientId,
      patientName: patientName,
    );
  },
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