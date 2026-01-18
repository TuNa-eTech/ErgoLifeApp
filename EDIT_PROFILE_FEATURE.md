# Edit Profile Feature

## Overview
The Edit Profile feature allows users to update their display name and choose from 20 pre-defined avatars. This provides a personalized experience across the app.

## Components

### Flutter App

#### 1. **EditProfileScreen** (`lib/ui/screens/profile/edit_profile_screen.dart`)
- Main screen for editing user profile
- Features:
  - Display name text field with validation (2-30 characters)
  - Avatar selector button
  - Email field (read-only, locked)
  - Save button (enabled only when changes are made)
  - Loading states during profile update
  
#### 2. **AvatarSelector** (`lib/ui/screens/profile/widgets/avatar_selector.dart`)
- Bottom sheet displaying 20 avatar options in a 4-column grid
- Features:
  - Visual feedback for selected avatar
  - Network image loading with error handling
  - Smooth selection animation

#### 3. **Profile Integration**
- Updated `ProfileScreen` to navigate to Edit Profile when tapping "Edit Profile" button
- Added route `/profile/edit` in `AppRouter`

### Backend

#### 1. **Avatar URL Generation** (`backend/src/common/utils/avatar.utils.ts`)
- Helper function `getAvatarUrl(avatarId)` generates consistent avatar URLs
- Uses DiceBear API: `https://api.dicebear.com/7.x/avataaars/png?seed=avatar{id}`

#### 2. **Updated DTOs**
- `UserDto` (auth module) - Added `avatarUrl` field
- `UserProfileDto` (user module) - Added `avatarUrl` field  
- `OtherUserDto` (user module) - Added `avatarUrl` field

#### 3. **Updated Services**
- `AuthService.mapUserToDto()` - Populates `avatarUrl` using `getAvatarUrl()`
- `UserService.updateProfile()` - Returns updated user with `avatarUrl`
- `UserService.getUserById()` - Returns user with `avatarUrl`

## API

### Update Profile
```
PUT /users/me
Content-Type: application/json
Authorization: Bearer {token}

{
  "displayName": "New Name",  // optional, 2-30 characters
  "avatarId": 5               // optional, 1-20
}
```

**Response:**
```json
{
  "id": "uuid",
  "displayName": "New Name",
  "avatarId": 5,
  "avatarUrl": "https://api.dicebear.com/7.x/avataaars/png?seed=avatar5",
  "email": "user@example.com",
  "walletBalance": 1500,
  "houseId": "uuid"
}
```

## User Flow

1. User taps "Edit Profile" in Profile Screen
2. Edit Profile Screen opens as fullscreen dialog
3. User can:
   - Edit display name
   - Tap avatar to open Avatar Selector
   - Choose from 20 avatars
4. Save button becomes enabled when changes are made
5. User taps Save
6. Profile updates via `ProfileBloc`
7. Success message shown
8. User returns to Profile Screen
9. Updated avatar and name displayed

## Validation

### Display Name
- **Required**: Cannot be empty
- **Min length**: 2 characters
- **Max length**: 30 characters
- **Trimmed**: Leading/trailing whitespace removed

### Avatar ID
- **Range**: 1-20 (validated in backend DTO)

## Error Handling

- Network errors show SnackBar
- Validation errors show ModernDialog
- Loading states prevent multiple submissions
- Failed updates restore previous state

## Future Enhancements

1. **Avatar Upload**: Allow users to upload custom avatars
2. **Bio/Description**: Add profile description field
3. **Social Links**: Connect social media accounts
4. **Profile Visibility**: Privacy toggle for profile visibility
5. **Username**: Add unique username field (in addition to display name)

## Troubleshooting

### Issue: Save button disabled / Avatar selector not showing

**Cause**: ProfileBloc state was `ProfileInitial` when EditProfileScreen opened

**Solution**: 
- Auto-load profile in `initState` if state is `ProfileInitial`
- Show loading indicator while fetching
- Populate fields when `ProfileLoaded` is received

**Implementation**:
```dart
// In initState
if (state is ProfileInitial) {
  context.read<ProfileBloc>().add(const LoadProfile());
}

// In listener
if (state is ProfileLoaded && _nameController.text.isEmpty) {
  setState(() {
    _nameController.text = state.user.name ?? '';
    _selectedAvatarId = state.user.avatarId;
  });
}

// In builder
if (state is ProfileLoading || state is ProfileInitial) {
  return Scaffold(body: Center(child: CircularProgressIndicator()));
}
```

## Implementation Notes

- ✅ Feature fully implemented and tested
- ✅ Backend API supports displayName (2-30 chars) and avatarId (1-20)
- ✅ Avatar URLs generated server-side using DiceBear API
- ✅ Profile auto-loads when EditProfileScreen opens
- ✅ Loading states handled gracefully
- ✅ Form validation with user-friendly error messages
- ✅ Optimistic UI updates (avatar preview on selection)
- ✅ Clean separation of concerns (BLoC pattern)

