import {
  Controller,
  Get,
  Put,
  Body,
  Param,
  UseGuards,
  ForbiddenException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UserService } from './user.service';
import {
  UpdateProfileDto,
  UpdateFcmTokenDto,
  FcmTokenResponseDto,
  UserProfileDto,
  OtherUserDto,
} from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Put('me')
  @ApiOperation({
    summary: 'Update profile',
    description: 'Update current user profile (displayName, avatarId)',
  })
  @ApiResponse({
    status: 200,
    description: 'Profile updated successfully',
    type: UserProfileDto,
  })
  @ApiResponse({ status: 422, description: 'Validation error' })
  async updateProfile(
    @CurrentUser() user: JwtPayload,
    @Body() updateProfileDto: UpdateProfileDto,
  ): Promise<UserProfileDto> {
    return this.userService.updateProfile(user.sub, updateProfileDto);
  }

  @Put('me/fcm-token')
  @ApiOperation({
    summary: 'Update FCM token',
    description: 'Update Firebase Cloud Messaging token for push notifications',
  })
  @ApiResponse({
    status: 200,
    description: 'FCM token updated successfully',
    type: FcmTokenResponseDto,
  })
  async updateFcmToken(
    @CurrentUser() user: JwtPayload,
    @Body() updateFcmTokenDto: UpdateFcmTokenDto,
  ): Promise<FcmTokenResponseDto> {
    return this.userService.updateFcmToken(user.sub, updateFcmTokenDto.fcmToken);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get user by ID',
    description: 'Get another user information (only users in the same house)',
  })
  @ApiResponse({
    status: 200,
    description: 'User information',
    type: OtherUserDto,
  })
  @ApiResponse({ status: 403, description: 'You can only view users in your house' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getUserById(
    @CurrentUser() currentUser: JwtPayload,
    @Param('id') targetUserId: string,
  ): Promise<OtherUserDto> {
    return this.userService.getUserById(currentUser.sub, targetUserId);
  }
}
