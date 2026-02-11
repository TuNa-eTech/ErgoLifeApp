import { PrismaClient, GiftRewardCategory } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * 20 Hardcoded Gift Rewards
 * Organized by 4 categories with EN and VI translations
 */
const giftRewards = [
  // ===== PRAISE & RECOGNITION =====
  {
    key: 'brightest_star',
    category: GiftRewardCategory.PRAISE,
    icon: '⭐',
    cost: 100,
    translations: [
      { locale: 'en', name: 'Brightest Star', description: 'You shine the brightest in our family!' },
      { locale: 'vi', name: 'Ngôi Sao Sáng Nhất', description: 'Bạn toả sáng nhất trong gia đình!' },
    ],
  },
  {
    key: 'superhero',
    category: GiftRewardCategory.PRAISE,
    icon: '🦸',
    cost: 100,
    translations: [
      { locale: 'en', name: 'Family Superhero', description: 'Thanks for saving the day!' },
      { locale: 'vi', name: 'Siêu Anh Hùng Gia Đình', description: 'Cảm ơn vì đã cứu nguy hôm nay!' },
    ],
  },
  {
    key: 'golden_heart',
    category: GiftRewardCategory.PRAISE,
    icon: '💛',
    cost: 150,
    translations: [
      { locale: 'en', name: 'Golden Heart', description: 'For your kindness and warm heart' },
      { locale: 'vi', name: 'Trái Tim Vàng', description: 'Dành cho trái tim ấm áp và tốt bụng của bạn' },
    ],
  },
  {
    key: 'mvp_award',
    category: GiftRewardCategory.PRAISE,
    icon: '🏆',
    cost: 200,
    translations: [
      { locale: 'en', name: 'MVP of the Day', description: 'You were the most valuable family member today!' },
      { locale: 'vi', name: 'MVP Của Ngày', description: 'Bạn là thành viên xuất sắc nhất hôm nay!' },
    ],
  },
  {
    key: 'thank_you_note',
    category: GiftRewardCategory.PRAISE,
    icon: '💌',
    cost: 100,
    translations: [
      { locale: 'en', name: 'Thank You Note', description: 'A heartfelt thank you for everything you do' },
      { locale: 'vi', name: 'Lời Cảm Ơn', description: 'Lời cảm ơn chân thành cho tất cả những gì bạn làm' },
    ],
  },

  // ===== FAMILY PRIVILEGES =====
  {
    key: 'skip_dishes',
    category: GiftRewardCategory.PRIVILEGE,
    icon: '🧹',
    cost: 500,
    translations: [
      { locale: 'en', name: 'Skip Dishwashing', description: "You're off dish duty for today! Enjoy!" },
      { locale: 'vi', name: 'Miễn Rửa Bát', description: 'Hôm nay bạn được miễn rửa bát! Tận hưởng nhé!' },
    ],
  },
  {
    key: 'movie_night',
    category: GiftRewardCategory.PRIVILEGE,
    icon: '🎬',
    cost: 400,
    translations: [
      { locale: 'en', name: 'Choose Movie Night', description: 'You get to pick what we watch tonight!' },
      { locale: 'vi', name: 'Chọn Phim Tối Nay', description: 'Bạn được chọn phim cho cả nhà xem tối nay!' },
    ],
  },
  {
    key: 'sleep_in',
    category: GiftRewardCategory.PRIVILEGE,
    icon: '😴',
    cost: 600,
    translations: [
      { locale: 'en', name: 'Sleep In Pass', description: 'Sleep in as long as you want tomorrow morning' },
      { locale: 'vi', name: 'Phiếu Ngủ Nướng', description: 'Ngủ nướng thoải mái vào sáng mai nhé' },
    ],
  },
  {
    key: 'menu_pick',
    category: GiftRewardCategory.PRIVILEGE,
    icon: '🍽️',
    cost: 300,
    translations: [
      { locale: 'en', name: "Pick Today's Menu", description: 'You decide what the family eats today!' },
      { locale: 'vi', name: 'Chọn Thực Đơn Hôm Nay', description: 'Bạn quyết định cả nhà ăn gì hôm nay!' },
    ],
  },
  {
    key: 'remote_control',
    category: GiftRewardCategory.PRIVILEGE,
    icon: '📺',
    cost: 300,
    translations: [
      { locale: 'en', name: 'Remote Control Boss', description: 'The remote is yours for the whole evening!' },
      { locale: 'vi', name: 'Quyền Điều Khiển TV', description: 'Remote TV là của bạn cả tối nay!' },
    ],
  },

  // ===== FUN EXPERIENCES =====
  {
    key: 'ice_cream',
    category: GiftRewardCategory.EXPERIENCE,
    icon: '🍦',
    cost: 400,
    translations: [
      { locale: 'en', name: 'Ice Cream Treat', description: 'You deserve a sweet ice cream treat!' },
      { locale: 'vi', name: 'Đãi Kem', description: 'Bạn xứng đáng được thưởng thức kem!' },
    ],
  },
  {
    key: 'massage_15min',
    category: GiftRewardCategory.EXPERIENCE,
    icon: '💆',
    cost: 800,
    translations: [
      { locale: 'en', name: '15-Min Massage', description: 'Relax with a 15-minute shoulder massage' },
      { locale: 'vi', name: 'Massage 15 Phút', description: 'Thư giãn với 15 phút massage vai' },
    ],
  },
  {
    key: 'breakfast_in_bed',
    category: GiftRewardCategory.EXPERIENCE,
    icon: '🥐',
    cost: 700,
    translations: [
      { locale: 'en', name: 'Breakfast in Bed', description: 'Wake up to a lovely breakfast in bed' },
      { locale: 'vi', name: 'Bữa Sáng Trên Giường', description: 'Thức dậy với bữa sáng yêu thương trên giường' },
    ],
  },
  {
    key: 'game_time',
    category: GiftRewardCategory.EXPERIENCE,
    icon: '🎮',
    cost: 500,
    translations: [
      { locale: 'en', name: '30-Min Game Time', description: 'Enjoy 30 minutes of your favorite game!' },
      { locale: 'vi', name: '30 Phút Chơi Game', description: 'Tận hưởng 30 phút chơi game yêu thích!' },
    ],
  },
  {
    key: 'story_time',
    category: GiftRewardCategory.EXPERIENCE,
    icon: '📖',
    cost: 300,
    translations: [
      { locale: 'en', name: 'Bedtime Story', description: 'A special bedtime story just for you' },
      { locale: 'vi', name: 'Kể Chuyện Trước Ngủ', description: 'Một câu chuyện đặc biệt trước giờ ngủ dành cho bạn' },
    ],
  },

  // ===== MOTIVATION & SPIRIT =====
  {
    key: 'keep_going',
    category: GiftRewardCategory.MOTIVATION,
    icon: '💪',
    cost: 100,
    translations: [
      { locale: 'en', name: 'Keep Going!', description: "Don't give up! You're doing amazing!" },
      { locale: 'vi', name: 'Cố Lên Nào!', description: 'Đừng bỏ cuộc! Bạn đang làm rất tuyệt!' },
    ],
  },
  {
    key: 'warm_hug',
    category: GiftRewardCategory.MOTIVATION,
    icon: '🤗',
    cost: 100,
    translations: [
      { locale: 'en', name: 'Warm Hug', description: 'Sending you the biggest, warmest hug!' },
      { locale: 'vi', name: 'Cái Ôm Ấm Áp', description: 'Gửi bạn cái ôm ấm áp nhất!' },
    ],
  },
  {
    key: 'proud_of_you',
    category: GiftRewardCategory.MOTIVATION,
    icon: '🌟',
    cost: 150,
    translations: [
      { locale: 'en', name: 'So Proud of You', description: "I'm so proud of everything you've achieved!" },
      { locale: 'vi', name: 'Tự Hào Về Bạn', description: 'Rất tự hào về những gì bạn đã đạt được!' },
    ],
  },
  {
    key: 'energy_boost',
    category: GiftRewardCategory.MOTIVATION,
    icon: '⚡',
    cost: 200,
    translations: [
      { locale: 'en', name: 'Energy Boost', description: "Here's a burst of energy to power through!" },
      { locale: 'vi', name: 'Nạp Năng Lượng', description: 'Đây là năng lượng để bạn bứt phá!' },
    ],
  },
  {
    key: 'lucky_charm',
    category: GiftRewardCategory.MOTIVATION,
    icon: '🍀',
    cost: 150,
    translations: [
      { locale: 'en', name: 'Lucky Charm', description: 'Wishing you all the luck today!' },
      { locale: 'vi', name: 'Bùa May Mắn', description: 'Chúc bạn thật nhiều may mắn hôm nay!' },
    ],
  },
];

async function main() {
  console.log('🎁 Seeding gift rewards...');

  for (let i = 0; i < giftRewards.length; i++) {
    const reward = giftRewards[i];

    const upserted = await prisma.giftReward.upsert({
      where: { key: reward.key },
      update: {
        category: reward.category,
        icon: reward.icon,
        cost: reward.cost,
        sortOrder: i,
      },
      create: {
        key: reward.key,
        category: reward.category,
        icon: reward.icon,
        cost: reward.cost,
        sortOrder: i,
        translations: {
          create: reward.translations,
        },
      },
    });

    // Update translations on re-seed
    for (const t of reward.translations) {
      await prisma.giftRewardTranslation.upsert({
        where: {
          rewardId_locale: {
            rewardId: upserted.id,
            locale: t.locale,
          },
        },
        update: { name: t.name, description: t.description },
        create: {
          rewardId: upserted.id,
          locale: t.locale,
          name: t.name,
          description: t.description,
        },
      });
    }

    console.log(`  ✓ ${reward.translations[0].name} (${reward.icon} ${reward.cost} EP)`);
  }

  console.log(`\n✅ Seeded ${giftRewards.length} gift rewards successfully!`);
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
