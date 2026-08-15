import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/states/empty_state.dart';
import '../../../../core/widgets/states/error_state.dart';
import '../../../../core/widgets/states/loading_state.dart';
import '../../../shared/domain/entities/medical_record.dart';
import 'providers.dart';

class MedicalRecordsScreen extends ConsumerWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(medicalRecordsProvider);
    final selectedFilter = ref.watch(recordTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          if (selectedFilter != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space16,
                vertical: AppTokens.space8,
              ),
              child: Row(
                children: [
                  Chip(
                    label: Text(selectedFilter.name),
                    onDeleted: () {
                      ref.read(recordTypeFilterProvider.notifier).state = null;
                    },
                  ),
                ],
              ),
            ),

          // Records List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(medicalRecordsProvider);
              },
              child: recordsAsync.when(
                loading: () => const LoadingState(),
                error: (error, stack) => ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(medicalRecordsProvider),
                ),
                data: (records) {
                  if (records.isEmpty) {
                    return EmptyState(
                      icon: Icons.folder_outlined,
                      title: 'No records yet',
                      message: 'Upload your medical records to keep them safe',
                      actionLabel: 'Upload Record',
                      onAction: () => _showUploadSheet(context, ref),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppTokens.space16),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppTokens.space12),
                    itemBuilder: (context, index) {
                      return _RecordCard(
                        record: records[index],
                        onTap: () {
                          // Open record viewer
                        },
                        onDelete: () => _deleteRecord(context, ref, records[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadSheet(context, ref),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTokens.space16),
              child: Text('Filter by Type', style: AppTypography.h6),
            ),
            const Divider(),
            ...RecordType.values.map((type) {
              return ListTile(
                title: Text(_getTypeLabel(type)),
                leading: Icon(_getTypeIcon(type)),
                onTap: () {
                  ref.read(recordTypeFilterProvider.notifier).state = type;
                  Navigator.pop(context);
                },
              );
            }),
            ListTile(
              title: const Text('Clear Filter'),
              leading: const Icon(Icons.clear),
              onTap: () {
                ref.read(recordTypeFilterProvider.notifier).state = null;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _UploadRecordSheet(),
    );
  }

  void _deleteRecord(BuildContext context, WidgetRef ref, MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete "${record.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(medicalRecordsRepositoryProvider)
                    .deleteMedicalRecord(record.id);
                ref.invalidate(medicalRecordsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Record deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(RecordType type) {
    switch (type) {
      case RecordType.labReport:
        return 'Lab Report';
      case RecordType.imaging:
        return 'Imaging';
      case RecordType.document:
        return 'Document';
      case RecordType.prescription:
        return 'Prescription';
      case RecordType.discharge:
        return 'Discharge Summary';
      case RecordType.other:
        return 'Other';
    }
  }

  IconData _getTypeIcon(RecordType type) {
    switch (type) {
      case RecordType.labReport:
        return Icons.science_outlined;
      case RecordType.imaging:
        return Icons.medical_information_outlined;
      case RecordType.document:
        return Icons.description_outlined;
      case RecordType.prescription:
        return Icons.medication_outlined;
      case RecordType.discharge:
        return Icons.exit_to_app_outlined;
      case RecordType.other:
        return Icons.insert_drive_file_outlined;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// RECORD CARD
// ═══════════════════════════════════════════════════════════════

class _RecordCard extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _RecordCard({
    required this.record,
    this.onTap,
    this.onDelete,
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
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTypeColor(record.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: Icon(
                      _getTypeIcon(record.type),
                      color: _getTypeColor(record.type),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.title, style: AppTypography.h6),
                        const SizedBox(height: AppTokens.space4),
                        Text(
                          record.typeLabel,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                      onPressed: onDelete,
                    ),
                ],
              ),
              if (record.description != null) ...[
                const SizedBox(height: AppTokens.space12),
                Text(
                  record.description!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppTokens.space12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: AppTokens.iconXs,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppTokens.space4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(record.uploadedAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppTokens.space16),
                  Icon(
                    Icons.insert_drive_file_outlined,
                    size: AppTokens.iconXs,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppTokens.space4),
                  Text(
                    record.fileSizeFormatted,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(RecordType type) {
    switch (type) {
      case RecordType.labReport:
        return AppColors.primary;
      case RecordType.imaging:
        return AppColors.info;
      case RecordType.document:
        return AppColors.accent;
      case RecordType.prescription:
        return AppColors.warning;
      case RecordType.discharge:
        return AppColors.error;
      case RecordType.other:
        return AppColors.gray500;
    }
  }

  IconData _getTypeIcon(RecordType type) {
    switch (type) {
      case RecordType.labReport:
        return Icons.science_outlined;
      case RecordType.imaging:
        return Icons.medical_information_outlined;
      case RecordType.document:
        return Icons.description_outlined;
      case RecordType.prescription:
        return Icons.medication_outlined;
      case RecordType.discharge:
        return Icons.exit_to_app_outlined;
      case RecordType.other:
        return Icons.insert_drive_file_outlined;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// UPLOAD SHEET
// ═══════════════════════════════════════════════════════════════

class _UploadRecordSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_UploadRecordSheet> createState() => _UploadRecordSheetState();
}

class _UploadRecordSheetState extends ConsumerState<_UploadRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  RecordType _selectedType = RecordType.document;
  DateTime? _recordDate;
  File? _selectedFile;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and select a file'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await ref.read(uploadStateProvider.notifier).uploadRecord(
            title: _titleController.text.trim(),
            type: _selectedType,
            file: _selectedFile!,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            recordDate: _recordDate,
          );

      ref.invalidate(medicalRecordsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record uploaded successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadStateProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Medical Record', style: AppTypography.h5),
              const SizedBox(height: AppTokens.space24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppTokens.space16),

              // Type Dropdown
              DropdownButtonFormField<RecordType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: RecordType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: AppTokens.space16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
              ),
              const SizedBox(height: AppTokens.space16),

              // Record Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Record Date (Optional)'),
                subtitle: Text(
                  _recordDate != null
                      ? DateFormat('MMM dd, yyyy').format(_recordDate!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _recordDate = date);
                  }
                },
              ),
              const SizedBox(height: AppTokens.space16),

              // File Picker
              OutlinedButton.icon(
                onPressed: uploadState.isUploading ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _selectedFile != null
                      ? _selectedFile!.path.split('/').last
                      : 'Select File',
                ),
              ),
              const SizedBox(height: AppTokens.space24),

              // Upload Progress
              if (uploadState.isUploading)
                Column(
                  children: [
                    LinearProgressIndicator(value: uploadState.progress),
                    const SizedBox(height: AppTokens.space8),
                    Text(
                      'Uploading... ${(uploadState.progress * 100).toStringAsFixed(0)}%',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space16),
                  ],
                ),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: uploadState.isUploading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Upload',
                      onPressed: uploadState.isUploading ? null : _upload,
                      isLoading: uploadState.isUploading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(RecordType type) {
    switch (type) {
      case RecordType.labReport:
        return 'Lab Report';
      case RecordType.imaging:
        return 'Imaging';
      case RecordType.document:
        return 'Document';
      case RecordType.prescription:
        return 'Prescription';
      case RecordType.discharge:
        return 'Discharge Summary';
      case RecordType.other:
        return 'Other';
    }
  }
}