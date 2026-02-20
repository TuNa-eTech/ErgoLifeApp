import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsDateString } from 'class-validator';

export class GetGoalHistoryDto {
  @ApiPropertyOptional({
    description: 'Start date (ISO format, e.g. 2026-01-01)',
  })
  @IsOptional()
  @IsDateString()
  from?: string;

  @ApiPropertyOptional({
    description: 'End date (ISO format, e.g. 2026-01-31)',
  })
  @IsOptional()
  @IsDateString()
  to?: string;
}
