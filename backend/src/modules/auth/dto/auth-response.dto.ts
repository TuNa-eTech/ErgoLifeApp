import { ApiProperty } from '@nestjs/swagger';

export class UserDto {
  @ApiProperty({ example: 'uuid-string' })
  id: string;

  @ApiProperty({ example: 'firebase-uid-string' })
  firebaseUid: string;

  @ApiProperty({ example: 'GOOGLE', enum: ['GOOGLE', 'APPLE'] })
  provider: string;

  @ApiProperty({ example: 'user@example.com', nullable: true })
  email: string | null;

  @ApiProperty({ example: 'John Doe', nullable: true })
  name: string | null;

  @ApiProperty({ example: 1, nullable: true })
  avatarId: number | null;

  @ApiProperty({ example: 'https://example.com/avatar.jpg', nullable: true })
  avatarUrl: string | null;
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
}
