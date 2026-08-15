import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SOS Alert Card
            Card(
              elevation: AppTokens.elevationMd,
              color: AppColors.errorLight,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space20),
                child: Column(
                  children: [
                    Icon(
                      Icons.emergency,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppTokens.space16),
                    Text(
                      'Emergency SOS',
                      style: AppTypography.h4.copyWith(color: AppColors.errorDark),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    Text(
                      'Tap the button below to send an SOS alert to your emergency contacts and nearby hospitals',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.errorDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTokens.space24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _showSOSConfirmation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 28),
                            const SizedBox(width: AppTokens.space12),
                            Text(
                              'SEND SOS ALERT',
                              style: AppTypography.h6.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            // Quick Call Section
            Text('Quick Call', style: AppTypography.h5),
            const SizedBox(height: AppTokens.space16),
            _QuickCallCard(
              icon: Icons.local_hospital_outlined,
              label: 'Ambulance',
              number: '108',
              color: AppColors.error,
              onCall: () => _makeCall('108'),
            ),
            const SizedBox(height: AppTokens.space12),
            _QuickCallCard(
              icon: Icons.medical_services_outlined,
              label: 'Nearest Hospital',
              number: '+91 1234567890',
              color: AppColors.primary,
              onCall: () => _makeCall('+911234567890'),
            ),
            const SizedBox(height: AppTokens.space12),
            _QuickCallCard(
              icon: Icons.local_police_outlined,
              label: 'Police',
              number: '100',
              color: AppColors.info,
              onCall: () => _makeCall('100'),
            ),
            const SizedBox(height: AppTokens.space24),

            // Emergency Contacts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Emergency Contacts', style: AppTypography.h5),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to add contact
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space16),

            // Mock contacts - replace with actual data
            _EmergencyContactCard(
              name: 'John Doe',
              relationship: 'Spouse',
              phone: '+91 9876543210',
              isPrimary: true,
              onCall: () => _makeCall('+919876543210'),
            ),
            const SizedBox(height: AppTokens.space12),
            _EmergencyContactCard(
              name: 'Jane Smith',
              relationship: 'Parent',
              phone: '+91 9876543211',
              onCall: () => _makeCall('+919876543211'),
            ),

            const SizedBox(height: AppTokens.space24),

            // Medical Info Card
            Text('Medical Information', style: AppTypography.h5),
            const SizedBox(height: AppTokens.space16),
            Card(
              elevation: AppTokens.elevationSm,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MedicalInfoRow(
                      label: 'Blood Group',
                      value: 'O+',
                      icon: Icons.bloodtype,
                    ),
                    const Divider(height: AppTokens.space24),
                    _MedicalInfoRow(
                      label: 'Allergies',
                      value: 'Penicillin, Peanuts',
                      icon: Icons.warning_amber_outlined,
                    ),
                    const Divider(height: AppTokens.space24),
                    _MedicalInfoRow(
                      label: 'Chronic Conditions',
                      value: 'Diabetes Type 2',
                      icon: Icons.medical_information_outlined,
                    ),
                    const SizedBox(height: AppTokens.space16),
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to edit medical info
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Update Medical Info'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSOSConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: AppTokens.space12),
            const Text('Send SOS Alert?'),
          ],
        ),
        content: const Text(
          'This will send your current location and medical information to:\n\n'
          '• Your emergency contacts\n'
          '• Nearest hospitals\n'
          '• Emergency services\n\n'
          'Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendSOSAlert(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSOSAlert(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(AppTokens.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppTokens.space16),
                Text('Sending SOS alert...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Simulate sending alert
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS alert sent successfully'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// QUICK CALL CARD
// ═══════════════════════════════════════════════════════════════

class _QuickCallCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  final Color color;
  final VoidCallback onCall;

  const _QuickCallCard({
    required this.icon,
    required this.label,
    required this.number,
    required this.color,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: InkWell(
        onTap: onCall,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space16),
          child: Row(
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
              const SizedBox(width: AppTokens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.h6),
                    Text(
                      number,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EMERGENCY CONTACT CARD
// ═══════════════════════════════════════════════════════════════

class _EmergencyContactCard extends StatelessWidget {
  final String name;
  final String relationship;
  final String phone;
  final bool isPrimary;
  final VoidCallback onCall;

  const _EmergencyContactCard({
    required this.name,
    required this.relationship,
    required this.phone,
    this.isPrimary = false,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                name[0],
                style: AppTypography.h6.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                      if (isPrimary) ...[
                        const SizedBox(width: AppTokens.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTokens.space6,
                            vertical: AppTokens.space2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppTokens.radiusXs),
                          ),
                          child: Text(
                            'PRIMARY',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    relationship,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    phone,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onCall,
              icon: const Icon(Icons.call, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MEDICAL INFO ROW
// ═══════════════════════════════════════════════════════════════

class _MedicalInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MedicalInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppTokens.iconSm, color: AppColors.primary),
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
              const SizedBox(height: AppTokens.space4),
              Text(value, style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
        ),
      ],
    );
  }
}