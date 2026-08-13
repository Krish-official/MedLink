import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/states/empty_state.dart';
import '../../../../core/widgets/states/error_state.dart';
import '../../../../core/widgets/states/loading_state.dart';
import '../domain/entities/patient_summary.dart';
import 'providers.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(doctorPatientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTokens.space16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients by name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(patientSearchQueryProvider.notifier).state = null;
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(patientSearchQueryProvider.notifier).state =
                    value.isEmpty ? null : value;
              },
            ),
          ),

          // Patients List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(doctorPatientsProvider);
              },
              child: patientsAsync.when(
                loading: () => const LoadingState(),
                error: (error, stack) => ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(doctorPatientsProvider),
                ),
                data: (patients) {
                  if (patients.isEmpty) {
                    return const EmptyState(
                      icon: Icons.people_outline,
                      title: 'No patients found',
                      message: 'Your patient list will appear here',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
                    itemCount: patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppTokens.space12),
                    itemBuilder: (context, index) {
                      return _PatientCard(
                        patient: patients[index],
                        onTap: () {
                          // Navigate to patient profile
                          context.push('/doctor/patients/${patients[index].id}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientSummary patient;
  final VoidCallback? onTap;

  const _PatientCard({
    required this.patient,
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: patient.avatar != null
                    ? NetworkImage(patient.avatar!)
                    : null,
                child: patient.avatar == null
                    ? Text(
                        patient.firstName[0] + patient.lastName[0],
                        style: AppTypography.h6,
                      )
                    : null,
              ),
              const SizedBox(width: AppTokens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: AppTypography.h6,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Row(
                      children: [
                        if (patient.age != null) ...[
                          Text(
                            '${patient.age} yrs',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppTokens.space8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.textSecondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppTokens.space8),
                        ],
                        if (patient.gender != null)
                          Text(
                            patient.gender!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (patient.bloodGroup != null) ...[
                          const SizedBox(width: AppTokens.space8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.space8,
                              vertical: AppTokens.space4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(AppTokens.radiusXs),
                            ),
                            child: Text(
                              patient.bloodGroup!,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppTokens.space8),
                    Text(
                      '${patient.totalVisits} visits',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}