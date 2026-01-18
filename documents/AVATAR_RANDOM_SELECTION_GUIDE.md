# Avatar Random Selection - Implementation Guide

## 📋 **OVERVIEW**

Thay đổi onboarding screen để sử dụng 60 DiceBear avatars thay vì 3 emojis cố định:
- Avatar được chọn ngẫu nhiên khi bắt đầu
- User có thể scroll và chọn avatar khác
- Sử dụng cùng DiceBear API như edit profile screen

---

## 🎯 **CHANGES NEEDED**

### 1. Update State Variables

**File:** `app/lib/ui/screens/onboarding/onboarding_screen.dart`

**Replace (lines 25-36):**
```dart
  // --- Page 1 State (Avatar + Name) ---
  final PageController _avatarController = PageController(
    initialPage: 1,
    viewportFraction: 0.45,
  );
  int _currentAvatarIndex = 1;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isNameValid = false;

  // Local avatar assets (replacing Google URLs)
  final List<String> _avatarEmojis = ['🧑‍💼', '👨‍🚀', '\u

ud83d\udc69\u200d\ud83c\udfa8'];
```

**With:**
```dart
  // --- Page 1 State (Avatar + Name) ---
  late int _selectedAvatarId; // Random initial avatar (1-60)
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isNameValid = false;

  // DiceBear avatar configuration
  static const int totalAvatars = 60; // 6 styles × 10 variations
  
  /// Get avatar URL from avatar ID using DiceBear API
  static String getAvatarUrl(int avatarId) {
    String style;
    int seed;

    if (avatarId <= 10) {
      style = 'lorelei';
      seed = avatarId;
    } else if (avatarId <= 20) {
      style = 'fun-emoji';
      seed = avatarId - 10;
    } else if (avatarId <= 30) {
      style = 'adventurer';
      seed = avatarId - 20;
    } else if (avatarId <= 40) {
      style = 'notionists';
      seed = avatarId - 30;
    } else if (avatarId <= 50) {
      style = 'big-smile';
      seed = avatarId - 40;
    } else {
      style = 'avataaars';
      seed = avatarId - 50;
    }

    return 'https://api.dicebear.com/7.x/$style/png?seed=avatar$seed';
  }
```

---

### 2. Initialize Random Avatar

**In `initState()` method (around line 48):**

Add after `_onboardingBloc = widget.onboardingBloc;`:
```dart
    // Randomly select initial avatar (1-60)
    _selectedAvatarId = DateTime.now().millisecondsSinceEpoch % totalAvatars + 1;
```

---

###  3. Remove Avatar Controller

**In `dispose()` method:**

Remove this line:
```dart
    _avatarController.dispose();
```

---

### 4. Update Profile Event

**In `_nextPage()` method:**

Change:
```dart
        avatarId: _currentAvatarIndex + 1,
```

To:
```dart
        avatarId: _selectedAvatarId,
```

---

### 5. Rebuild Avatar Page UI

**Replace entire `_buildAvatarPage()` method with:**

```dart
  Widget _buildAvatarPage(bool isDark, Color textColor) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Choose your avatar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scroll to browse $totalAvatars unique avatars',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Avatar Grid - 4 columns, scrollable
          Container(
            height: 280,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: totalAvatars,
              itemBuilder: (context, index) {
                final avatarId = index + 1;
                final isSelected = avatarId == _selectedAvatarId;
                return _buildAvatarItem(
                  avatarId: avatarId,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _selectedAvatarId = avatarId;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height:  24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'What should we call you?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C1F18) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 14),
                          child: Icon(
                            Icons.badge_outlined,
                            color: _nameFocusNode.hasFocus
                                ? AppColors.secondary
                                : const Color(0xFF98A2B3),
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isNameValid ? 1.0 : 0.0,
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        hintText: 'Enter your name...',
                        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Skip Avatar Button
                TextButton.icon(
                  onPressed: _skipAvatar,
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                  label: Text(
                    'Skip avatar selection',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
```

---

### 6. Add Avatar Item Builder Method

**Add this method after `_buildAvatarPage()`:**

```dart
  /// Build individual avatar item with network image
  Widget _buildAvatarItem({
    required int avatarId,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                getAvatarUrl(avatarId),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      size: 24,
                      color: isDark ? Colors.white54 : Colors.grey.shade400,
                    ),
                  );
                },
              ),
              if (isSelected)
                Container(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
```

---

## ✅ **VERIFICATION**

After making changes:

1. **Run dart format:**
   ```bash
   cd app
   dart format lib/ui/screens/onboarding/onboarding_screen.dart
   ```

2. **Run dart analyze:**
   ```bash
   dart analyze
   ```

3. **Test the app:**
   - Launch onboarding
   - Verify random avatar is selected
   - Scroll through grid
   - Select different avatars
   - Verify selection persists

---

## 🎨 **UI CHANGES**

**Before:**
- 3 emoji avatars in carousel
- Swipe left/right to change
- Large avatar display

**After:**
- 60 DiceBear avatars in 4-column grid
- Scroll vertically to browse
- Smaller avatar thumbnails
- Random initial selection
- Same interaction (tap to select)

---

## 📊 **KEY DIFFERENCES FROM EDIT PROFILE**

| Feature | Edit Profile | Onboarding |
|---------|-------------|-----------|
| **Avatar Count** | 60 (in bottom sheet) | 60 (in main view) |
| **Layout** | Bottom sheet modal | Inline grid |
| **Columns** | 5 columns | 4 columns |
| **Height** | 70% screen | 280px fixed |
| **API** | Same DiceBear | Same DiceBear |
| **Selection** | Updates existing | Sets initial |

---

## 🔧 **TROUBLESHOOTING**

### Images not loading?
- Check network connection
- Verify DiceBear API is accessible
- Check error builder is showing fallback icon

### Random selection not working?
- Verify `_selectedAvatarId` is initialized in `initState()`
- Check modulo calculation: `% totalAvatars + 1`
- Should be 1-60, not 0-59

### Grid not scrolling?
- Height constraint may be too small (increase from 280px)
- Verify `GridView.builder` is inside scrollable container

---

## 📝 **NEXT STEPS**

After implementing:
1. Test on different screen sizes
2. Consider adding categories (like edit profile)
3. Maybe add search/filter
4. Cache network images for performance

---

**Implementation Status:** ⏸️ PAUSED (Due to file corruption issues)
**Recommendation:** Implement manually following this guide
**Estimated Time:** 10-15 minutes

Happy coding! 🚀
