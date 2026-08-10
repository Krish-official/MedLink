import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../theme/colors.dart';
import 'buttons/primary_button.dart';
import 'buttons/secondary_button.dart';
// Import all other components

class KitchenSinkScreen extends StatelessWidget {
  const KitchenSinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Component Library')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: 'Buttons',
              children: [
                PrimaryButton(label: 'Primary Button', onPressed: () {}),
                const SizedBox(height: AppTokens.space12),
                SecondaryButton(label: 'Secondary Button', onPressed: () {}),
                const SizedBox(height: AppTokens.space12),
                PrimaryButton(
                  label: 'Loading',
                  isLoading: true,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space32),
            _Section(
              title: 'Typography',
              children: [
                const Text('Heading 1', style: AppTypography.h1),
                const Text('Heading 2', style: AppTypography.h2),
                const Text('Heading 3', style: AppTypography.h3),
                const Text('Body Large', style: AppTypography.bodyLarge),
                const Text('Body Medium', style: AppTypography.bodyMedium),
                const Text('Caption', style: AppTypography.caption),
              ],
            ),
            // Add sections for Cards, Badges, Inputs, States, etc.
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h4),
        const SizedBox(height: AppTokens.space16),
        ...children,
      ],
    );
  }
}