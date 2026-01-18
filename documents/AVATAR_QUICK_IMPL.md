# AVATAR FEATURE - QUICK IMPLEMENTATION

Bạn đã hoàn thành hầu hết! Chỉ còn những thay đổi sau đây cần áp dụng manually.

## ✅ COMPLETED SO FAR:
1. ✅ State variable changed  
2. ✅ `totalAvatars` constant added
3. ✅ Errors appear (normal, will fix after all changes)

## 📝 REMAINING CHANGES (Copy-Paste):

### 1. Add `getAvatarUrl` method

**Location:** After line 31 (`static const int totalAvatars = 60;`)

**Add this method:**

```dart
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
      style = '

adventurer';
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

### 2. Update `initState()`

**Find (around line 70):**
```dart
    super.initState();
    _onboardingBloc = widget.onboardingBloc;
    _nameController.addListener(() {
```

**Replace with:**
```dart
    super.initState();
    _onboardingBloc = widget.onboardingBloc;
    
    _selectedAvatarId = DateTime.now().millisecondsSinceEpoch % totalAvatars + 1;
    
    _nameController.addListener(() {
```

### 3. Update `dispose()`

**Find:**
```dart
    _avatarController.dispose();
```

**Delete that line** (keep the rest)

### 4. Update `_nextPage()` - avatarId parameter

**Find (around line 98 or line 123):**
```dart
          avatarId: _currentAvatarIndex + 1,
```

**Replace with:**
```dart
          avatarId: _selectedAvatarId,
```

### 5. Replace entire `_buildAvatarPage()` method

**Find the method starting around line 458-510**

**REPLACE THE ENTIRE METHOD with:**

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
                );
              },
            ),
          ),
          const SizedBox(height: 24),
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

### 6. Add `_buildAvatarItem()` method

**Add this method right after `_buildAvatarPage()`:**

```dart
  Widget _buildAvatarItem({
    required int avatarId,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatarId = avatarId;
        });
      },
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

## ✅ AFTER COMPLETING ALL CHANGES:

Run these commands:

```bash
cd app
dart format lib/ui/screens/onboarding/onboarding_screen.dart
dart analyze
```

## 🎯 SUMMARY:

Total changes:
1. State variables (✅ done)
2. `totalAvatars` constant (✅ done)
3. `getAvatarUrl()` method (❌ add manually)
4. Update `initState()` (❌ add manually)
5. Update `dispose()` (❌ remove one line)
6. Update avatarId params (❌ 1 line change) 
7.  Replace `_buildAvatarPage()` (❌ entire method)
8. Add `_buildAvatarItem()` (❌ new method)

**Time: ~5 minutes** ⏱️

Ready to go! 🚀
