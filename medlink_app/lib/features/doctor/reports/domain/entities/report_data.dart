import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_data.freezed.dart';
part 'report_data.g.dart';

@freezed
class AppointmentStats with _$AppointmentStats {
  const factory AppointmentStats({
    required int total,
    required int completed,
    required int cancelled,
    required int noShow,
    required Map<String, int> byMonth,
    required Map<String, int> byDayOfWeek,
    required Map<String, int> byTimeSlot,
  }) = _AppointmentStats;

  factory AppointmentStats.fromJson(Map<String, dynamic> json) =>
      _$AppointmentStatsFromJson(json);
}

@freezed
class DemographicsData with _$DemographicsData {
  const factory DemographicsData({
    required Map<String, int> ageGroups,
    required Map<String, int> genderDistribution,
    required int totalPatients,
    required int newPatientsThisMonth,
  }) = _DemographicsData;

  factory DemographicsData.fromJson(Map<String, dynamic> json) =>
      _$DemographicsDataFromJson(json);
}

@freezed
class ConditionData with _$ConditionData {
  const factory ConditionData({
    required String name,
    required int count,
    required double percentage,
  }) = _ConditionData;

  factory ConditionData.fromJson(Map<String, dynamic> json) =>
      _$ConditionDataFromJson(json);
}