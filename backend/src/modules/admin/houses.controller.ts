import {
  Controller,
  Get,
  Put,
  Delete,
  Param,
  Query,
  Body,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
  ApiQuery,
} from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { AdminHousesService } from './houses.service';

@ApiTags('Admin Houses')
@ApiBearerAuth()
@UseGuards(AuthGuard('admin-jwt'))
@Controller('admin/houses')
export class AdminHousesController {
  constructor(private readonly housesService: AdminHousesService) {}

  @Get()
  @ApiOperation({ summary: 'List all houses' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'search', required: false, type: String })
  findAll(
    @Query('page') page = 1,
    @Query('limit') limit = 20,
    @Query('search') search?: string,
  ) {
    return this.housesService.findAll(Number(page), Number(limit), search);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get house details' })
  findOne(@Param('id') id: string) {
    return this.housesService.findOne(id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update house' })
  update(
    @Param('id') id: string,
    @Body() dto: { name?: string },
  ) {
    return this.housesService.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete house' })
  remove(@Param('id') id: string) {
    return this.housesService.remove(id);
  }
}
