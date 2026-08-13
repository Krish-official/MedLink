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
import 'widgets/todays_queue_widget.dart';
import 'widgets/stats_summary.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final dashboardData = ref.watch(doctorDashboardDataProvider);
    
    // Watch refresh stream to auto-refresh
    ref.listen(dashboardRefreshProvider, (_, __) {
      ref.invalidate(doctorDashboardDataProvider);
    });

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
              'Dr. ${user?.lastName ?? ''}',
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
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(doctorDashboardDataProvider);
        },
        child: dashboardData.when(
          loading: () => const LoadingState(),
          error: (error, stack) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(doctorDashboardDataProvider),
          ),
          data: (data) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Summary
                StatsSummary(
                  totalPatients: data.totalPatientsToday,
                  completed: data.completedToday,
                  pending: data.pendingToday,
                  queueSize: data.currentQueueSize,
                ),
                const SizedBox(height: AppTokens.space24),

                // Next Appointment (if exists and no current)
                if (data.currentAppointment == null && data.nextAppointment != null) ...[
                  Card(
                    elevation: AppTokens.elevationSm,
                    color: AppColors.infoLight,
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.space16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.upcoming_outlined,
                            color: AppColors.info,
                            size: AppTokens.iconLg,
                          ),
                          const SizedBox(width: AppTokens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next Patient',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.infoDark,
                                  ),
                                ),
                                Text(
                                  data.nextAppointment!.patientName ?? 'Patient',
                                  style: AppTypography.h6.copyWith(
                                    color: AppColors.infoDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.space16),
                ],

                // Today's Queue
                TodaysQueueWidget(
                  appointments: data.todayAppointments,
                  currentAppointment: data.currentAppointment,
                  onRefresh: () => ref.invalidate(doctorDashboardDataProvider),
                ),
                const SizedBox(height: AppTokens.space24),

                // Quick Actions
                Text('Quick Actions', style: AppTypography.h5),
                const SizedBox(height: AppTokens.space16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: AppTokens.space12,
                  mainAxisSpacing: AppTokens.space12,
                  childAspectRatio: 1.5,
                  children: [
                    _QuickActionCard(
                      label: 'My Schedule',
                      icon: Icons.calendar_month_outlined,
                      color: AppColors.primary,
                      onTap: () => context.push(Routes.doctorSchedule),
                    ),
                    _QuickActionCard(
                      label: 'Patients',
                      icon: Icons.people_outline,
                      color: AppColors.accent,
                      onTap: () => context.push(Routes.doctorPatients),
                    ),
                    _QuickActionCard(
                      label: 'Prescriptions',
                      icon: Icons.medication_outlined,
                      color: AppColors.warning,
                      onTap: () => context.push(Routes.doctorPrescriptions),
                    ),
                    _QuickActionCard(
                      label: 'Reports',
                      icon: Icons.analytics_outlined,
                      color: AppColors.info,
                      onTap: () => context.push(Routes.doctorReports),
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

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Icon(icon, color: color, size: AppTokens.iconLg),
              ),
              const SizedBox(height: AppTokens.space12),
              Text(
                label,
                style: AppTypography.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}