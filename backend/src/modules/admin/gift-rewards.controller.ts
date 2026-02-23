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
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { AdminGiftRewardsService } from './gift-rewards.service';

class GiftRewardTranslationDto {
  locale: string;
  name: string;
  description?: string;
}

class CreateGiftRewardDto {
  key: string;
  category: string;
  icon: string;
  cost: number;
  sortOrder?: number;
  translations: GiftRewardTranslationDto[];
}

class UpdateGiftRewardDto {
  category?: string;
  icon?: string;
  cost?: number;
  sortOrder?: number;
  isActive?: boolean;
  translations?: GiftRewardTranslationDto[];
}

@ApiTags('Admin Gift Rewards')
@ApiBearerAuth()
@UseGuards(AuthGuard('admin-jwt'))
@Controller('admin/gift-rewards')
export class AdminGiftRewardsController {
  constructor(
    private readonly giftRewardsService: AdminGiftRewardsService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List all gift rewards' })
  findAll() {
    return this.giftRewardsService.findAll();
  }

  @Get('transactions')
  @ApiOperation({ summary: 'List gift transactions' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  getTransactions(
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    return this.giftRewardsService.getTransactions(
      Number(page),
      Number(limit),
    );
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get gift reward by ID' })
  findOne(@Param('id') id: string) {
    return this.giftRewardsService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a gift reward' })
  create(@Body() dto: CreateGiftRewardDto) {
    return this.giftRewardsService.create(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a gift reward' })
  update(
    @Param('id') id: string,
    @Body() dto: UpdateGiftRewardDto,
  ) {
    return this.giftRewardsService.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a gift reward' })
  remove(@Param('id') id: string) {
    return this.giftRewardsService.remove(id);
  }
}
