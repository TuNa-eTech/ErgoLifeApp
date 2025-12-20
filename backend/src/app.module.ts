import { Module } from '@nestjs/common';
import { AppConfigModule } from './config/config.module';
import { PrismaModule } from './prisma/prisma.module';
import { FirebaseModule } from './firebase';
import { UserModule } from './modules/user/user.module';
import { AuthModule } from './modules/auth/auth.module';
import { HousesModule } from './modules/houses/houses.module';
import { ActivitiesModule } from './modules/activities/activities.module';
import { RewardsModule } from './modules/rewards/rewards.module';
import { RedemptionsModule } from './modules/redemptions/redemptions.module';

@Module({
  imports: [
    AppConfigModule,
    PrismaModule,
    FirebaseModule,
    AuthModule,
    UserModule,
    HousesModule,
    ActivitiesModule,
    RewardsModule,
    RedemptionsModule,
  ],
})
export class AppModule {}
