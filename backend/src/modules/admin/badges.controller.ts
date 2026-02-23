import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { AdminBadgesService } from './badges.service';

class BadgeTranslationDto {
  locale: string;
  name: string;
  description?: string;
}

class CreateBadgeDto {
  code: string;
  category: string;
  icon: string;
  color?: string;
  sortOrder?: number;
  conditionType: string;
  conditionValue: number;
  rarity?: string;
  translations: BadgeTranslationDto[];
}

class UpdateBadgeDto {
  category?: string;
  icon?: string;
  color?: string;
  sortOrder?: number;
  conditionType?: string;
  conditionValue?: number;
  rarity?: string;
  isActive?: boolean;
  translations?: BadgeTranslationDto[];
}

@ApiTags('Admin Badges')
@ApiBearerAuth()
@UseGuards(AuthGuard('admin-jwt'))
@Controller('admin/badges')
export class AdminBadgesController {
  constructor(
    private readonly badgesService: AdminBadgesService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List all badge definitions' })
  findAll() {
    return this.badgesService.findAll();
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get badge unlock statistics' })
  getStats() {
    return this.badgesService.getStats();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get badge by ID' })
  findOne(@Param('id') id: string) {
    return this.badgesService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a badge definition' })
  create(@Body() dto: CreateBadgeDto) {
    return this.badgesService.create(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a badge definition' })
  update(@Param('id') id: string, @Body() dto: UpdateBadgeDto) {
    return this.badgesService.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a badge definition' })
  remove(@Param('id') id: string) {
    return this.badgesService.remove(id);
  }
}
