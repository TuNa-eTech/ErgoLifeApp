import 'package:flutter/material.dart';
import 'package:ergo_life_app/ui/widgets/modern_dialog.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

/// Dialog for entering a join code - Using ModernDialog
class JoinCodeDialog extends StatefulWidget {
  final TextEditingController nameController;
  final int selectedAvatarId;
  final Function(String displayName, int avatarId, String code) onJoin;

  const JoinCodeDialog({
    super.key,
    required this.nameController,
    required this.selectedAvatarId,
    required this.onJoin,
  });

  @override
  State<JoinCodeDialog> createState() => _JoinCodeDialogState();
}

class _JoinCodeDialogState extends State<JoinCodeDialog> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleJoin(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.isNotEmpty) {
      Navigator.pop(context);
      widget.onJoin(
        widget.nameController.text.trim(),
        widget.selectedAvatarId,
        code,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernDialog(
      type: DialogType.info,
      title: AppLocalizations.of(context)!.joinHouseAction,
      message: AppLocalizations.of(context)!.enterJoinCodeMessage,
      customIcon: const Icon(
        Icons.home_outlined,
        size: 24,
        color: Color(0xFF0D59F2),
      ),
      customContent: TextField(
        controller: _codeController,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        maxLength: 6,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.inviteCodeLabel,
          hintText: 'ABC123',
          counterText: '',
        ),
        onSubmitted: (_) => _handleJoin(context),
      ),
      primaryButtonText: AppLocalizations.of(context)!.joinBtn,
      secondaryButtonText: AppLocalizations.of(context)!.cancel,
      onPrimaryPressed: () => _handleJoin(context),
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }
}
