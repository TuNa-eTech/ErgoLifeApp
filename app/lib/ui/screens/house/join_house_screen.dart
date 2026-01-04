import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/house/house_bloc.dart';
import 'package:ergo_life_app/blocs/house/house_event.dart';
import 'package:ergo_life_app/blocs/house/house_state.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

/// Screen for joining a house with invite code
class JoinHouseScreen extends StatefulWidget {
  final HouseBloc houseBloc;

  const JoinHouseScreen({super.key, required this.houseBloc});

  @override
  State<JoinHouseScreen> createState() => _JoinHouseScreenState();
}

class _JoinHouseScreenState extends State<JoinHouseScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HouseBloc>.value(
      value: widget.houseBloc,
      child: BlocConsumer<HouseBloc, HouseState>(
        listener: (context, state) {
          if (state is HouseLoaded) {
            // Successfully joined house
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Joined ${state.house.name}!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate to home
            context.go(AppRouter.home);
          } else if (state is HouseError) {
            // Show error
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
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final isLoading = state is HouseProcessing;

          return Scaffold(
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                AppLocalizations.of(context)!.joinHouse,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Icon
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.secondary, Color(0xFFEE0979)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_outlined,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    AppLocalizations.of(context)!.enterInviteCode,
                    textAlign: TextAlign.center,
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
                    AppLocalizations.of(context)!.askYourFriendForCode,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSubDark
                          : AppColors.textSubLight,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Code Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _codeController,
                      focusNode: _codeFocusNode,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                      ),
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: '000000',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 24,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Join Button
                  ElevatedButton(
                    onPressed: isLoading || _codeController.text.length != 6
                        ? null
                        : () => _joinHouse(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.joinHouse,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.goodToKnow,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• You can only be in one house at a time\n'
                          '• Maximum 4 members per house\n'
                          '• Compete with housemates on the leaderboard!',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSubDark
                                : AppColors.textSubLight,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _joinHouse(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.length == 6) {
      context.read<HouseBloc>().add(JoinHouse(inviteCode: code));
    }
  }
}
