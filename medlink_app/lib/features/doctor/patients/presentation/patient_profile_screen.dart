import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/states/loading_state.dart';
import '../../../../core/widgets/states/error_state.dart';
import 'providers.dart';
import '../domain/entities/patient_summary.dart';

class PatientProfileScreen extends ConsumerWidget {
  final String patientId;

  const PatientProfileScreen({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientDetailProvider(patientId));

    return Scaffold(
      body: patientAsync.when(
        loading: () => const LoadingState(),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(patientDetailProvider(patientId)),
        ),
        data: (patient) => DefaultTabController(
          length: 4,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: patient.avatar != null
                                ? NetworkImage(patient.avatar!)
                                : null,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: patient.avatar == null
                                ? Text(
                                    patient.firstName[0] + patient.lastName[0],
                                    style: AppTypography.h3.copyWith(
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: AppTokens.space12),
                          Text(
                            patient.fullName,
                            style: AppTypography.h5.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: AppTokens.space4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (patient.age != null) ...[
                                Text(
                                  '${patient.age} years',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(width: AppTokens.space8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppTokens.space8),
                              ],
                              if (patient.gender != null)
                                Text(
                                  patient.gender!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              if (patient.bloodGroup != null) ...[
                                const SizedBox(width: AppTokens.space8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppTokens.space8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTokens.space8,
                                    vertical: AppTokens.space4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.radiusXs,
                                    ),
                                  ),
                                  child: Text(
                                    patient.bloodGroup!,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Vitals'),
                    Tab(text: 'History'),
                    Tab(text: 'Documents'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _OverviewTab(patient: patient),
                _VitalsTab(patientId: patientId),
                _HistoryTab(patientId: patientId),
                _DocumentsTab(patientId: patientId),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to prescription editor
        },
        icon: const Icon(Icons.medication_outlined),
        label: const Text('New Prescription'),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ═══════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final dynamic patient;

  const _OverviewTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Info Card
          Card(
            elevation: AppTokens.elevationSm,
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact Information', style: AppTypography.h6),
                  const SizedBox(height: AppTokens.space16),
                  if (patient.phone != null)
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: patient.phone!,
                    ),
                  if (patient.email != null) ...[
                    const SizedBox(height: AppTokens.space12),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: patient.email!,
                    ),
                  ],
                  if (patient.dateOfBirth != null) ...[
                    const SizedBox(height: AppTokens.space12),
                    _InfoRow(
                      icon: Icons.cake_outlined,
                      label: 'Date of Birth',
                      value: DateFormat('MMM dd, yyyy').format(patient.dateOfBirth!),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space16),

          // Visit Stats
          Card(
            elevation: AppTokens.elevationSm,
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Visit Statistics', style: AppTypography.h6),
                  const SizedBox(height: AppTokens.space16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          label: 'Total Visits',
                          value: '${patient.totalVisits}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppTokens.space12),
                      Expanded(
                        child: _StatBox(
                          label: 'Last Visit',
                          value: patient.lastVisit != null
                              ? DateFormat('MMM dd').format(patient.lastVisit!)
                              : 'N/A',
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppTokens.iconSm, color: AppColors.textSecondary),
        const SizedBox(width: AppTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(value, style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.h4.copyWith(color: color),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// VITALS TAB
// ═══════════════════════════════════════════════════════════════

class _VitalsTab extends StatelessWidget {
  final String patientId;

  const _VitalsTab({required this.patientId});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch actual vitals data
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Vitals', style: AppTypography.h6),
              TextButton.icon(
                onPressed: () {
                  // Add new vitals
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Vitals'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space16),

          // Vitals Cards
          _VitalCard(
            icon: Icons.favorite_outline,
            label: 'Blood Pressure',
            value: '120/80',
            unit: 'mmHg',
            color: AppColors.error,
            trend: VitalTrend.normal,
          ),
          const SizedBox(height: AppTokens.space12),
          _VitalCard(
            icon: Icons.monitor_heart_outlined,
            label: 'Heart Rate',
            value: '72',
            unit: 'bpm',
            color: AppColors.primary,
            trend: VitalTrend.normal,
          ),
          const SizedBox(height: AppTokens.space12),
          _VitalCard(
            icon: Icons.thermostat_outlined,
            label: 'Temperature',
            value: '98.6',
            unit: '°F',
            color: AppColors.warning,
            trend: VitalTrend.normal,
          ),
          const SizedBox(height: AppTokens.space12),
          _VitalCard(
            icon: Icons.air_outlined,
            label: 'Oxygen Saturation',
            value: '98',
            unit: '%',
            color: AppColors.info,
            trend: VitalTrend.normal,
          ),
        ],
      ),
    );
  }
}

enum VitalTrend { high, normal, low }

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final VitalTrend trend;

  const _VitalCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.trend,
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Icon(icon, color: color, size: AppTokens.iconLg),
            ),
            const SizedBox(width: AppTokens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  )),
                  const SizedBox(height: AppTokens.space4),
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(value, style: AppTypography.h4),
                      const SizedBox(width: AppTokens.space4),
                      Text(
                        unit,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _getTrendIcon(trend),
          ],
        ),
      ),
    );
  }

  Widget _getTrendIcon(VitalTrend trend) {
    switch (trend) {
      case VitalTrend.high:
        return const Icon(Icons.trending_up, color: AppColors.error);
      case VitalTrend.low:
        return const Icon(Icons.trending_down, color: AppColors.warning);
      case VitalTrend.normal:
        return const Icon(Icons.check_circle_outline, color: AppColors.success);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// HISTORY TAB
// ═══════════════════════════════════════════════════════════════

class _HistoryTab extends StatelessWidget {
  final String patientId;

  const _HistoryTab({required this.patientId});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch actual history data
    final mockHistory = [
      _HistoryItem(
        date: DateTime.now().subtract(const Duration(days: 7)),
        type: 'Prescription',
        title: 'Antibiotics prescribed',
        doctor: 'Dr. Smith',
      ),
      _HistoryItem(
        date: DateTime.now().subtract(const Duration(days: 14)),
        type: 'Diagnosis',
        title: 'Common Cold',
        doctor: 'Dr. Johnson',
      ),
      _HistoryItem(
        date: DateTime.now().subtract(const Duration(days: 30)),
        type: 'Lab Test',
        title: 'Blood Test - Complete',
        doctor: 'Dr. Smith',
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(AppTokens.space16),
      itemCount: mockHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTokens.space12),
      itemBuilder: (context, index) {
        final item = mockHistory[index];
        return _HistoryItemCard(item: item);
      },
    );
  }
}

class _HistoryItem {
  final DateTime date;
  final String type;
  final String title;
  final String doctor;

  _HistoryItem({
    required this.date,
    required this.type,
    required this.title,
    required this.doctor,
  });
}

class _HistoryItemCard extends StatelessWidget {
  final _HistoryItem item;

  const _HistoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: _getTypeColor(item.type),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.space8,
                          vertical: AppTokens.space4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(item.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTokens.radiusXs),
                        ),
                        child: Text(
                          item.type,
                          style: AppTypography.labelSmall.copyWith(
                            color: _getTypeColor(item.type),
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(item.date),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.space8),
                  Text(item.title, style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    'By ${item.doctor}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'prescription':
        return AppColors.primary;
      case 'diagnosis':
        return AppColors.warning;
      case 'lab test':
        return AppColors.info;
      case 'procedure':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// DOCUMENTS TAB
// ═══════════════════════════════════════════════════════════════

class _DocumentsTab extends StatelessWidget {
  final String patientId;

  const _DocumentsTab({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 64,
            color: AppColors.gray300,
          ),
          const SizedBox(height: AppTokens.space16),
          Text(
            'No documents yet',
            style: AppTypography.h6,
          ),
          const SizedBox(height: AppTokens.space8),
          Text(
            'Medical records and documents will appear here',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.space24),
          ElevatedButton.icon(
            onPressed: () {
              // Upload document
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Document'),
          ),
        ],
      ),
    );
  }
}