import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, Min, Max, IsEnum } from 'class-validator';
import { Type } from 'class-transformer';

// ============= Request DTOs =============

export class GetRedemptionsQueryDto {
  @ApiPropertyOptional({
    example: 'PENDING',
    enum: ['PENDING', 'USED', 'all'],
    default: 'all',
  })
  @IsOptional()
  @IsString()
  status?: 'PENDING' | 'USED' | 'all' = 'all';

  @ApiPropertyOptional({ example: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 20;
}

// ============= Response DTOs =============

export class RedemptionDto {
  @ApiProperty({ example: '990e8400-e29b-41d4-a716-446655444444' })
  id: string;

  @ApiProperty({ example: 'Miễn rửa bát 1 ngày' })
  rewardTitle: string;

  @ApiProperty({ example: 1000 })
  pointsSpent: number;

  @ApiProperty({ example: 'PENDING', enum: ['PENDING', 'USED', 'EXPIRED'] })
  status: string;

  @ApiProperty({ example: '2025-12-20T14:00:00.000Z' })
  redeemedAt: Date;

  @ApiPropertyOptional({ example: '2025-12-20T18:00:00.000Z' })
  usedAt: Date | null;
}

export class PaginationDto {
  @ApiProperty({ example: 1 })
  page: number;

  @ApiProperty({ example: 20 })
  limit: number;

  @ApiProperty({ example: 5 })
  total: number;

  @ApiProperty({ example: 1 })
  totalPages: number;
}

export class GetRedemptionsResponseDto {
  @ApiProperty({ type: [RedemptionDto] })
  items: RedemptionDto[];

  @ApiProperty({ type: PaginationDto })
  pagination: PaginationDto;
}

export class UseRedemptionResponseDto {
  @ApiProperty({ example: '990e8400-e29b-41d4-a716-446655444444' })
  id: string;

  @ApiProperty({ example: 'USED' })
  status: string;

  @ApiProperty({ example: '2025-12-20T18:00:00.000Z' })
  usedAt: Date;
}
