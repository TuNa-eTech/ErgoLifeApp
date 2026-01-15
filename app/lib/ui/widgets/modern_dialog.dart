import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Modern dialog system with consistent design
/// Provides multiple dialog types with professional styling

enum DialogType { info, success, warning, error, confirmation }

class ModernDialog extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Widget? customIcon;
  final Widget? customContent;

  const ModernDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.customIcon,
    this.customContent,
  });

  /// Show info dialog
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    Widget? customContent,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ModernDialog(
        type: DialogType.info,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: () => Navigator.pop(ctx),
        customContent: customContent,
      ),
    );
  }

  /// Show success dialog
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Great!',
    Widget? customContent,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ModernDialog(
        type: DialogType.success,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: () => Navigator.pop(ctx),
        customContent: customContent,
      ),
    );
  }

  /// Show warning dialog
  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Understood',
    Widget? customContent,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ModernDialog(
        type: DialogType.warning,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: () => Navigator.pop(ctx),
        customContent: customContent,
      ),
    );
  }

  /// Show error dialog
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    Widget? customContent,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ModernDialog(
        type: DialogType.error,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: () => Navigator.pop(ctx),
        customContent: customContent,
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    Widget? customContent,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ModernDialog(
        type: isDestructive ? DialogType.warning : DialogType.confirmation,
        title: title,
        message: message,
        primaryButtonText: confirmText,
        secondaryButtonText: cancelText,
        onPrimaryPressed: () => Navigator.pop(ctx, true),
        onSecondaryPressed: () => Navigator.pop(ctx, false),
        customContent: customContent,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDark),
            _buildContent(isDark),
            _buildActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: _getHeaderColor().withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getHeaderColor().withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  customIcon ??
                  Icon(_getIcon(), color: _getHeaderColor(), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
          if (customContent != null) ...[
            const SizedBox(height: 16),
            customContent!,
          ],
        ],
      ),
    );
  }

  Widget _buildActions(bool isDark) {
    final hasSecondary = secondaryButtonText != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          if (hasSecondary) ...[
            Expanded(
              child: _buildButton(
                text: secondaryButtonText!,
                onPressed: onSecondaryPressed ?? () {},
                isPrimary: false,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: _buildButton(
              text: primaryButtonText ?? 'OK',
              onPressed: onPrimaryPressed ?? () {},
              isPrimary: true,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
    required bool isDark,
  }) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getHeaderColor(),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );
    } else {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? AppColors.textMainDark
              : AppColors.textMainLight,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );
    }
  }

  IconData _getIcon() {
    switch (type) {
      case DialogType.info:
        return Icons.info_outline;
      case DialogType.success:
        return Icons.check_circle_outline;
      case DialogType.warning:
        return Icons.warning_amber_outlined;
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.confirmation:
        return Icons.help_outline;
    }
  }

  Color _getHeaderColor() {
    switch (type) {
      case DialogType.info:
        return AppColors.primary;
      case DialogType.success:
        return Colors.green;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.error:
        return Colors.red;
      case DialogType.confirmation:
        return AppColors.primary;
    }
  }
}
