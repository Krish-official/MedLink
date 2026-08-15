import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    
    // Set custom error handler
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() => _error = details);
      }
      widget.onError?.call(details);
      
      // Log to crash reporting service in production
      if (kReleaseMode) {
        // TODO: Send to Firebase Crashlytics or Sentry
        debugPrint('Error: ${details.exception}');
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorScreen(
        error: _error!,
        onRetry: () {
          setState(() => _error = null);
        },
      );
    }

    return widget.child;
  }
}

class _ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: AppTokens.space24),
              Text(
                'Something went wrong',
                style: AppTypography.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space8),
              Text(
                'We\'re sorry for the inconvenience. Please try again.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: AppTokens.space24),
                Container(
                  padding: const EdgeInsets.all(AppTokens.space16),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Text(
                    error.exception.toString(),
                    style: AppTypography.bodySmall.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.errorDark,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppTokens.space32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}