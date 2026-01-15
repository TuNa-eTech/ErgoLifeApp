# Language Selector Bottom Sheet

Reusable common widget for language selection across the ErgoLife app.

## Overview

The `LanguageSelectorBottomSheet` provides a clean, Material Design 3 styled bottom sheet for users to select their preferred language.

## Features

- ✅ **Reusable**: Can be used anywhere in the app
- ✅ **Material Design 3**: Modern, clean design
- ✅ **Dark Mode**: Full support for light and dark themes
- ✅ **Animated**: Smooth transitions and interactions
- ✅ **Accessible**: Clear selected state indicators
- ✅ **Localized**: Native language names with flags

## Usage

### Basic Usage

```dart
import 'package:ergo_life_app/ui/common/common.dart';

// Show the language selector
LanguageSelectorBottomSheet.show(context);
```

### With Callback

```dart
final changed = await LanguageSelectorBottomSheet.show(context);
if (changed == true) {
  // Language was changed
  print('User selected a new language');
}
```

### In a Widget

```dart
ElevatedButton(
  onPressed: () => LanguageSelectorBottomSheet.show(context),
  child: Text('Change Language'),
)
```

## Supported Languages

Currently supports:
- 🇬🇧 English (en)
- 🇻🇳 Vietnamese (vi)

## File Structure

```
lib/ui/common/
├── language_selector_bottom_sheet.dart  # Main widget
└── common.dart                          # Barrel export file
```

## Design Specifications

### Layout
- **Drag Handle**: 40×4px rounded indicator
- **Header**: Icon + "Select Language" title
- **Options**: Flag emoji + Native name + English name + Selection indicator
- **Selected Border**: 4px left border in primary color
- **Selected Background**: Primary color at 15% (dark) or 8% (light) opacity

### Typography
- **Header**: 20px, weight 700
- **Native Name**: 16px, weight 600
- **English Name**: 13px, weight 500

### Colors
- **Selected Indicator**: Primary color circle with white checkmark
- **Unselected Indicator**: Border circle
- **Background**: Surface color (dark/light adaptive)

## Integration with LocaleCubit

The bottom sheet automatically integrates with `LocaleCubit`:

```dart
context.read<LocaleCubit>().setLocale(const Locale('en'));
```

## Adding New Languages

To add a new language:

1. Add a new `_LanguageOption` in `language_selector_bottom_sheet.dart`:

```dart
_LanguageOption(
  languageCode: 'fr',
  languageName: 'French',
  languageNativeName: 'Français',
  flag: '🇫🇷',
  isSelected: currentLocale == 'fr',
  isDark: isDark,
  onTap: () {
    context.read<LocaleCubit>().setLocale(const Locale('fr'));
    Navigator.of(context).pop(true);
  },
),
```

2. Add corresponding translations in l10n files

## Testing

```dart
testWidgets('Language selector shows available languages', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Show the bottom sheet
  await tester.tap(find.byIcon(Icons.language_rounded));
  await tester.pumpAndSettle();
  
  // Verify languages are shown
  expect(find.text('English'), findsOneWidget);
  expect(find.text('Tiếng Việt'), findsOneWidget);
  
  // Select Vietnamese
  await tester.tap(find.text('Tiếng Việt'));
  await tester.pumpAndSettle();
  
  // Verify locale changed
  expect(Localizations.localeOf(context).languageCode, 'vi');
});
```

## Accessibility

- Clear visual indicators for selected language
- Touch targets meet minimum 48×48px requirement
- Proper contrast ratios for text
- Screen reader friendly with semantic labels
