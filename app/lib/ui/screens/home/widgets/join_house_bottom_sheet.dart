import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/house_model.dart';
import 'package:ergo_life_app/ui/widgets/modern_dialog.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

/// Bottom sheet for joining a house with invite code
class JoinHouseBottomSheet extends StatefulWidget {
  const JoinHouseBottomSheet({this.onPreview, this.onJoin, super.key});

  final Future<HousePreview?> Function(String code)? onPreview;
  final Future<bool> Function(String code)? onJoin;

  @override
  State<JoinHouseBottomSheet> createState() => _JoinHouseBottomSheetState();

  /// Show the bottom sheet
  static Future<void> show(
    BuildContext context, {
    Future<HousePreview?> Function(String code)? onPreview,
    Future<bool> Function(String code)? onJoin,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          JoinHouseBottomSheet(onPreview: onPreview, onJoin: onJoin),
    );
  }
}

class _JoinHouseBottomSheetState extends State<JoinHouseBottomSheet> {
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();

  bool _isLoading = false;
  HousePreview? _preview;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onPreview() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = AppLocalizations.of(context)!.enterInviteCode);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final preview = await widget.onPreview?.call(code);
      setState(() {
        _preview = preview;
        _isLoading = false;
        if (preview == null) {
          _error = AppLocalizations.of(context)!.invalidInviteCode;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = AppLocalizations.of(context)!.failedToLoadHouseInfo;
      });
    }
  }

  Future<void> _onJoin() async {
    final confirmed = await _showLeaveConfirmDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final success = await widget.onJoin?.call(_codeController.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
        if (success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.welcomeToHouse(_preview?.name ?? 'the house'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = AppLocalizations.of(context)!.failedToJoinHouse;
      });
    }
  }

  Future<bool> _showLeaveConfirmDialog() async {
    return await ModernDialog.showConfirmation(
      context,
      title: AppLocalizations.of(context)!.leavePersonalSpaceTitle,
      message: AppLocalizations.of(
        context,
      )!.leavePersonalSpaceMessage(_preview?.name ?? 'this house'),
      confirmText: AppLocalizations.of(context)!.joinHouseAction,
      cancelText: AppLocalizations.of(context)!.cancel,
      isDestructive: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    // Icon
                    const Text('🏠', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      AppLocalizations.of(context)!.joinAHouse,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.enterInviteCodeDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textSubDark
                            : AppColors.textSubLight,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Code input
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(13)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _error != null
                              ? Colors.red
                              : (_codeFocusNode.hasFocus
                                    ? AppColors.secondary
                                    : Colors.transparent),
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _codeController,
                        focusNode: _codeFocusNode,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ABCD1234',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            letterSpacing: 4,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                          if (_preview != null) setState(() => _preview = null);
                        },
                      ),
                    ),

                    // Error message
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Preview or Preview button
                    if (_preview != null)
                      _buildPreviewCard(isDark)
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onPreview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.surfaceDark
                                : Colors.grey.shade100,
                            foregroundColor: isDark
                                ? AppColors.textMainDark
                                : AppColors.textMainLight,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.previewHouse,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                    // Join button (only if preview loaded)
                    if (_preview != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onJoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.joinHouseAction,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withAlpha(50)),
      ),
      child: Column(
        children: [
          // House icon + name
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _preview!.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                      ),
                    ),
                    if (_preview!.ownerName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.createdBy(_preview!.ownerName ?? ''),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSubDark
                              : AppColors.textSubLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Member count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.memberCount(_preview!.memberCount),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
