import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { StreakReminderService } from './streak-reminder.service';
import { ActivityPatternService } from './activity-pattern.service';
import { LeaderboardNotificationService } from './leaderboard-notification.service';

@Module({
  imports: [ScheduleModule.forRoot()],
  controllers: [NotificationsController],
  providers: [
    NotificationsService,
    StreakReminderService,
    ActivityPatternService,
    LeaderboardNotificationService,
  ],
  exports: [NotificationsService],
})
export class NotificationsModule {}
