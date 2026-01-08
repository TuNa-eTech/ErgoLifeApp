import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, MinLength, MaxLength } from 'class-validator';

// ============= Request DTOs =============

export class CreateHouseDto {
  @ApiProperty({
    example: 'Nhà của Mèo & Cún',
    description: 'House name (2-50 characters)',
    minLength: 2,
    maxLength: 50,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(2, { message: 'House name must be at least 2 characters' })
  @MaxLength(50, { message: 'House name must be at most 50 characters' })
  name: string;
}

export class JoinHouseDto {
  @ApiProperty({
    example: 'clxyz123abc',
    description: 'Invite code from existing house',
  })
  @IsString()
  @IsNotEmpty()
  inviteCode: string;
}

// ============= Response DTOs =============

export class HouseMemberDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  id: string;

  @ApiPropertyOptional({ example: 'Minh Nguyễn' })
  displayName: string | null;

  @ApiPropertyOptional({ example: 3 })
  avatarId: number | null;

  @ApiPropertyOptional({ example: 2500 })
  walletBalance?: number;
}

export class HouseDto {
  @ApiProperty({ example: '660e8400-e29b-41d4-a716-446655441111' })
  id: string;

  @ApiProperty({ example: 'Nhà của Mèo & Cún' })
  name: string;

  @ApiProperty({ example: 'clxyz123abc' })
  inviteCode: string;

  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  createdBy: string;

  @ApiProperty({ type: [HouseMemberDto] })
  members: HouseMemberDto[];

  @ApiProperty({ example: 2 })
  memberCount: number;

  @ApiProperty({ example: '2025-12-20T09:00:00.000Z' })
  createdAt: Date;
}

export class InviteDto {
  @ApiProperty({ example: 'clxyz123abc' })
  inviteCode: string;

  @ApiProperty({ example: 'https://ergolife.app/join/clxyz123abc' })
  deepLink: string;

  @ApiPropertyOptional({
    example: 'https://api.ergolife.app/qr/clxyz123abc.png',
  })
  qrCodeUrl?: string;
}

export class HousePreviewDto {
  @ApiProperty({ example: 'Nhà của Mèo & Cún' })
  name: string;

  @ApiProperty({ example: 2 })
  memberCount: number;

  @ApiProperty({ example: false })
  isFull: boolean;

  @ApiProperty({ example: [3, 8], type: [Number] })
  memberAvatars: (number | null)[];
}

export class LeaveHouseResponseDto {
  @ApiProperty({ example: 'Successfully left the house' })
  message: string;

  @ApiProperty({
    example: false,
    description: 'True if user was the last member and house was deleted',
  })
  houseDeleted: boolean;
}
