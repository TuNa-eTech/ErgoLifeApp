import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateTaskTemplateWithTranslationsDto,
  UpdateTaskTemplateDto,
  CreateTranslationDto,
  TaskTemplateResponseDto,
  TaskTemplateLocalizedResponseDto,
  GetTaskTemplatesResponseDto,
} from './dto';

@Injectable()
export class TaskTemplatesService {
  constructor(private prisma: PrismaService) {}

  /**
   * Create a new task template with translations
   */
  async create(
    dto: CreateTaskTemplateWithTranslationsDto,
  ): Promise<TaskTemplateResponseDto> {
    const template = await this.prisma.taskTemplate.create({
      data: {
        metsValue: dto.metsValue,
        defaultDuration: dto.defaultDuration,
        icon: dto.icon ?? 'fitness_center',
        animation: dto.animation,
        color: dto.color ?? '#FF6A00',
        category: dto.category ?? 'general',
        sortOrder: dto.sortOrder ?? 0,
        translations: {
          create: dto.translations.map((t) => ({
            locale: t.locale,
            name: t.name,
            description: t.description,
          })),
        },
      },
      include: { translations: true },
    });

    return this.mapToResponse(template);
  }

  /**
   * Get all active templates with localized content
   */
  async findAll(locale: string = 'en'): Promise<GetTaskTemplatesResponseDto> {
    const templates = await this.prisma.taskTemplate.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
      include: {
        translations: {
          where: { locale },
        },
      },
    });

    // Fallback to English if translation not found
    const localizedTemplates: TaskTemplateLocalizedResponseDto[] = [];

    for (const template of templates) {
      let translation = template.translations[0];

      // Fallback to English
      if (!translation && locale !== 'en') {
        const englishTranslation =
          await this.prisma.taskTemplateTranslation.findFirst({
            where: { templateId: template.id, locale: 'en' },
          });
        translation = englishTranslation ?? undefined;
      }

      if (translation) {
        localizedTemplates.push({
          id: template.id,
          name: translation.name,
          description: translation.description ?? undefined,
          metsValue: template.metsValue,
          defaultDuration: template.defaultDuration,
          icon: template.icon,
          animation: template.animation ?? undefined,
          color: template.color,
          category: template.category,
        });
      }
    }

    return {
      templates: localizedTemplates,
      total: localizedTemplates.length,
    };
  }

  /**
   * Get a single template by ID (admin view with all translations)
   */
  async findOne(id: string): Promise<TaskTemplateResponseDto> {
    const template = await this.prisma.taskTemplate.findUnique({
      where: { id },
      include: { translations: true },
    });

    if (!template) {
      throw new NotFoundException('Task template not found');
    }

    return this.mapToResponse(template);
  }

  /**
   * Update a template
   */
  async update(
    id: string,
    dto: UpdateTaskTemplateDto,
  ): Promise<TaskTemplateResponseDto> {
    const template = await this.prisma.taskTemplate.update({
      where: { id },
      data: {
        metsValue: dto.metsValue,
        defaultDuration: dto.defaultDuration,
        icon: dto.icon,
        animation: dto.animation,
        color: dto.color,
        category: dto.category,
        sortOrder: dto.sortOrder,
        isActive: dto.isActive,
      },
      include: { translations: true },
    });

    return this.mapToResponse(template);
  }

  /**
   * Add or update a translation
   */
  async upsertTranslation(
    templateId: string,
    dto: CreateTranslationDto,
  ): Promise<TaskTemplateResponseDto> {
    await this.prisma.taskTemplateTranslation.upsert({
      where: {
        templateId_locale: {
          templateId,
          locale: dto.locale,
        },
      },
      create: {
        templateId,
        locale: dto.locale,
        name: dto.name,
        description: dto.description,
      },
      update: {
        name: dto.name,
        description: dto.description,
      },
    });

    return this.findOne(templateId);
  }

  /**
   * Soft delete a template
   */
  async remove(id: string): Promise<void> {
    await this.prisma.taskTemplate.update({
      where: { id },
      data: { isActive: false },
    });
  }

  /**
   * Map database model to response DTO
   */
  private mapToResponse(template: {
    id: string;
    metsValue: number;
    defaultDuration: number;
    icon: string;
    animation: string | null;
    color: string;
    category: string;
    sortOrder: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
    translations: {
      locale: string;
      name: string;
      description: string | null;
    }[];
  }): TaskTemplateResponseDto {
    return {
      id: template.id,
      metsValue: template.metsValue,
      defaultDuration: template.defaultDuration,
      icon: template.icon,
      animation: template.animation ?? undefined,
      color: template.color,
      category: template.category,
      sortOrder: template.sortOrder,
      isActive: template.isActive,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
      translations: template.translations.map((t) => ({
        locale: t.locale,
        name: t.name,
        description: t.description ?? undefined,
      })),
    };
  }
}
