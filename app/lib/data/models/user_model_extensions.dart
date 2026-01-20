import 'package:ergo_life_app/data/models/user_model.dart';

/// Get the effective avatar URL for a user.
/// Returns avatarUrl if available, otherwise generates URL from avatarId.
String? getUserAvatarUrl(UserModel user) {
  // If avatarUrl is provided, use it
  if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
    return user.avatarUrl;
  }

  // Otherwise, generate from avatarId if available
  if (user.avatarId != null) {
    return getAvatarUrlFromId(user.avatarId!);
  }

  // No avatar available
  return null;
}

/// Generate avatar URL from avatarId using DiceBear API
/// This matches the logic in avatar_helpers.dart
String getAvatarUrlFromId(int id) {
  String style;
  int seed;

  if (id <= 10) {
    style = 'lorelei';
    seed = id;
  } else if (id <= 20) {
    style = 'fun-emoji';
    seed = id - 10;
  } else if (id <= 30) {
    style = 'adventurer';
    seed = id - 20;
  } else if (id <= 40) {
    style = 'notionists';
    seed = id - 30;
  } else if (id <= 50) {
    style = 'big-smile';
    seed = id - 40;
  } else {
    style = 'avataaars';
    seed = id - 50;
  }

  return 'https://api.dicebear.com/7.x/$style/png?seed=avatar$seed';
}
