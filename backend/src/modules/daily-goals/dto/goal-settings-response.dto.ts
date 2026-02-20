import { ApiProperty } from '@nestjs/swagger';

export class GoalSettingsResponseDto {
  @ApiProperty() targetEp: number;
  @ApiProperty() targetDuration: number;
  @ApiProperty() targetActivities: number;
}
