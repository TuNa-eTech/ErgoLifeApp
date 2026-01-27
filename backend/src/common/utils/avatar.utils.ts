/**
 * Utility functions for avatar management
 */

/**
 * Generate avatar URL from avatar ID with multiple DiceBear styles
 * - avatarId 1-10: lorelei (cute illustrated girls)
 * - avatarId 11-20: fun-emoji (colorful emoji style)
 * - avatarId 21-30: adventurer (playful characters)
 * - avatarId 31-40: notionists (notion-style avatars)
 * - avatarId 41-50: big-smile (happy faces)
 * - avatarId 51-60: avataaars (classic cartoon style)
 *
 * @param avatarId - Avatar ID (1-60)
 * @returns Avatar URL
 */
export function getAvatarUrl(avatarId: number | null): string | null {
  if (avatarId === null || avatarId === undefined) {
    return null;
  }

  // Determine style based on avatarId range
  let style: string;
  let seed: number;

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

  return `https://api.dicebear.com/7.x/${style}/png?seed=avatar${seed}`;
}
