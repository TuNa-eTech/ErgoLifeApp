import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SocialLoginDto {
  @ApiProperty({
    description: 'Firebase ID Token from Google/Apple Sign-In',
    example: 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  @IsString()
  @IsNotEmpty()
  idToken: string;
}
