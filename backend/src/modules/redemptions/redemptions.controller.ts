import { Controller, Get, Put, Param, Query, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { RedemptionsService } from './redemptions.service';
import {
  GetRedemptionsQueryDto,
  GetRedemptionsResponseDto,
  UseRedemptionResponseDto,
} from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';

@ApiTags('redemptions')
@Controller('redemptions')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class RedemptionsController {
  constructor(private readonly redemptionsService: RedemptionsService) {}

  @Get()
  @ApiOperation({
    summary: 'Get redemption history',
    description: 'Get paginated redemption history for current user',
  })
  @ApiResponse({
    status: 200,
    description: 'Redemption history',
    type: GetRedemptionsResponseDto,
  })
  async findAll(
    @CurrentUser() user: JwtPayload,
    @Query() query: GetRedemptionsQueryDto,
  ): Promise<GetRedemptionsResponseDto> {
    return this.redemptionsService.findAll(user.sub, query);
  }

  @Put(':id/use')
  @ApiOperation({
    summary: 'Mark as used',
    description: 'Mark a redemption as used (any house member can do this)',
  })
  @ApiResponse({
    status: 200,
    description: 'Redemption marked as used',
    type: UseRedemptionResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Already used' })
  @ApiResponse({ status: 403, description: 'Not in the same house' })
  @ApiResponse({ status: 404, description: 'Redemption not found' })
  async markAsUsed(
    @CurrentUser() user: JwtPayload,
    @Param('id') id: string,
  ): Promise<UseRedemptionResponseDto> {
    return this.redemptionsService.markAsUsed(user.sub, id);
  }
}
