import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { RewardsService } from './rewards.service';
import {
  CreateRewardDto,
  UpdateRewardDto,
  GetRewardsQueryDto,
  GetRewardsResponseDto,
  RewardDto,
  DeleteRewardResponseDto,
  RedeemRewardResponseDto,
} from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';

@ApiTags('rewards')
@Controller('rewards')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class RewardsController {
  constructor(private readonly rewardsService: RewardsService) {}

  @Get()
  @ApiOperation({
    summary: 'List rewards',
    description: 'Get all rewards in the house shop',
  })
  @ApiResponse({
    status: 200,
    description: 'List of rewards',
    type: GetRewardsResponseDto,
  })
  async findAll(
    @CurrentUser() user: JwtPayload,
    @Query() query: GetRewardsQueryDto,
  ): Promise<GetRewardsResponseDto> {
    return this.rewardsService.findAll(user.sub, query);
  }

  @Post()
  @ApiOperation({
    summary: 'Create reward',
    description: 'Create a new reward in the house shop',
  })
  @ApiResponse({
    status: 201,
    description: 'Reward created successfully',
    type: RewardDto,
  })
  async create(
    @CurrentUser() user: JwtPayload,
    @Body() createRewardDto: CreateRewardDto,
  ): Promise<RewardDto> {
    return this.rewardsService.create(user.sub, createRewardDto);
  }

  @Put(':id')
  @ApiOperation({
    summary: 'Update reward',
    description: 'Update a reward (only creator or house owner)',
  })
  @ApiResponse({
    status: 200,
    description: 'Reward updated successfully',
    type: RewardDto,
  })
  @ApiResponse({ status: 403, description: 'Not authorized' })
  @ApiResponse({ status: 404, description: 'Reward not found' })
  async update(
    @CurrentUser() user: JwtPayload,
    @Param('id') id: string,
    @Body() updateRewardDto: UpdateRewardDto,
  ): Promise<RewardDto> {
    return this.rewardsService.update(user.sub, id, updateRewardDto);
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Delete reward',
    description: 'Soft delete a reward (only creator or house owner)',
  })
  @ApiResponse({
    status: 200,
    description: 'Reward deleted successfully',
    type: DeleteRewardResponseDto,
  })
  @ApiResponse({ status: 403, description: 'Not authorized' })
  @ApiResponse({ status: 404, description: 'Reward not found' })
  async remove(
    @CurrentUser() user: JwtPayload,
    @Param('id') id: string,
  ): Promise<DeleteRewardResponseDto> {
    return this.rewardsService.remove(user.sub, id);
  }

  @Post(':id/redeem')
  @ApiOperation({
    summary: 'Redeem reward',
    description: 'Exchange points for a reward',
  })
  @ApiResponse({
    status: 200,
    description: 'Reward redeemed successfully',
    type: RedeemRewardResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Insufficient balance' })
  @ApiResponse({ status: 404, description: 'Reward not found' })
  async redeem(
    @CurrentUser() user: JwtPayload,
    @Param('id') id: string,
  ): Promise<RedeemRewardResponseDto> {
    return this.rewardsService.redeem(user.sub, id);
  }
}
