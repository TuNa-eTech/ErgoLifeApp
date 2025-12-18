import { Controller, Post, Body, Get, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { SocialLoginDto, AuthResponseDto, UserDto } from './dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import { JwtPayload } from './auth.service';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('social-login')
  @ApiOperation({
    summary: 'Social Login with Firebase',
    description:
      'Authenticate user with Firebase ID Token from Google/Apple Sign-In. Returns JWT access token.',
  })
  @ApiResponse({
    status: 200,
    description: 'Login successful',
    type: AuthResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Invalid ID token' })
  async socialLogin(
    @Body() socialLoginDto: SocialLoginDto,
  ): Promise<AuthResponseDto> {
    return this.authService.socialLogin(socialLoginDto.idToken);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Get current user',
    description: 'Get authenticated user information. Requires JWT token.',
  })
  @ApiResponse({
    status: 200,
    description: 'User information',
    type: UserDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMe(@CurrentUser() user: JwtPayload): Promise<UserDto> {
    return this.authService.getMe(user.sub);
  }
}
