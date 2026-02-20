import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface BadgeSeed {
  code: string;
  category: string;
  icon: string;
  color: string;
  conditionType: string;
  conditionValue: number;
  rarity: string;
  sortOrder: number;
  translations: {
    vi: { name: string; description: string };
    en: { name: string; description: string };
  };
}

const badges: BadgeSeed[] = [
  // ── Streak badges ──
  {
    code: 'STREAK_3',
    category: 'streak',
    icon: 'local_fire_department',
    color: '#FF6A00',
    conditionType: 'streak',
    conditionValue: 3,
    rarity: 'COMMON',
    sortOrder: 1,
    translations: {
      vi: { name: 'Ngọn lửa nhỏ', description: 'Đạt chuỗi 3 ngày liên tiếp' },
      en: { name: 'Spark', description: 'Reach a 3-day streak' },
    },
  },
  {
    code: 'STREAK_7',
    category: 'streak',
    icon: 'whatshot',
    color: '#FF5722',
    conditionType: 'streak',
    conditionValue: 7,
    rarity: 'COMMON',
    sortOrder: 2,
    translations: {
      vi: { name: 'Tuần lửa', description: 'Đạt chuỗi 7 ngày liên tiếp' },
      en: { name: 'Week Warrior', description: 'Reach a 7-day streak' },
    },
  },
  {
    code: 'STREAK_14',
    category: 'streak',
    icon: 'whatshot',
    color: '#E64A19',
    conditionType: 'streak',
    conditionValue: 14,
    rarity: 'RARE',
    sortOrder: 3,
    translations: {
      vi: { name: 'Ngọn lửa bền', description: 'Đạt chuỗi 14 ngày liên tiếp' },
      en: { name: 'Fortnight Fire', description: 'Reach a 14-day streak' },
    },
  },
  {
    code: 'STREAK_30',
    category: 'streak',
    icon: 'bolt',
    color: '#BF360C',
    conditionType: 'streak',
    conditionValue: 30,
    rarity: 'EPIC',
    sortOrder: 4,
    translations: {
      vi: { name: 'Thói quen vàng', description: 'Đạt chuỗi 30 ngày liên tiếp' },
      en: { name: 'Monthly Master', description: 'Reach a 30-day streak' },
    },
  },
  {
    code: 'STREAK_100',
    category: 'streak',
    icon: 'diamond',
    color: '#FFD700',
    conditionType: 'streak',
    conditionValue: 100,
    rarity: 'LEGENDARY',
    sortOrder: 5,
    translations: {
      vi: { name: 'Huyền thoại', description: 'Đạt chuỗi 100 ngày liên tiếp' },
      en: { name: 'Centurion', description: 'Reach a 100-day streak' },
    },
  },

  // ── Total EP badges ──
  {
    code: 'EP_500',
    category: 'ep',
    icon: 'stars',
    color: '#4CAF50',
    conditionType: 'total_ep',
    conditionValue: 500,
    rarity: 'COMMON',
    sortOrder: 10,
    translations: {
      vi: { name: 'Khởi đầu EP', description: 'Tích lũy 500 EP' },
      en: { name: 'EP Starter', description: 'Earn 500 EP total' },
    },
  },
  {
    code: 'EP_2000',
    category: 'ep',
    icon: 'stars',
    color: '#388E3C',
    conditionType: 'total_ep',
    conditionValue: 2000,
    rarity: 'RARE',
    sortOrder: 11,
    translations: {
      vi: { name: 'Nhà sưu tập EP', description: 'Tích lũy 2,000 EP' },
      en: { name: 'EP Collector', description: 'Earn 2,000 EP total' },
    },
  },
  {
    code: 'EP_10000',
    category: 'ep',
    icon: 'auto_awesome',
    color: '#1B5E20',
    conditionType: 'total_ep',
    conditionValue: 10000,
    rarity: 'EPIC',
    sortOrder: 12,
    translations: {
      vi: { name: 'Vua EP', description: 'Tích lũy 10,000 EP' },
      en: { name: 'EP King', description: 'Earn 10,000 EP total' },
    },
  },

  // ── Activity count badges ──
  {
    code: 'ACTIVITIES_5',
    category: 'activity',
    icon: 'directions_run',
    color: '#2196F3',
    conditionType: 'total_activities',
    conditionValue: 5,
    rarity: 'COMMON',
    sortOrder: 20,
    translations: {
      vi: { name: 'Bước đầu', description: 'Hoàn thành 5 hoạt động' },
      en: { name: 'First Steps', description: 'Complete 5 activities' },
    },
  },
  {
    code: 'ACTIVITIES_25',
    category: 'activity',
    icon: 'fitness_center',
    color: '#1976D2',
    conditionType: 'total_activities',
    conditionValue: 25,
    rarity: 'RARE',
    sortOrder: 21,
    translations: {
      vi: { name: 'Người siêng năng', description: 'Hoàn thành 25 hoạt động' },
      en: { name: 'Dedicated', description: 'Complete 25 activities' },
    },
  },
  {
    code: 'ACTIVITIES_100',
    category: 'activity',
    icon: 'military_tech',
    color: '#0D47A1',
    conditionType: 'total_activities',
    conditionValue: 100,
    rarity: 'EPIC',
    sortOrder: 22,
    translations: {
      vi: { name: 'Chiến binh', description: 'Hoàn thành 100 hoạt động' },
      en: { name: 'Warrior', description: 'Complete 100 activities' },
    },
  },

  // ── Perfect day badges ──
  {
    code: 'PERFECT_3',
    category: 'special',
    icon: 'done_all',
    color: '#9C27B0',
    conditionType: 'perfect_days',
    conditionValue: 3,
    rarity: 'COMMON',
    sortOrder: 30,
    translations: {
      vi: { name: 'Hoàn hảo', description: 'Đạt 3 ngày hoàn hảo' },
      en: { name: 'Perfectionist', description: 'Achieve 3 perfect days' },
    },
  },
  {
    code: 'PERFECT_10',
    category: 'special',
    icon: 'verified',
    color: '#7B1FA2',
    conditionType: 'perfect_days',
    conditionValue: 10,
    rarity: 'RARE',
    sortOrder: 31,
    translations: {
      vi: { name: 'Kỷ luật thép', description: 'Đạt 10 ngày hoàn hảo' },
      en: { name: 'Iron Discipline', description: 'Achieve 10 perfect days' },
    },
  },

  // ── Single session EP badge ──
  {
    code: 'SESSION_EP_200',
    category: 'special',
    icon: 'flash_on',
    color: '#FF9800',
    conditionType: 'single_session_ep',
    conditionValue: 200,
    rarity: 'RARE',
    sortOrder: 40,
    translations: {
      vi: { name: 'Sức mạnh bùng nổ', description: 'Đạt 200 EP trong 1 phiên' },
      en: { name: 'Power Surge', description: 'Earn 200 EP in a single session' },
    },
  },
];

export async function seedBadges() {
  console.log('🏅 Seeding badge definitions...');

  for (const badge of badges) {
    const created = await prisma.badgeDefinition.upsert({
      where: { code: badge.code },
      update: {
        category: badge.category,
        icon: badge.icon,
        color: badge.color,
        conditionType: badge.conditionType,
        conditionValue: badge.conditionValue,
        rarity: badge.rarity,
        sortOrder: badge.sortOrder,
      },
      create: {
        code: badge.code,
        category: badge.category,
        icon: badge.icon,
        color: badge.color,
        conditionType: badge.conditionType,
        conditionValue: badge.conditionValue,
        rarity: badge.rarity,
        sortOrder: badge.sortOrder,
      },
    });

    // Upsert translations
    for (const [locale, t] of Object.entries(badge.translations)) {
      await prisma.badgeTranslation.upsert({
        where: {
          badgeId_locale: { badgeId: created.id, locale },
        },
        update: { name: t.name, description: t.description },
        create: {
          badgeId: created.id,
          locale,
          name: t.name,
          description: t.description,
        },
      });
    }
  }

  console.log(`✅ Seeded ${badges.length} badge definitions with translations`);
}
