import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { GiftsService } from './gifts.service';
import {
  SendGiftDto,
  GetGiftHistoryQueryDto,
  GetGiftCatalogQueryDto,
  GiftCatalogResponseDto,
  SendGiftResponseDto,
  GiftHistoryResponseDto,
} from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';

@ApiTags('gifts')
@Controller('gifts')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class GiftsController {
  constructor(private readonly giftsService: GiftsService) {}

  @Get('catalog')
  @ApiOperation({
    summary: 'Get gift catalog',
    description:
      'Fetch all available gift rewards with user balance and house members',
  })
  @ApiResponse({
    status: 200,
    description: 'Gift catalog with rewards, balance, and house members',
    type: GiftCatalogResponseDto,
  })
  async getCatalog(
    @CurrentUser() user: JwtPayload,
    @Query() query: GetGiftCatalogQueryDto,
  ): Promise<GiftCatalogResponseDto> {
    return this.giftsService.getCatalog(user.sub, query);
  }

  @Post('send')
  @ApiOperation({
    summary: 'Send a gift',
    description:
      'Send a symbolic gift to a house member (deducts EP from sender)',
  })
  @ApiResponse({
    status: 201,
    description: 'Gift sent successfully',
    type: SendGiftResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Insufficient balance or invalid request',
  })
  @ApiResponse({
    status: 404,
    description: 'Receiver or gift reward not found',
  })
  async sendGift(
    @CurrentUser() user: JwtPayload,
    @Body() sendGiftDto: SendGiftDto,
  ): Promise<SendGiftResponseDto> {
    return this.giftsService.sendGift(user.sub, sendGiftDto);
  }

  @Get('history')
  @ApiOperation({
    summary: 'Get gift history',
    description:
      'Paginated list of sent and/or received gifts',
  })
  @ApiResponse({
    status: 200,
    description: 'Gift history',
    type: GiftHistoryResponseDto,
  })
  async getHistory(
    @CurrentUser() user: JwtPayload,
    @Query() query: GetGiftHistoryQueryDto,
  ): Promise<GiftHistoryResponseDto> {
    return this.giftsService.getHistory(user.sub, query);
  }
}
