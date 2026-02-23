import {
  Controller,
  Delete,
  Get,
  Put,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
  ApiQuery,
} from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { AdminUsersService } from './users.service';

class UpdateUserDto {
  displayName?: string;
  walletBalance?: number;
}

class BanUserDto {
  banned: boolean;
}

@ApiTags('Admin Users')
@ApiBearerAuth()
@UseGuards(AuthGuard('admin-jwt'))
@Controller('admin/users')
export class AdminUsersController {
  constructor(private readonly usersService: AdminUsersService) {}

  @Get()
  @ApiOperation({ summary: 'List all users' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'search', required: false, type: String })
  findAll(
    @Query('page') page = 1,
    @Query('limit') limit = 20,
    @Query('search') search?: string,
  ) {
    return this.usersService.findAll(Number(page), Number(limit), search);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user details' })
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update user details' })
  update(@Param('id') id: string, @Body() dto: UpdateUserDto) {
    return this.usersService.updateUser(id, dto);
  }

  @Put(':id/ban')
  @ApiOperation({ summary: 'Ban or unban a user' })
  toggleBan(@Param('id') id: string, @Body() dto: BanUserDto) {
    return this.usersService.toggleBan(id, dto.banned);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a user and all associated data' })
  remove(@Param('id') id: string) {
    return this.usersService.deleteUser(id);
  }
}
