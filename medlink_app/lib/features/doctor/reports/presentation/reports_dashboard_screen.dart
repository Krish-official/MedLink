import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/states/loading_state.dart';
import '../../../../core/widgets/states/error_state.dart';
import 'providers.dart';

class ReportsDashboardScreen extends ConsumerWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              // Export reports
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appointment Analytics', style: AppTypography.h5),
            const SizedBox(height: AppTokens.space16),
            _AppointmentStatsCard(),
            const SizedBox(height: AppTokens.space24),

            Text('Patient Demographics', style: AppTypography.h5),
            const SizedBox(height: AppTokens.space16),
            _DemographicsCard(),
            const SizedBox(height: AppTokens.space24),

            Text('Top Conditions', style: AppTypography.h5),
            const SizedBox(height: AppTokens.space16),
            _TopConditionsCard(),
            const SizedBox(height: AppTokens.space24),

            Text('Time Slot Heatmap', style: AppTypography.h5),
            const SizedBox(height: AppTokens.space16),
            _TimeSlotHeatmap(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// APPOINTMENT STATS CARD
// ═══════════════════════════════════════════════════════════════

class _AppointmentStatsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(appointmentStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(height: 300, child: LoadingState()),
      error: (e, s) => ErrorState(message: e.toString()),
      data: (stats) => Card(
        elevation: AppTokens.elevationSm,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Stats
              Row(
                children: [
                  _StatBox(
                    label: 'Total',
                    value: '${stats.total}',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppTokens.space12),
                  _StatBox(
                    label: 'Completed',
                    value: '${stats.completed}',
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppTokens.space12),
                  _StatBox(
                    label: 'Cancelled',
                    value: '${stats.cancelled}',
                    color: AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space24),

              // Monthly Chart
              Text('Appointments by Month', style: AppTypography.labelLarge),
              const SizedBox(height: AppTokens.space16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barGroups: stats.byMonth.entries.map((e) {
                      final index = stats.byMonth.keys.toList().indexOf(e.key);
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.toDouble(),
                            color: AppColors.primary,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final labels = stats.byMonth.keys.toList();
                            if (value.toInt() >= 0 && value.toInt() < labels.length) {
                              return Text(
                                labels[value.toInt()],
                                style: AppTypography.bodySmall,
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTokens.space12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.h4.copyWith(color: color)),
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

// ═══════════════════════════════════════════════════════════════
// DEMOGRAPHICS CARD
// ═══════════════════════════════════════════════════════════════

class _DemographicsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoAsync = ref.watch(demographicsProvider);

    return demoAsync.when(
      loading: () => const SizedBox(height: 300, child: LoadingState()),
      error: (e, s) => ErrorState(message: e.toString()),
      data: (demo) => Card(
        elevation: AppTokens.elevationSm,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DemoStat(
                    label: 'Total Patients',
                    value: '${demo.totalPatients}',
                  ),
                  _DemoStat(
                    label: 'New This Month',
                    value: '+${demo.newPatientsThisMonth}',
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space24),

              // Age Distribution
              Text('Age Distribution', style: AppTypography.labelLarge),
              const SizedBox(height: AppTokens.space16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: demo.ageGroups.entries.map((e) {
                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        title: '${e.key}\n${e.value}',
                        color: _getAgeGroupColor(e.key),
                        radius: 60,
                        titleStyle: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAgeGroupColor(String group) {
    switch (group) {
      case '0-18':
        return AppColors.primary;
      case '19-35':
        return AppColors.accent;
      case '36-50':
        return AppColors.warning;
      case '51-65':
        return AppColors.info;
      case '65+':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }
}

class _DemoStat extends StatelessWidget {
  final String label;
  final String value;

  const _DemoStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.h3.copyWith(color: AppColors.primary)),
        const SizedBox(height: AppTokens.space4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TOP CONDITIONS CARD
// ═══════════════════════════════════════════════════════════════

class _TopConditionsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditionsAsync = ref.watch(topConditionsProvider);

    return conditionsAsync.when(
      loading: () => const SizedBox(height: 200, child: LoadingState()),
      error: (e, s) => ErrorState(message: e.toString()),
      data: (conditions) => Card(
        elevation: AppTokens.elevationSm,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space16),
          child: Column(
            children: conditions.map((condition) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(condition.name, style: AppTypography.bodyMedium),
                        Text(
                          '${condition.percentage.toStringAsFixed(1)}%',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space8),
                    LinearProgressIndicator(
                      value: condition.percentage / 100,
                      backgroundColor: AppColors.gray200,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TIME SLOT HEATMAP
// ═══════════════════════════════════════════════════════════════

class _TimeSlotHeatmap extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(appointmentStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(height: 200, child: LoadingState()),
      error: (e, s) => ErrorState(message: e.toString()),
      data: (stats) {
        final maxValue = stats.byTimeSlot.values.reduce((a, b) => a > b ? a : b);

        return Card(
          elevation: AppTokens.elevationSm,
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.space16),
            child: Column(
              children: stats.byTimeSlot.entries.map((e) {
                final intensity = e.value / maxValue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.space8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(e.key, style: AppTypography.bodySmall),
                      ),
                      Expanded(
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(intensity * 0.8),
                            borderRadius: BorderRadius.circular(AppTokens.radiusXs),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTokens.space8,
                          ),
                          child: Text(
                            '${e.value}',
                            style: AppTypography.labelMedium.copyWith(
                              color: intensity > 0.5 ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}