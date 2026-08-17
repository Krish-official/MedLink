import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/buttons/destructive_button.dart';
import '../../../auth/presentation/widgets/providers.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          children: [
            // Profile Header
            Card(
              elevation: AppTokens.elevationSm,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        user?.firstName[0] ?? 'P',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space16),
                    Text(
                      user?.fullName ?? 'Patient',
                      style: AppTypography.h4,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      user?.email ?? '',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            // Personal Information
            _SectionHeader(title: 'Personal Information'),
            const SizedBox(height: AppTokens.space12),
            _InfoCard(
              items: [
                _InfoItem(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: user?.phone ?? 'Not provided',
                ),
                _InfoItem(
                  icon: Icons.cake_outlined,
                  label: 'Date of Birth',
                  value: user?.dateOfBirth != null
                      ? DateFormat('MMM dd, yyyy').format(user!.dateOfBirth!)
                      : 'Not provided',
                ),
                _InfoItem(
                  icon: Icons.wc_outlined,
                  label: 'Gender',
                  value: user?.gender ?? 'Not provided',
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space24),

            // Settings
            _SectionHeader(title: 'Settings'),
            const SizedBox(height: AppTokens.space12),
            _SettingsCard(
              items: [
                _SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {
                    // Navigate to notification settings
                  },
                ),
                _SettingsItem(
                  icon: Icons.lock_outlined,
                  title: 'Change Password',
                  onTap: () {
                    // Navigate to change password
                  },
                ),
                _SettingsItem(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    // Navigate to language selection
                  },
                ),
                _SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    // Open privacy policy
                  },
                ),
                _SettingsItem(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {
                    // Open terms
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space24),

            // App Info
            _SectionHeader(title: 'App Information'),
            const SizedBox(height: AppTokens.space12),
            Card(
              elevation: AppTokens.elevationSm,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Version', style: AppTypography.bodyMedium),
                        Text(
                          '1.0.0',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space32),

            // Logout Button
            DestructiveButton(
              label: 'Logout',
              icon: Icons.logout,
              fullWidth: true,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authStateProvider.notifier).logout();
                }
              },
            ),
            const SizedBox(height: AppTokens.space48),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: AppTypography.h6),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1)
                const Divider(height: AppTokens.space24),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
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
              Text(value, style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTypography.bodyMedium),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}