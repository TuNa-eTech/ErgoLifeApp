import { PrismaClient, AuthProvider, RedemptionStatus } from '@prisma/client';

const prisma = new PrismaClient();

const USERS_TO_CREATE = 5;
const DAYS_OF_HISTORY = 30;

// Helper to generate random integer
function randomInt(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Helper to get random array item
function randomItem<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

// Task templates for random activity generation
const ACTIVITIES = [
  { name: 'Vacuuming', mets: 3.5, duration: 20 },
  { name: 'Dishwashing', mets: 2.3, duration: 15 },
  { name: 'Cooking', mets: 2.5, duration: 30 },
  { name: 'Laundry', mets: 2.5, duration: 20 },
  { name: 'Gardening', mets: 3.8, duration: 45 },
  { name: 'Mowing Lawn', mets: 5.0, duration: 30 },
  { name: 'Cleaning Bathroom', mets: 3.5, duration: 25 },
  { name: 'Grocery Shopping', mets: 2.5, duration: 45 },
];

export async function createUsers() {
  console.log('👥 Seeding users...');

  for (let i = 1; i <= USERS_TO_CREATE; i++) {
    const firebaseUid = `user_seed_${i}`;
    const email = `user${i}@example.com`;
    const displayName = `Seed User ${i}`;
    
    // Check if user exists
    let user = await prisma.user.findUnique({
      where: { firebaseUid },
    });

    if (!user) {
      // 1. Create User
      user = await prisma.user.create({
        data: {
          firebaseUid,
          email,
          displayName,
          provider: AuthProvider.GOOGLE,
          avatarId: randomInt(1, 10), // Assuming there are at least 10 avatars
          walletBalance: randomInt(0, 500),
          currentStreak: randomInt(0, 10),
          longestStreak: randomInt(10, 30),
          createdAt: new Date(),
        },
      });
      console.log(`  ✓ Created user: ${displayName}`);
    } else {
      console.log(`  ℹ User exists: ${displayName}`);
    }

    // 2. Create Personal House (if not exists)
    let house = await prisma.house.findFirst({
      where: { createdById: user.id, isPersonal: true },
    });

    if (!house) {
      house = await prisma.house.create({
        data: {
          name: `${displayName}'s House`,
          isPersonal: true,
          createdById: user.id,
          members: {
            connect: { id: user.id },
          },
        },
      });
      console.log(`    ✓ Created personal house`);
      
      // Update user's current house
      await prisma.user.update({
        where: { id: user.id },
        data: { houseId: house.id },
      });
    }

    // 3. Create Activity History
    // We'll generate mostly consecutive days of activity, with some gaps
    const today = new Date();
    let activitiesCreated = 0;

    for (let d = 0; d < DAYS_OF_HISTORY; d++) {
      // 80% chance to have activity on a given day
      if (Math.random() > 0.2) {
        const date = new Date(today);
        date.setDate(date.getDate() - d);
        
        // 1-3 activities per day
        const numActivities = randomInt(1, 3);
        
        for (let a = 0; a < numActivities; a++) {
          const activityTemplate = randomItem(ACTIVITIES);
          // Vary duration slightly (+- 5 mins)
          const duration = Math.max(5, activityTemplate.duration + randomInt(-5, 10));
          // Calculate arbitrary points (e.g. 10 * METs)
          const points = Math.floor(duration * activityTemplate.mets * 0.5); 

          await prisma.activity.create({
            data: {
              userId: user.id,
              houseId: house.id,
              taskName: activityTemplate.name,
              metsValue: activityTemplate.mets,
              durationSeconds: duration * 60,
              pointsEarned: points,
              completedAt: date,
            },
          });
          activitiesCreated++;
        }
      }
    }
    console.log(`    ✓ Created ${activitiesCreated} activities`);

    // 4. Create Custom Tasks
    const customTasksCount = await prisma.customTask.count({ where: { userId: user.id } });
    if (customTasksCount === 0) {
        await prisma.customTask.createMany({
            data: [
                {
                    userId: user.id,
                    exerciseName: 'My Special Workout',
                    durationMinutes: 45,
                    metsValue: 6.0,
                    icon: 'fitness_center',
                    color: '#FF0000',
                },
                 {
                    userId: user.id,
                    exerciseName: 'Morning Yoga',
                    durationMinutes: 20,
                    metsValue: 2.5,
                    icon: 'self_improvement',
                    color: '#00FF00',
                }
            ]
        });
        console.log(`    ✓ Created custom tasks`);
    }
  }
}
