import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/report_data.dart';

// Mock data for demonstration - replace with actual API calls
final appointmentStatsProvider = FutureProvider<AppointmentStats>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return const AppointmentStats(
    total: 234,
    completed: 198,
    cancelled: 28,
    noShow: 8,
    byMonth: {
      'Jan': 45,
      'Feb': 52,
      'Mar': 48,
      'Apr': 89,
    },
    byDayOfWeek: {
      'Mon': 42,
      'Tue': 38,
      'Wed': 45,
      'Thu': 40,
      'Fri': 35,
      'Sat': 25,
      'Sun': 9,
    },
    byTimeSlot: {
      '09:00': 28,
      '10:00': 32,
      '11:00': 35,
      '14:00': 30,
      '15:00': 27,
      '16:00': 22,
    },
  );
});

final demographicsProvider = FutureProvider<DemographicsData>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return const DemographicsData(
    ageGroups: {
      '0-18': 45,
      '19-35': 89,
      '36-50': 67,
      '51-65': 43,
      '65+': 32,
    },
    genderDistribution: {
      'Male': 142,
      'Female': 134,
      'Other': 0,
    },
    totalPatients: 276,
    newPatientsThisMonth: 23,
  );
});

final topConditionsProvider = FutureProvider<List<ConditionData>>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return [
    const ConditionData(name: 'Hypertension', count: 56, percentage: 20.3),
    const ConditionData(name: 'Diabetes Type 2', count: 48, percentage: 17.4),
    const ConditionData(name: 'Common Cold', count: 42, percentage: 15.2),
    const ConditionData(name: 'Migraine', count: 34, percentage: 12.3),
    const ConditionData(name: 'Asthma', count: 28, percentage: 10.1),
  ];
});