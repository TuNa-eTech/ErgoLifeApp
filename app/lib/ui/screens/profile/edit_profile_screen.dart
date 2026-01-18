import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ergo_life_app/blocs/profile/profile_bloc.dart';
import 'package:ergo_life_app/blocs/profile/profile_event.dart';
import 'package:ergo_life_app/blocs/profile/profile_state.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';
import 'package:ergo_life_app/ui/screens/profile/widgets/avatar_selector.dart';
import 'package:ergo_life_app/ui/widgets/modern_dialog.dart';

/// Edit Profile Screen
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  int? _selectedAvatarId;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    // Load current user data
    final state = context.read<ProfileBloc>().state;

    if (state is ProfileInitial) {
      // Need to load profile first
      context.read<ProfileBloc>().add(const LoadProfile());
    } else if (state is ProfileLoaded) {
      _nameController.text = state.user.name ?? '';
      _selectedAvatarId = state.user.avatarId;
    }

    _nameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      final hasNameChanged =
          _nameController.text.trim() != (state.user.name ?? '');
      final hasAvatarChanged = _selectedAvatarId != state.user.avatarId;

      setState(() {
        _hasChanges = hasNameChanged || hasAvatarChanged;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final state = context.read<ProfileBloc>().state;
    if (state is! ProfileLoaded) return;

    final name = _nameController.text.trim();

    // Validation
    if (name.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context)!.displayNameEmptyError);
      return;
    }

    if (name.length < 2) {
      _showErrorDialog(AppLocalizations.of(context)!.displayNameMinLengthError);
      return;
    }

    if (name.length > 30) {
      _showErrorDialog(AppLocalizations.of(context)!.displayNameMaxLengthError);
      return;
    }

    // Update profile
    setState(() {
      _isSaving = true;
    });

    context.read<ProfileBloc>().add(
      UpdateProfile(
        displayName: name != state.user.name ? name : null,
        avatarId: _selectedAvatarId != state.user.avatarId
            ? _selectedAvatarId
            : null,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => ModernDialog(
        type: DialogType.error,
        title: AppLocalizations.of(context)!.validationErrorTitle,
        message: message,
        primaryButtonText: AppLocalizations.of(context)!.ok,
        onPrimaryPressed: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showAvatarSelector() {
    final state = context.read<ProfileBloc>().state;
    if (state is! ProfileLoaded) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => AvatarSelector(
        currentAvatarId: _selectedAvatarId,
        onAvatarSelected: (avatarId) {
          setState(() {
            _selectedAvatarId = avatarId;
            _onFieldChanged();
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // Populate data when profile loads for the first time
        if (state is ProfileLoaded &&
            _nameController.text.isEmpty &&
            _selectedAvatarId == null) {
          setState(() {
            _nameController.text = state.user.name ?? '';
            _selectedAvatarId = state.user.avatarId;
          });
        }

        if (state is ProfileLoaded && _isSaving) {
          // Profile updated successfully - just go back
          setState(() {
            _isSaving = false;
            _hasChanges = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.profileUpdatedSuccessfully,
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          // Pop back to ProfileScreen - it will reload automatically
          context.pop();
        }

        if (state is ProfileError) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileUpdating;
        final isInitialLoading =
            state is ProfileLoading || state is ProfileInitial;

        // Show loading while fetching profile
        if (isInitialLoading) {
          return Scaffold(
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.editProfile,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              elevation: 0,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.editProfile,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: isLoading ? null : () => context.pop(),
            ),
            actions: [
              TextButton(
                onPressed: isLoading || !_hasChanges ? null : _saveProfile,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(
                          color: _hasChanges
                              ? AppColors.secondary
                              : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildAvatarSection(state, isDark, isLoading),
                  const SizedBox(height: 40),
                  _buildNameField(state, isDark, isLoading),
                  const SizedBox(height: 20),
                  _buildEmailField(state, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(ProfileState state, bool isDark, bool isLoading) {
    // Generate avatar URL from selected avatar ID using AvatarSelector utility
    String? avatarUrl;
    if (_selectedAvatarId != null) {
      avatarUrl = AvatarSelector.getAvatarUrl(_selectedAvatarId!);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : _showAvatarSelector,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 3),
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                child: avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: isDark ? Colors.white54 : Colors.grey.shade400,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: isLoading ? null : _showAvatarSelector,
          icon: const Icon(Icons.edit, size: 16),
          label: Text(AppLocalizations.of(context)!.changeAvatar),
          style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
        ),
      ],
    );
  }

  Widget _buildNameField(ProfileState state, bool isDark, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.displayName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enterDisplayNameHint,
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.displayNameMaxLengthError,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(ProfileState state, bool isDark) {
    final email = state is ProfileLoaded ? state.user.email : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.emailLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  email ?? AppLocalizations.of(context)!.noEmail,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline,
                size: 16,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.emailCannotBeChanged,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
      ],
    );
  }
}
