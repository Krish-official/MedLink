import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/domain/entities/medical_record.dart';
import '../data/repository_impl/medical_records_repository_impl.dart';
import '../domain/repository/medical_records_repository.dart';

// Repository Provider
final medicalRecordsRepositoryProvider = Provider<MedicalRecordsRepository>((ref) {
  return MedicalRecordsRepositoryImpl(DioClient());
});

// Filter State
final recordTypeFilterProvider = StateProvider<RecordType?>((ref) => null);

// Medical Records List Provider
final medicalRecordsProvider = FutureProvider<List<MedicalRecord>>((ref) async {
  final repository = ref.watch(medicalRecordsRepositoryProvider);
  final filter = ref.watch(recordTypeFilterProvider);
  return repository.getMedicalRecords(type: filter);
});

// Upload State Provider
class UploadState {
  final bool isUploading;
  final double progress;
  final String? error;

  UploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.error,
  });

  UploadState copyWith({
    bool? isUploading,
    double? progress,
    String? error,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}

final uploadStateProvider = StateNotifierProvider<UploadStateNotifier, UploadState>(
  (ref) => UploadStateNotifier(ref.watch(medicalRecordsRepositoryProvider)),
);

class UploadStateNotifier extends StateNotifier<UploadState> {
  final MedicalRecordsRepository _repository;

  UploadStateNotifier(this._repository) : super(UploadState());

  Future<void> uploadRecord({
    required String title,
    required RecordType type,
    required File file,
    String? description,
    DateTime? recordDate,
  }) async {
    state = state.copyWith(isUploading: true, progress: 0.0, error: null);

    try {
      await _repository.uploadMedicalRecord(
        title: title,
        type: type,
        file: file,
        description: description,
        recordDate: recordDate,
      );

      state = state.copyWith(isUploading: false, progress: 1.0);
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        progress: 0.0,
        error: e.toString(),
      );
      rethrow;
    }
  }
}