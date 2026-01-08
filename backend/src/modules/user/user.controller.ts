import {
  Controller,
  Get,
  Put,
  Body,
  Param,
  UseGuards,
  ForbiddenException,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
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
@ApiBearerAuth('JWT-auth')
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
    return this.userService.updateFcmToken(
      user.sub,
      updateFcmTokenDto.fcmToken,
    );
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
  @ApiResponse({
    status: 403,
    description: 'You can only view users in your house',
  })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getUserById(
    @CurrentUser() currentUser: JwtPayload,
    @Param('id') targetUserId: string,
  ): Promise<OtherUserDto> {
    return this.userService.getUserById(currentUser.sub, targetUserId);
  }

  @Put('purchase-streak-freeze')
  @ApiOperation({
    summary: 'Purchase Streak Freeze',
    description:
      'Buy a Streak Freeze for 500 ErgoPoints to protect streak for one missed day (max 2)',
  })
  @ApiResponse({
    status: 200,
    description: 'Streak Freeze purchased successfully',
    schema: {
      example: {
        message: 'Streak Freeze purchased successfully',
        walletBalance: 2000,
        streakFreezeCount: 1,
      },
    },
  })
  @ApiResponse({
    status: 403,
    description: 'Max Streak Freezes reached or insufficient points',
    schema: {
      examples: {
        maxReached: {
          value: {
            statusCode: 403,
            error: 'Forbidden',
            code: 'MAX_FREEZE_REACHED',
            message:
              'You already have the maximum number of Streak Freezes (2)',
          },
        },
        insufficientPoints: {
          value: {
            statusCode: 403,
            error: 'Forbidden',
            code: 'INSUFFICIENT_POINTS',
            message:
              'You need 500 EP to purchase a Streak Freeze. Current balance: 300 EP',
          },
        },
      },
    },
  })
  async purchaseStreakFreeze(@CurrentUser() user: JwtPayload): Promise<{
    message: string;
    walletBalance: number;
    streakFreezeCount: number;
  }> {
    return this.userService.purchaseStreakFreeze(user.sub);
  }
}
