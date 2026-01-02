import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { HousesService } from './houses.service';
import {
  CreateHouseDto,
  JoinHouseDto,
  HouseDto,
  InviteDto,
  HousePreviewDto,
  LeaveHouseResponseDto,
} from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';

@ApiTags('houses')
@Controller('houses')
export class HousesController {
  constructor(private readonly housesService: HousesService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Create a new house',
    description: 'Create a new household. User becomes the first member and owner.',
  })
  @ApiResponse({
    status: 201,
    description: 'House created successfully',
    type: HouseDto,
  })
  @ApiResponse({ status: 409, description: 'Already in another house' })
  async create(
    @CurrentUser() user: JwtPayload,
    @Body() createHouseDto: CreateHouseDto,
  ): Promise<HouseDto> {
    return this.housesService.create(user.sub, createHouseDto);
  }

  @Get('mine')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get current house',
    description: 'Get information about the current user\'s house',
  })
  @ApiResponse({
    status: 200,
    description: 'House information',
    type: HouseDto,
  })
  @ApiResponse({ status: 404, description: 'Not a member of any house' })
  async getMyHouse(@CurrentUser() user: JwtPayload): Promise<HouseDto> {
    return this.housesService.getMyHouse(user.sub);
  }

  @Get('invite')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get invite info',
    description: 'Get invite code and deep link for current house',
  })
  @ApiResponse({
    status: 200,
    description: 'Invite information',
    type: InviteDto,
  })
  @ApiResponse({ status: 404, description: 'Not a member of any house' })
  async getInvite(@CurrentUser() user: JwtPayload): Promise<InviteDto> {
    return this.housesService.getInvite(user.sub);
  }

  @Post('join')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Join a house',
    description: 'Join an existing house using invite code',
  })
  @ApiResponse({
    status: 200,
    description: 'Successfully joined the house',
    type: HouseDto,
  })
  @ApiResponse({ status: 404, description: 'Invalid invite code' })
  @ApiResponse({ status: 409, description: 'Already in house / House full' })
  async join(
    @CurrentUser() user: JwtPayload,
    @Body() joinHouseDto: JoinHouseDto,
  ): Promise<HouseDto> {
    return this.housesService.join(user.sub, joinHouseDto.inviteCode);
  }

  @Post('leave')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Leave current house',
    description: 'Leave the current house. Wallet balance will be reset to 0.',
  })
  @ApiResponse({
    status: 200,
    description: 'Successfully left the house',
    type: LeaveHouseResponseDto,
  })
  @ApiResponse({ status: 404, description: 'Not a member of any house' })
  async leave(@CurrentUser() user: JwtPayload): Promise<LeaveHouseResponseDto> {
    return this.housesService.leave(user.sub);
  }

  @Get(':code/preview')
  @ApiOperation({
    summary: 'Preview house (public)',
    description: 'Preview house information before joining. No authentication required.',
  })
  @ApiResponse({
    status: 200,
    description: 'House preview information',
    type: HousePreviewDto,
  })
  @ApiResponse({ status: 404, description: 'Invalid invite code' })
  async preview(@Param('code') code: string): Promise<HousePreviewDto> {
    return this.housesService.preview(code);
  }
}
