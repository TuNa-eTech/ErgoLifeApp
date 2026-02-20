import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class BadgeResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  code: string;

  @ApiProperty()
  category: string;

  @ApiProperty()
  icon: string;

  @ApiProperty()
  color: string;

  @ApiProperty()
  rarity: string;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  description?: string;

  @ApiProperty()
  isEarned: boolean;

  @ApiProperty({ description: 'Progress 0.0 - 1.0' })
  progress: number;

  @ApiPropertyOptional()
  unlockedAt?: Date;

  @ApiProperty()
  conditionType: string;

  @ApiProperty()
  conditionValue: number;

  @ApiProperty({ description: 'Current value toward the condition' })
  currentValue: number;
}

export class BadgeListResponseDto {
  @ApiProperty({ type: [BadgeResponseDto] })
  badges: BadgeResponseDto[];

  @ApiProperty()
  earnedCount: number;

  @ApiProperty()
  totalCount: number;
}
