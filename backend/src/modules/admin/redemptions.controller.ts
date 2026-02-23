import {
  Controller,
  Get,
  Put,
  Param,
  Body,
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
import { AdminRedemptionsService } from './redemptions.service';

class UpdateRedemptionStatusDto {
  status: string;
}

@ApiTags('Admin Redemptions')
@ApiBearerAuth()
@UseGuards(AuthGuard('admin-jwt'))
@Controller('admin/redemptions')
export class AdminRedemptionsController {
  constructor(
    private readonly redemptionsService: AdminRedemptionsService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List all redemptions' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, type: String })
  @ApiQuery({ name: 'userId', required: false, type: String })
  findAll(
    @Query('page') page = 1,
    @Query('limit') limit = 20,
    @Query('status') status?: string,
    @Query('userId') userId?: string,
  ) {
    return this.redemptionsService.findAll(
      Number(page),
      Number(limit),
      status,
      userId,
    );
  }

  @Put(':id/status')
  @ApiOperation({ summary: 'Update redemption status' })
  updateStatus(
    @Param('id') id: string,
    @Body() dto: UpdateRedemptionStatusDto,
  ) {
    return this.redemptionsService.updateStatus(id, dto.status);
  }
}
