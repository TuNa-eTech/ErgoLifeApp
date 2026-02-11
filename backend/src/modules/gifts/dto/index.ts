import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsUUID,
  IsOptional,
  IsIn,
  IsInt,
  Min,
  Max,
  MaxLength,
} from 'class-validator';
import { Type } from 'class-transformer';

// ============= Request DTOs =============

export class SendGiftDto {
  @ApiProperty({
    example: '550e8400-e29b-41d4-a716-446655440001',
    description: 'ID of the gift reward to send',
  })
  @IsUUID()
  @IsNotEmpty()
  giftRewardId: string;

  @ApiProperty({
    example: '550e8400-e29b-41d4-a716-446655440002',
    description: 'ID of the receiver (must be in same house)',
  })
  @IsUUID()
  @IsNotEmpty()
  receiverId: string;

  @ApiPropertyOptional({
    example: 'Cảm ơn vì đã giúp dọn nhà!',
    description: 'Optional message (max 100 characters)',
    maxLength: 100,
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  message?: string;

  @ApiPropertyOptional({
    example: 'vi',
    description: 'Locale for the reward name snapshot (default: vi)',
  })
  @IsOptional()
  @IsString()
  locale?: string;
}

export class GetGiftHistoryQueryDto {
  @ApiPropertyOptional({
    enum: ['sent', 'received'],
    description: 'Filter by sent or received gifts',
  })
  @IsOptional()
  @IsIn(['sent', 'received'])
  type?: 'sent' | 'received';

  @ApiPropertyOptional({ default: 1, minimum: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 20, minimum: 1, maximum: 50 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 20;
}

export class GetGiftCatalogQueryDto {
  @ApiPropertyOptional({
    default: 'vi',
    description: 'Locale for translations (en, vi)',
  })
  @IsOptional()
  @IsString()
  locale?: string = 'vi';
}

// ============= Response DTOs =============

export class GiftRewardTranslationDto {
  @ApiProperty({ example: 'Ngôi Sao Sáng Nhất' })
  name: string;

  @ApiPropertyOptional({ example: 'Bạn toả sáng nhất trong gia đình!' })
  description: string | null;
}

export class GiftRewardDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440001' })
  id: string;

  @ApiProperty({ example: 'brightest_star' })
  key: string;

  @ApiProperty({ example: 'PRAISE' })
  category: string;

  @ApiProperty({ example: '⭐' })
  icon: string;

  @ApiProperty({ example: 100 })
  cost: number;

  @ApiProperty({ example: 'Ngôi Sao Sáng Nhất' })
  name: string;

  @ApiPropertyOptional({ example: 'Bạn toả sáng nhất trong gia đình!' })
  description: string | null;
}

export class HouseMemberDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440002' })
  id: string;

  @ApiPropertyOptional({ example: 'Lan Trần' })
  displayName: string | null;

  @ApiPropertyOptional({ example: 1 })
  avatarId: number | null;
}

export class GiftCatalogResponseDto {
  @ApiProperty({ type: [GiftRewardDto] })
  rewards: GiftRewardDto[];

  @ApiProperty({ example: 3270 })
  userBalance: number;

  @ApiProperty({ type: [HouseMemberDto] })
  houseMembers: HouseMemberDto[];
}

export class GiftTransactionDto {
  @ApiProperty({ example: '990e8400-e29b-41d4-a716-446655444444' })
  id: string;

  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440001' })
  senderId: string;

  @ApiPropertyOptional({ example: 'Anh Tú' })
  senderName: string | null;

  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440002' })
  receiverId: string;

  @ApiPropertyOptional({ example: 'Lan Trần' })
  receiverName: string | null;

  @ApiProperty({ example: 'Ngôi Sao Sáng Nhất' })
  rewardName: string;

  @ApiProperty({ example: '⭐' })
  rewardIcon: string;

  @ApiProperty({ example: 100 })
  pointsSpent: number;

  @ApiPropertyOptional({ example: 'Cảm ơn vì đã giúp dọn nhà!' })
  message: string | null;

  @ApiProperty({ example: '2025-12-20T14:00:00.000Z' })
  createdAt: Date;
}

export class WalletSpendDto {
  @ApiProperty({ example: 3270 })
  previousBalance: number;

  @ApiProperty({ example: 100 })
  pointsSpent: number;

  @ApiProperty({ example: 3170 })
  newBalance: number;
}

export class SendGiftResponseDto {
  @ApiProperty({ type: GiftTransactionDto })
  transaction: GiftTransactionDto;

  @ApiProperty({ type: WalletSpendDto })
  wallet: WalletSpendDto;
}

export class GiftHistoryResponseDto {
  @ApiProperty({ type: [GiftTransactionDto] })
  gifts: GiftTransactionDto[];

  @ApiProperty({ example: 42 })
  total: number;

  @ApiProperty({ example: true })
  hasMore: boolean;
}
