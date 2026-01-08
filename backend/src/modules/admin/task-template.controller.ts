import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { TaskTemplateService } from './task-template.service';
import { CreateTaskTemplateDto } from './dto/create-task-template.dto';
import { UpdateTaskTemplateDto } from './dto/update-task-template.dto';

@ApiTags('Admin Task Templates')
@ApiBearerAuth()
@UseGuards(AuthGuard('admin-jwt'))
@Controller('admin/task-templates')
export class TaskTemplateController {
  constructor(private readonly service: TaskTemplateService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new task template' })
  create(@Body() createDto: CreateTaskTemplateDto) {
    return this.service.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'List all task templates' })
  findAll(@Query('isActive') isActive?: string) {
    const activeFilter = isActive === 'true' ? true : isActive === 'false' ? false : undefined;
    return this.service.findAll({ isActive: activeFilter });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a task template by ID' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a task template' })
  update(@Param('id') id: string, @Body() updateDto: UpdateTaskTemplateDto) {
    return this.service.update(id, updateDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a task template' })
  delete(@Param('id') id: string) {
    return this.service.delete(id);
  }
}
