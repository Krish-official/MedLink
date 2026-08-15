import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import 'providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authRepositoryProvider)
          .forgotPassword(_emailController.text.trim());

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _emailSent ? _buildSuccessView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.lock_reset,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppTokens.space24),
          Text(
            'Reset Your Password',
            style: AppTypography.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.space8),
          Text(
            'Enter your email address and we\'ll send you instructions to reset your password.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.space32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'your.email@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: AppTokens.space24),
          PrimaryButton(
            label: 'Send Reset Link',
            onPressed: _isLoading ? null : _handleSubmit,
            isLoading: _isLoading,
            fullWidth: true,
          ),
          const SizedBox(height: AppTokens.space16),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: AppColors.success,
        ),
        const SizedBox(height: AppTokens.space24),
        Text(
          'Check Your Email',
          style: AppTypography.h3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTokens.space8),
        Text(
          'We\'ve sent password reset instructions to:',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTokens.space8),
        Text(
          _emailController.text,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTokens.space32),
        Container(
          padding: const EdgeInsets.all(AppTokens.space16),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  'Didn\'t receive the email? Check your spam folder or try again.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.infoDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space24),
        PrimaryButton(
          label: 'Back to Login',
          onPressed: () => context.pop(),
          fullWidth: true,
        ),
        const SizedBox(height: AppTokens.space12),
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: const Text('Resend Email'),
        ),
      ],
    );
  }
}