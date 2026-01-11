import 'package:flutter/material.dart';

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
        child: Row(
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
                      color: colorScheme.onTertiaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () {
                Navigator.pushNamed(context, '/house/join');
              },
              child: const Text('Find House'),
            ),
          ],
        ),
      ),
    );
  }
}
