import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsInt, Min, Max } from 'class-validator';

export class UpdateGoalSettingsDto {
  @ApiPropertyOptional({
    description: 'Daily EP target',
    minimum: 50,
    maximum: 5000,
    default: 500,
  })
  @IsOptional()
  @IsInt()
  @Min(50)
  @Max(5000)
  targetEp?: number;

  @ApiPropertyOptional({
    description: 'Daily duration target in minutes',
    minimum: 5,
    maximum: 300,
    default: 30,
  })
  @IsOptional()
  @IsInt()
  @Min(5)
  @Max(300)
  targetDuration?: number;

  @ApiPropertyOptional({
    description: 'Daily activity count target',
    minimum: 1,
    maximum: 20,
    default: 2,
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(20)
  targetActivities?: number;
}
