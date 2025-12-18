import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsInt,
  IsEnum,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

enum AuthProvider {
  GOOGLE = 'GOOGLE',
  APPLE = 'APPLE',
}

export class CreateUserDto {
  @ApiProperty({
    example: 'firebase-uid-123456',
    description: 'Firebase UID from authentication provider',
  })
  @IsString()
  @IsNotEmpty()
  firebaseUid: string;

  @ApiProperty({
    example: 'GOOGLE',
    description: 'Authentication provider',
    enum: AuthProvider,
  })
  @IsEnum(AuthProvider)
  @IsNotEmpty()
  provider: AuthProvider;

  @ApiPropertyOptional({
    example: 'john.doe@example.com',
    description: 'User email address',
  })
  @IsEmail()
  @IsOptional()
  email?: string;

  @ApiPropertyOptional({
    example: 'John Doe',
    description: 'User full name',
  })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional({
    example: 1,
    description: 'Avatar ID from app library',
  })
  @IsInt()
  @IsOptional()
  avatarId?: number;

  @ApiPropertyOptional({
    example: 'https://example.com/avatar.jpg',
    description: 'External avatar URL',
  })
  @IsString()
  @IsOptional()
  avatarUrl?: string;
}
