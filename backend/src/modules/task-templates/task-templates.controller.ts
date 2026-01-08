import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiQuery,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { TaskTemplatesService } from './task-templates.service';
import {
  CreateTaskTemplateWithTranslationsDto,
  UpdateTaskTemplateDto,
  CreateTranslationDto,
  TaskTemplateResponseDto,
  GetTaskTemplatesResponseDto,
} from './dto';

@ApiTags('Task Templates')
@Controller('task-templates')
export class TaskTemplatesController {
  constructor(private readonly taskTemplatesService: TaskTemplatesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all active task templates (localized)' })
  @ApiQuery({
    name: 'locale',
    required: false,
    description: 'Locale code (en, vi). Defaults to en',
  })
  async findAll(
    @Query('locale') locale: string = 'en',
  ): Promise<GetTaskTemplatesResponseDto> {
    return this.taskTemplatesService.findAll(locale);
  }

  @Get(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get a task template by ID (admin)' })
  async findOne(@Param('id') id: string): Promise<TaskTemplateResponseDto> {
    return this.taskTemplatesService.findOne(id);
  }

  @Post()
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new task template (admin)' })
  async create(
    @Body() dto: CreateTaskTemplateWithTranslationsDto,
  ): Promise<TaskTemplateResponseDto> {
    return this.taskTemplatesService.create(dto);
  }

  @Patch(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a task template (admin)' })
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateTaskTemplateDto,
  ): Promise<TaskTemplateResponseDto> {
    return this.taskTemplatesService.update(id, dto);
  }

  @Post(':id/translations')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add or update a translation (admin)' })
  async upsertTranslation(
    @Param('id') id: string,
    @Body() dto: CreateTranslationDto,
  ): Promise<TaskTemplateResponseDto> {
    return this.taskTemplatesService.upsertTranslation(id, dto);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Soft delete a task template (admin)' })
  async remove(@Param('id') id: string): Promise<{ success: boolean }> {
    await this.taskTemplatesService.remove(id);
    return { success: true };
  }
}
