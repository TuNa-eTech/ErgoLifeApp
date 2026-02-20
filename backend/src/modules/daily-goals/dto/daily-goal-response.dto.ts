import { ApiProperty } from '@nestjs/swagger';

export class DailyGoalResponseDto {
  @ApiProperty() id: string;
  @ApiProperty() date: string;
  @ApiProperty() targetEp: number;
  @ApiProperty() targetDuration: number;
  @ApiProperty() targetActivities: number;
  @ApiProperty() currentEp: number;
  @ApiProperty() currentDuration: number;
  @ApiProperty() currentActivities: number;
  @ApiProperty() isPerfectDay: boolean;
  @ApiProperty({ required: false }) completedAt?: string;

  @ApiProperty({
    description: 'EP ring progress (0.0 to 1.0+)',
  })
  epProgress: number;

  @ApiProperty({
    description: 'Duration ring progress (0.0 to 1.0+)',
  })
  durationProgress: number;

  @ApiProperty({
    description: 'Activities ring progress (0.0 to 1.0+)',
  })
  activitiesProgress: number;
}
