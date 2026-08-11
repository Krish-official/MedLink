import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/states/empty_state.dart';
import '../../../../core/widgets/states/error_state.dart';
import '../../../../core/widgets/states/loading_state.dart';
import '../../../shared/domain/entities/doctor.dart';
import 'providers.dart';
import 'widgets/doctor_card.dart';

class DoctorSearchScreen extends ConsumerStatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  ConsumerState<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends ConsumerState<DoctorSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onDoctorSelected(Doctor doctor) {
    ref.read(selectedDoctorProvider.notifier).state = doctor;
    context.push('/patient/book-appointment/slots');
  }

  @override
  Widget build(BuildContext context) {
    final specialtiesAsync = ref.watch(specialtiesProvider);
    final selectedSpecialty = ref.watch(selectedSpecialtyProvider);
    final doctorsAsync = ref.watch(doctorSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Doctor'),
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            padding: const EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or specialty',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(doctorSearchQueryProvider.notifier).state = null;
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    ref.read(doctorSearchQueryProvider.notifier).state =
                        value.isEmpty ? null : value;
                  },
                ),
                const SizedBox(height: AppTokens.space12),

                // Specialty Filter
                specialtiesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (specialties) => SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: specialties.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: AppTokens.space8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return FilterChip(
                            label: const Text('All'),
                            selected: selectedSpecialty == null,
                            onSelected: (_) {
                              ref.read(selectedSpecialtyProvider.notifier).state = null;
                            },
                          );
                        }

                        final specialty = specialties[index - 1];
                        return FilterChip(
                          label: Text(specialty),
                          selected: selectedSpecialty == specialty,
                          onSelected: (_) {
                            ref.read(selectedSpecialtyProvider.notifier).state = specialty;
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: doctorsAsync.when(
              loading: () => const LoadingState(),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(doctorSearchProvider),
              ),
              data: (doctors) {
                if (doctors.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No doctors found',
                    message: 'Try adjusting your search or filters',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppTokens.space16),
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppTokens.space12),
                  itemBuilder: (context, index) {
                    return DoctorCard(
                      doctor: doctors[index],
                      onTap: () => _onDoctorSelected(doctors[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}