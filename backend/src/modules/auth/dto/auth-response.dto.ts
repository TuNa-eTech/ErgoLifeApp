import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class HouseSummaryDto {
  @ApiProperty({ example: '660e8400-e29b-41d4-a716-446655441111' })
  id: string;

  @ApiProperty({ example: 'Nhà của Mèo' })
  name: string;

  @ApiProperty({ example: 2 })
  memberCount: number;
}

export class UserDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  id: string;

  @ApiProperty({ example: 'abc123xyz' })
  firebaseUid: string;

  @ApiProperty({ example: 'GOOGLE', enum: ['GOOGLE', 'APPLE'] })
  provider: string;

  @ApiPropertyOptional({ example: 'user@gmail.com' })
  email: string | null;

  @ApiPropertyOptional({ example: 'Minh Nguyen' })
  displayName: string | null;

  @ApiPropertyOptional({ example: 3 })
  avatarId: number | null;

  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655441111' })
  houseId: string | null;

  @ApiProperty({ example: 2500, default: 0 })
  walletBalance: number;

  @ApiProperty({ example: 15, default: 0 })
  currentStreak: number;

  @ApiProperty({ example: 28, default: 0 })
  longestStreak: number;

  @ApiProperty({ example: 1, default: 0 })
  streakFreezeCount: number;

  @ApiPropertyOptional({ type: HouseSummaryDto })
  house?: HouseSummaryDto | null;
}

export class AuthResponseDto {
  @ApiProperty({
    description: 'JWT access token for authenticating subsequent requests',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  accessToken: string;

  @ApiProperty({
    description: 'Authenticated user information',
    type: UserDto,
  })
  user: UserDto;

  @ApiProperty({
    description: 'True if this is a newly created account',
    example: false,
  })
  isNewUser: boolean;
}

export class LogoutResponseDto {
  @ApiProperty({ example: 'Logged out successfully' })
  message: string;
}
