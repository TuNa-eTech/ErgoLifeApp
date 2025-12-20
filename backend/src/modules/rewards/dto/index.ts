import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsInt,
  IsOptional,
  Min,
  Max,
  MinLength,
  MaxLength,
  IsBoolean,
} from 'class-validator';
import { Type } from 'class-transformer';

// ============= Request DTOs =============

export class CreateRewardDto {
  @ApiProperty({
    example: 'Bữa sáng trên giường',
    description: 'Reward title (2-50 characters)',
    minLength: 2,
    maxLength: 50,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(50)
  title: string;

  @ApiProperty({
    example: 2000,
    description: 'Cost in ErgoPoints (100-10000)',
    minimum: 100,
    maximum: 10000,
  })
  @IsInt()
  @Min(100, { message: 'Cost must be at least 100 points' })
  @Max(10000, { message: 'Cost must be at most 10000 points' })
  cost: number;

  @ApiProperty({
    example: 'breakfast',
    description: 'Icon name (1-30 characters)',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(1)
  @MaxLength(30)
  icon: string;

  @ApiPropertyOptional({
    example: 'Được phục vụ bữa sáng tại giường vào cuối tuần',
    description: 'Description (max 200 characters)',
  })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  description?: string;
}

export class UpdateRewardDto {
  @ApiPropertyOptional({
    example: 'Bữa sáng trên giường (cuối tuần)',
    minLength: 2,
    maxLength: 50,
  })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  title?: string;

  @ApiPropertyOptional({
    example: 2500,
    minimum: 100,
    maximum: 10000,
  })
  @IsOptional()
  @IsInt()
  @Min(100)
  @Max(10000)
  cost?: number;

  @ApiPropertyOptional({
    example: 'breakfast',
  })
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(30)
  icon?: string;

  @ApiPropertyOptional({
    example: 'Updated description',
  })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  description?: string;
}

export class GetRewardsQueryDto {
  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  activeOnly?: boolean = true;
}

// ============= Response DTOs =============

export class RewardCreatorDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440001' })
  id: string;

  @ApiPropertyOptional({ example: 'Lan Trần' })
  displayName: string | null;
}

export class RewardDto {
  @ApiProperty({ example: '880e8400-e29b-41d4-a716-446655443333' })
  id: string;

  @ApiProperty({ example: 'Miễn rửa bát 1 ngày' })
  title: string;

  @ApiProperty({ example: 1000 })
  cost: number;

  @ApiProperty({ example: 'dish_free' })
  icon: string;

  @ApiPropertyOptional({ example: 'Được miễn rửa bát trong 1 ngày' })
  description: string | null;

  @ApiProperty({ type: RewardCreatorDto })
  creator: RewardCreatorDto;

  @ApiProperty({ example: true })
  isActive: boolean;

  @ApiProperty({ example: '2025-12-15T08:00:00.000Z' })
  createdAt: Date;
}

export class GetRewardsResponseDto {
  @ApiProperty({ type: [RewardDto] })
  rewards: RewardDto[];

  @ApiProperty({ example: 3270 })
  userBalance: number;
}

export class DeleteRewardResponseDto {
  @ApiProperty({ example: 'Reward deleted successfully' })
  message: string;
}

// Redemption response for the redeem endpoint
export class RedemptionSnapshotDto {
  @ApiProperty({ example: '990e8400-e29b-41d4-a716-446655444444' })
  id: string;

  @ApiProperty({ example: 'Miễn rửa bát 1 ngày' })
  rewardTitle: string;

  @ApiProperty({ example: 1000 })
  pointsSpent: number;

  @ApiProperty({ example: 'PENDING' })
  status: string;

  @ApiProperty({ example: '2025-12-20T14:00:00.000Z' })
  redeemedAt: Date;
}

export class WalletSpendDto {
  @ApiProperty({ example: 3270 })
  previousBalance: number;

  @ApiProperty({ example: 1000 })
  pointsSpent: number;

  @ApiProperty({ example: 2270 })
  newBalance: number;
}

export class RedeemRewardResponseDto {
  @ApiProperty({ type: RedemptionSnapshotDto })
  redemption: RedemptionSnapshotDto;

  @ApiProperty({ type: WalletSpendDto })
  wallet: WalletSpendDto;
}
