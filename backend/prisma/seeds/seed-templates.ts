import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * Top 20 Household Task Templates
 * Each template has EN and VI translations
 */
const taskTemplates = [
  {
    metsValue: 3.5,
    defaultDuration: 20,
    icon: 'cleaning_services',
    animation: 'vacuum.json',
    color: '#9C27B0',
    category: 'cleaning',
    translations: [
      { locale: 'en', name: 'Vacuuming', description: 'Vacuum the floors and carpets' },
      { locale: 'vi', name: 'Hút bụi', description: 'Hút bụi sàn nhà và thảm' },
    ],
  },
  {
    metsValue: 3.8,
    defaultDuration: 25,
    icon: 'cleaning_services',
    animation: 'mopping.json',
    color: '#2196F3',
    category: 'cleaning',
    translations: [
      { locale: 'en', name: 'Mopping', description: 'Mop the floors' },
      { locale: 'vi', name: 'Lau sàn', description: 'Lau sàn nhà' },
    ],
  },
  {
    metsValue: 2.3,
    defaultDuration: 15,
    icon: 'water_drop',
    animation: 'dishes.json',
    color: '#00BCD4',
    category: 'kitchen',
    translations: [
      { locale: 'en', name: 'Dishwashing', description: 'Wash dishes by hand' },
      { locale: 'vi', name: 'Rửa bát', description: 'Rửa bát đĩa bằng tay' },
    ],
  },
  {
    metsValue: 2.5,
    defaultDuration: 15,
    icon: 'dry_cleaning',
    animation: 'laundry.json',
    color: '#E91E63',
    category: 'laundry',
    translations: [
      { locale: 'en', name: 'Hanging Laundry', description: 'Hang clothes to dry' },
      { locale: 'vi', name: 'Phơi quần áo', description: 'Phơi quần áo khô' },
    ],
  },
  {
    metsValue: 2.5,
    defaultDuration: 30,
    icon: 'restaurant',
    animation: 'cooking.json',
    color: '#FF5722',
    category: 'kitchen',
    translations: [
      { locale: 'en', name: 'Cooking', description: 'Prepare and cook meals' },
      { locale: 'vi', name: 'Nấu ăn', description: 'Chuẩn bị và nấu bữa ăn' },
    ],
  },
  {
    metsValue: 2.5,
    defaultDuration: 45,
    icon: 'shopping_cart',
    animation: 'shopping.json',
    color: '#4CAF50',
    category: 'shopping',
    translations: [
      { locale: 'en', name: 'Grocery Shopping', description: 'Shop for groceries' },
      { locale: 'vi', name: 'Đi chợ', description: 'Mua thực phẩm và đồ dùng' },
    ],
  },
  {
    metsValue: 3.5,
    defaultDuration: 15,
    icon: 'bathroom',
    animation: 'toilet.json',
    color: '#607D8B',
    category: 'bathroom',
    translations: [
      { locale: 'en', name: 'Toilet Cleaning', description: 'Clean and sanitize toilet' },
      { locale: 'vi', name: 'Vệ sinh toilet', description: 'Vệ sinh và khử trùng toilet' },
    ],
  },
  {
    metsValue: 3.0,
    defaultDuration: 10,
    icon: 'bed',
    animation: 'bed.json',
    color: '#795548',
    category: 'bedroom',
    translations: [
      { locale: 'en', name: 'Making Bed', description: 'Make the bed and tidy pillows' },
      { locale: 'vi', name: 'Dọn giường', description: 'Dọn giường và gối' },
    ],
  },
  {
    metsValue: 3.3,
    defaultDuration: 15,
    icon: 'cleaning_services',
    animation: 'sweeping.json',
    color: '#8BC34A',
    category: 'cleaning',
    translations: [
      { locale: 'en', name: 'Sweeping', description: 'Sweep floors and walkways' },
      { locale: 'vi', name: 'Quét nhà', description: 'Quét sàn và lối đi' },
    ],
  },
  {
    metsValue: 2.5,
    defaultDuration: 15,
    icon: 'air',
    animation: 'dusting.json',
    color: '#FFEB3B',
    category: 'cleaning',
    translations: [
      { locale: 'en', name: 'Dusting', description: 'Dust furniture and surfaces' },
      { locale: 'vi', name: 'Lau bụi', description: 'Lau bụi đồ đạc và bề mặt' },
    ],
  },
  {
    metsValue: 2.3,
    defaultDuration: 30,
    icon: 'iron',
    animation: 'ironing.json',
    color: '#FF9800',
    category: 'laundry',
    translations: [
      { locale: 'en', name: 'Ironing', description: 'Iron clothes and linens' },
      { locale: 'vi', name: 'Ủi đồ', description: 'Ủi quần áo và khăn trải' },
    ],
  },
  {
    metsValue: 2.0,
    defaultDuration: 15,
    icon: 'checkroom',
    animation: 'folding.json',
    color: '#673AB7',
    category: 'laundry',
    translations: [
      { locale: 'en', name: 'Folding Clothes', description: 'Fold and organize laundry' },
      { locale: 'vi', name: 'Gấp quần áo', description: 'Gấp và sắp xếp quần áo' },
    ],
  },
  {
    metsValue: 2.5,
    defaultDuration: 15,
    icon: 'yard',
    animation: 'watering.json',
    color: '#4CAF50',
    category: 'outdoor',
    translations: [
      { locale: 'en', name: 'Watering Plants', description: 'Water indoor and outdoor plants' },
      { locale: 'vi', name: 'Tưới cây', description: 'Tưới cây trong nhà và ngoài sân' },
    ],
  },
  {
    metsValue: 2.5,
    defaultDuration: 10,
    icon: 'delete',
    animation: 'trash.json',
    color: '#9E9E9E',
    category: 'kitchen',
    translations: [
      { locale: 'en', name: 'Taking Out Trash', description: 'Collect and dispose trash' },
      { locale: 'vi', name: 'Đổ rác', description: 'Thu gom và đổ rác' },
    ],
  },
  {
    metsValue: 3.2,
    defaultDuration: 20,
    icon: 'window',
    animation: 'window.json',
    color: '#03A9F4',
    category: 'cleaning',
    translations: [
      { locale: 'en', name: 'Window Cleaning', description: 'Clean windows and glass surfaces' },
      { locale: 'vi', name: 'Lau kính', description: 'Lau cửa kính và bề mặt kính' },
    ],
  },
  {
    metsValue: 2.8,
    defaultDuration: 15,
    icon: 'kitchen',
    animation: 'kitchen.json',
    color: '#FFC107',
    category: 'kitchen',
    translations: [
      { locale: 'en', name: 'Kitchen Cleanup', description: 'Clean kitchen surfaces and appliances' },
      { locale: 'vi', name: 'Dọn bếp', description: 'Lau dọn bề mặt và thiết bị bếp' },
    ],
  },
  {
    metsValue: 4.0,
    defaultDuration: 20,
    icon: 'bathtub',
    animation: 'bathroom.json',
    color: '#00BCD4',
    category: 'bathroom',
    translations: [
      { locale: 'en', name: 'Bathroom Scrubbing', description: 'Deep clean bathroom and tiles' },
      { locale: 'vi', name: 'Cọ nhà tắm', description: 'Vệ sinh sâu nhà tắm và gạch' },
    ],
  },
  {
    metsValue: 3.0,
    defaultDuration: 30,
    icon: 'inventory_2',
    animation: 'organizing.json',
    color: '#3F51B5',
    category: 'organizing',
    translations: [
      { locale: 'en', name: 'Organizing Closet', description: 'Organize and sort wardrobe' },
      { locale: 'vi', name: 'Sắp xếp tủ', description: 'Sắp xếp và phân loại tủ đồ' },
    ],
  },
  {
    metsValue: 3.0,
    defaultDuration: 20,
    icon: 'pets',
    animation: 'pet.json',
    color: '#FF5722',
    category: 'care',
    translations: [
      { locale: 'en', name: 'Pet Care', description: 'Feed and groom pets' },
      { locale: 'vi', name: 'Chăm thú cưng', description: 'Cho ăn và chải lông thú cưng' },
    ],
  },
  {
    metsValue: 4.0,
    defaultDuration: 25,
    icon: 'grass',
    animation: 'yard.json',
    color: '#8BC34A',
    category: 'outdoor',
    translations: [
      { locale: 'en', name: 'Yard Sweeping', description: 'Sweep yard and outdoor areas' },
      { locale: 'vi', name: 'Quét sân', description: 'Quét sân và khu vực ngoài trời' },
    ],
  },
];

async function main() {
  console.log('🌱 Seeding task templates...');

  for (let i = 0; i < taskTemplates.length; i++) {
    const template = taskTemplates[i];

    await prisma.taskTemplate.create({
      data: {
        metsValue: template.metsValue,
        defaultDuration: template.defaultDuration,
        icon: template.icon,
        animation: template.animation,
        color: template.color,
        category: template.category,
        sortOrder: i,
        translations: {
          create: template.translations,
        },
      },
    });

    console.log(`  ✓ Created: ${template.translations[0].name}`);
  }

  console.log(`\n✅ Seeded ${taskTemplates.length} task templates successfully!`);
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
