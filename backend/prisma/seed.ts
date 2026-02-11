import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...\n');

  // Seed task templates (imported side-effect — runs its own main())
  await import('./seeds/seed-templates');

  // Seed gift rewards
  await import('./seeds/seed-gift-rewards');

  console.log('\n✅ All seeds completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
