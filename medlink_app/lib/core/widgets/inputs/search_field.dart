import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

class SearchField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSubmitted;
  final bool autofocus;

  const SearchField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller?.text.isNotEmpty ?? false;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted?.call(),
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText ?? 'Search...',
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textDisabled,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: AppTokens.iconSm,
        ),
        suffixIcon: hasText
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: AppTokens.iconSm,
                ),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                  onChanged?.call('');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}