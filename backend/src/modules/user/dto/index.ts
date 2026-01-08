import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsInt,
  Min,
  Max,
  MinLength,
  MaxLength,
} from 'class-validator';

export class UpdateProfileDto {
  @ApiPropertyOptional({
    example: 'Minh Nguyễn',
    description: 'Display name (2-30 characters)',
    minLength: 2,
    maxLength: 30,
  })
  @IsOptional()
  @IsString()
  @MinLength(2, { message: 'Display name must be at least 2 characters' })
  @MaxLength(30, { message: 'Display name must be at most 30 characters' })
  displayName?: string;

  @ApiPropertyOptional({
    example: 5,
    description: 'Avatar ID from library (1-20)',
    minimum: 1,
    maximum: 20,
  })
  @IsOptional()
  @IsInt()
  @Min(1, { message: 'Avatar ID must be at least 1' })
  @Max(20, { message: 'Avatar ID must be at most 20' })
  avatarId?: number;
}

export class UpdateFcmTokenDto {
  @ApiProperty({
    example: 'dYjK8L2xQPGD:APA91bHJdK...',
    description: 'FCM token from firebase_messaging',
  })
  @IsString()
  fcmToken: string;
}

export class FcmTokenResponseDto {
  @ApiProperty({ example: 'FCM token updated successfully' })
  message: string;
}

export class UserProfileDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  id: string;

  @ApiPropertyOptional({ example: 'Minh Nguyễn' })
  displayName: string | null;

  @ApiPropertyOptional({ example: 5 })
  avatarId: number | null;

  @ApiPropertyOptional({ example: 'user@gmail.com' })
  email: string | null;

  @ApiProperty({ example: 2500 })
  walletBalance: number;

  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655441111' })
  houseId: string | null;
}

export class OtherUserDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440001' })
  id: string;

  @ApiPropertyOptional({ example: 'Lan Trần' })
  displayName: string | null;

  @ApiPropertyOptional({ example: 8 })
  avatarId: number | null;

  @ApiProperty({ example: 1800 })
  walletBalance: number;
}
