import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/house_model.dart';

/// Bottom sheet for inviting friends to your house
class InviteHouseBottomSheet extends StatefulWidget {
  const InviteHouseBottomSheet({
    required this.houseName,
    this.isDefaultName = false,
    this.onGetInvite,
    this.onRenameHouse,
    super.key,
  });

  final String houseName;
  final bool isDefaultName;
  final Future<HouseInvite?> Function()? onGetInvite;
  final Future<bool> Function(String newName)? onRenameHouse;

  @override
  State<InviteHouseBottomSheet> createState() => _InviteHouseBottomSheetState();

  /// Show the bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String houseName,
    bool isDefaultName = false,
    Future<HouseInvite?> Function()? onGetInvite,
    Future<bool> Function(String newName)? onRenameHouse,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InviteHouseBottomSheet(
        houseName: houseName,
        isDefaultName: isDefaultName,
        onGetInvite: onGetInvite,
        onRenameHouse: onRenameHouse,
      ),
    );
  }
}

class _InviteHouseBottomSheetState extends State<InviteHouseBottomSheet> {
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _showNameInput = false;
  HouseInvite? _invite;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.houseName;
    _showNameInput = widget.isDefaultName;

    if (!widget.isDefaultName) {
      _loadInvite();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadInvite() async {
    setState(() => _isLoading = true);

    try {
      final invite = await widget.onGetInvite?.call();
      setState(() {
        _invite = invite;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load invite code';
      });
    }
  }

  Future<void> _onSaveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      setState(() => _error = 'Please enter a house name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await widget.onRenameHouse?.call(newName);
      if (success == true) {
        setState(() => _showNameInput = false);
        await _loadInvite();
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Failed to update name';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to update name';
      });
    }
  }

  void _copyCode() {
    if (_invite == null) return;

    Clipboard.setData(ClipboardData(text: _invite!.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite code copied! 📋'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareInvite() {
    if (_invite == null) return;

    SharePlus.instance.share(
      ShareParams(
        text:
            'Join my ErgoLife house! Use code: ${_invite!.inviteCode}\n\n${_invite!.inviteLink}',
        subject: 'Join my ErgoLife house!',
      ),
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
          maxHeight: MediaQuery.of(context).size.height * 0.7,
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
                child: _showNameInput
                    ? _buildNameInputView(isDark)
                    : _buildInviteView(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameInputView(bool isDark) {
    return Column(
      children: [
        // Icon
        const Text('✏️', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),

        // Title
        Text(
          'Name Your Arena',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Give your house a cool name before inviting friends!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
        const SizedBox(height: 24),

        // Name input
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _error != null ? Colors.red : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., "The Warriors" 💪',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ],

        const SizedBox(height: 24),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onSaveName,
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
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteView(bool isDark) {
    return Column(
      children: [
        // Icon
        const Text('🎉', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),

        // Title
        Text(
          'Invite Friends',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share this code with friends to join "${_nameController.text}"',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
        const SizedBox(height: 32),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_invite != null) ...[
          // Invite code display
          GestureDetector(
            onTap: _copyCode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withAlpha(50),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _invite!.inviteCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.copy,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to copy',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Share button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _shareInvite,
              icon: const Icon(Icons.share),
              label: const Text(
                'Share Invite Link',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ] else if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
      ],
    );
  }
}
