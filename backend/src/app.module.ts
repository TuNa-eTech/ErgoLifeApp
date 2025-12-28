import { Module, NestModule, MiddlewareConsumer } from '@nestjs/common';
import { AppConfigModule } from './config/config.module';
import { PrismaModule } from './prisma/prisma.module';
import { FirebaseModule } from './firebase';
import { UserModule } from './modules/user/user.module';
import { AuthModule } from './modules/auth/auth.module';
import { HousesModule } from './modules/houses/houses.module';
import { ActivitiesModule } from './modules/activities/activities.module';
import { RewardsModule } from './modules/rewards/rewards.module';
import { RedemptionsModule } from './modules/redemptions/redemptions.module';
import { TasksModule } from './modules/tasks/tasks.module';
import { LoggingMiddleware } from './common/middleware/logging.middleware';

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
    TasksModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(LoggingMiddleware).forRoutes('*');
  }
}
