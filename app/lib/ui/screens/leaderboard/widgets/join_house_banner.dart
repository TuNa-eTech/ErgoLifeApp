import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';

class JoinHouseBanner extends StatelessWidget {
  const JoinHouseBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.groups_rounded,
                  size: 32,
                  color: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join a House',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                      Text(
                        'Compete together!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onTertiaryContainer.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push(AppRouter.joinHouse),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text('Join House'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.onTertiaryContainer,
                      foregroundColor: colorScheme.tertiaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRouter.inviteMembers),
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Invite My House'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onTertiaryContainer,
                      side: BorderSide(
                        color: colorScheme.onTertiaryContainer.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
