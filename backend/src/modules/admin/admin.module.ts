import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';

import { TaskTemplateController } from './task-template.controller';
import { TaskTemplateService } from './task-template.service';

import { AdminStatsController } from './stats.controller';
import { AdminStatsService } from './stats.service';
import { AdminUsersController } from './users.controller';
import { AdminUsersService } from './users.service';
import { AdminHousesController } from './houses.controller';
import { AdminHousesService } from './houses.service';

import { AdminNotificationsController } from './notifications.controller';
import { AdminNotificationsService } from './notifications.service';
import { AdminBadgesController } from './badges.controller';
import { AdminBadgesService } from './badges.service';
import { AdminGiftRewardsController } from './gift-rewards.controller';
import { AdminGiftRewardsService } from './gift-rewards.service';
import { AdminActivitiesController } from './activities.controller';
import { AdminActivitiesService } from './activities.service';
import { AdminRedemptionsController } from './redemptions.controller';
import { AdminRedemptionsService } from './redemptions.service';

import { NotificationsModule } from '../notifications/notifications.module';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    PassportModule,
    NotificationsModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret:
          configService.get<string>('ADMIN_JWT_SECRET') ||
          'dev_master_secret',
        signOptions: { expiresIn: '1d' },
      }),
    }),
  ],
  controllers: [
    AuthController,
    TaskTemplateController,
    AdminStatsController,
    AdminUsersController,
    AdminHousesController,
    AdminNotificationsController,
    AdminBadgesController,
    AdminGiftRewardsController,
    AdminActivitiesController,
    AdminRedemptionsController,
  ],
  providers: [
    AuthService,
    JwtStrategy,
    TaskTemplateService,
    AdminStatsService,
    AdminUsersService,
    AdminHousesService,
    AdminNotificationsService,
    AdminBadgesService,
    AdminGiftRewardsService,
    AdminActivitiesService,
    AdminRedemptionsService,
  ],
  exports: [AuthService],
})
export class AdminModule {}
