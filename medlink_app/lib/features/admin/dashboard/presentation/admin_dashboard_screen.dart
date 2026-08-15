import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/router/routes.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push(Routes.adminSettings);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview
            Text('System Overview', style: AppTypography.h5),
            const SizedBox(height: AppTokens.space16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total Doctors',
                    value: '48',
                    icon: Icons.medical_services_outlined,
                    color: AppColors.primary,
                    onTap: () => context.push(Routes.adminDoctors),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: _StatCard(
                    label: 'Total Patients',
                    value: '1,234',
                    icon: Icons.people_outline,
                    color: AppColors.accent,
                    onTap: () => context.push(Routes.adminPatients),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Appointments Today',
                    value: '156',
                    icon: Icons.calendar_today_outlined,
                    color: AppColors.info,
                    onTap: () => context.push(Routes.adminAppointments),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: _StatCard(
                    label: 'Active Sessions',
                    value: '23',
                    icon: Icons.online_prediction,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space24),

            // Quick Actions
            Text('Management', style: AppTypography.h5),
            const SizedBox(height: AppTokens.space16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppTokens.space12,
              mainAxisSpacing: AppTokens.space12,
              childAspectRatio: 1.5,
              children: [
                _ManagementCard(
                  icon: Icons.person_add_outlined,
                  label: 'Add Doctor',
                  color: AppColors.primary,
                  onTap: () {
                    // Navigate to add doctor
                  },
                ),
                _ManagementCard(
                  icon: Icons.person_outline,
                  label: 'Add Patient',
                  color: AppColors.accent,
                  onTap: () {
                    // Navigate to add patient
                  },
                ),
                _ManagementCard(
                  icon: Icons.event_available_outlined,
                  label: 'Manage Appointments',
                  color: AppColors.info,
                  onTap: () => context.push(Routes.adminAppointments),
                ),
                _ManagementCard(
                  icon: Icons.analytics_outlined,
                  label: 'View Reports',
                  color: AppColors.warning,
                  onTap: () {
                    // Navigate to reports
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space24),

            // Recent Activity
            Text('Recent Activity', style: AppTypography.h5),
            const SizedBox(height: AppTokens.space16),
            _ActivityCard(
              icon: Icons.person_add,
              title: 'New doctor registered',
              subtitle: 'Dr. Sarah Johnson - Cardiology',
              time: '5 minutes ago',
              color: AppColors.primary,
            ),
            const SizedBox(height: AppTokens.space12),
            _ActivityCard(
              icon: Icons.event,
              title: 'Appointment booked',
              subtitle: 'John Doe with Dr. Smith',
              time: '12 minutes ago',
              color: AppColors.accent,
            ),
            const SizedBox(height: AppTokens.space12),
            _ActivityCard(
              icon: Icons.warning_amber,
              title: 'SOS Alert triggered',
              subtitle: 'Patient: Mary Wilson',
              time: '1 hour ago',
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: AppTokens.iconLg),
              const Spacer(),
              Text(value, style: AppTypography.h3.copyWith(color: color)),
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MANAGEMENT CARD
// ═══════════════════════════════════════════════════════════════

class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.icon,
    required this.label,
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
                width: 56,
                height: 56,
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
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ACTIVITY CARD
// ═══════════════════════════════════════════════════════════════

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
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