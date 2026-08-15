import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/states/empty_state.dart';
import '../../../../core/widgets/states/error_state.dart';
import '../../../../core/widgets/states/loading_state.dart';
import '../../../auth/presentation/widgets/providers.dart';
import 'providers.dart';
import 'widgets/upcoming_appointment_card.dart';
import 'widgets/quick_actions.dart';

class PatientDashboardScreen extends ConsumerWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final dashboardData = ref.watch(patientDashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              user?.firstName ?? '',
              style: AppTypography.h6,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push(Routes.patientProfile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(patientDashboardDataProvider);
        },
        child: dashboardData.when(
          loading: () => const LoadingState(),
          error: (error, stack) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(patientDashboardDataProvider),
          ),
          data: (data) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upcoming Appointment
                if (data.upcomingAppointment != null) ...[
                  UpcomingAppointmentCard(
                    appointment: data.upcomingAppointment!,
                    onTap: () {
                      // TODO: Navigate to appointment details
                    },
                  ),
                  const SizedBox(height: AppTokens.space24),
                ] else ...[
                  EmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'No upcoming appointments',
                    message: 'Book an appointment with a doctor',
                    actionLabel: 'Book Now',
                    onAction: () {
                      context.push(Routes.patientBookAppointment);
                    },
                  ),
                  const SizedBox(height: AppTokens.space24),
                ],

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: AppTypography.h5,
                ),
                const SizedBox(height: AppTokens.space16),
                QuickActions(
                  actions: [
                    QuickAction(
                      label: 'Book Appointment',
                      icon: Icons.add_circle_outline,
                      color: AppColors.primary,
                      onTap: () {
                        context.push(Routes.patientBookAppointment);
                      },
                    ),
                    QuickAction(
                      label: 'My Appointments',
                      icon: Icons.event_note_outlined,
                      color: AppColors.accent,
                      onTap: () {
                        context.push(Routes.patientAppointments);
                      },
                    ),
                    QuickAction(
                      label: 'Medical Records',
                      icon: Icons.description_outlined,
                      color: AppColors.info,
                      onTap: () {
                        context.push(Routes.patientMedicalRecords);
                      },
                    ),
                    QuickAction(
                      label: 'Prescriptions',
                      icon: Icons.medication_outlined,
                      color: AppColors.warning,
                      onTap: () {
                        context.push(Routes.patientPrescriptions);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space24),

                // Stats Overview
                Text(
                  'Overview',
                  style: AppTypography.h5,
                ),
                const SizedBox(height: AppTokens.space16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total',
                        value: '${data.totalAppointments}',
                        icon: Icons.calendar_month_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppTokens.space12),
                    Expanded(
                      child: _StatCard(
                        label: 'Completed',
                        value: '${data.completedAppointments}',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: AppTokens.iconLg),
            const SizedBox(height: AppTokens.space12),
            Text(
              value,
              style: AppTypography.h3.copyWith(color: color),
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}