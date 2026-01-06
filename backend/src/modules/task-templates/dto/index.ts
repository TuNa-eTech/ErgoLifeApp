import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNumber,
  IsOptional,
  IsBoolean,
  Min,
  Max,
} from 'class-validator';

// ===========================================
// REQUEST DTOs
// ===========================================

export class CreateTaskTemplateDto {
  @ApiProperty({ example: 3.5, description: 'MET value for calorie calculation' })
  @IsNumber()
  @Min(1)
  @Max(20)
  metsValue: number;

  @ApiProperty({ example: 20, description: 'Default duration in minutes' })
  @IsNumber()
  @Min(1)
  @Max(180)
  defaultDuration: number;

  @ApiPropertyOptional({ example: 'cleaning_services' })
  @IsOptional()
  @IsString()
  icon?: string;

  @ApiPropertyOptional({ example: 'vacuuming.json' })
  @IsOptional()
  @IsString()
  animation?: string;

  @ApiPropertyOptional({ example: '#FF6A00' })
  @IsOptional()
  @IsString()
  color?: string;

  @ApiPropertyOptional({ example: 'cleaning' })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsNumber()
  sortOrder?: number;
}

export class UpdateTaskTemplateDto {
  @ApiPropertyOptional({ example: 3.5 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(20)
  metsValue?: number;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(180)
  defaultDuration?: number;

  @ApiPropertyOptional({ example: 'cleaning_services' })
  @IsOptional()
  @IsString()
  icon?: string;

  @ApiPropertyOptional({ example: 'vacuuming.json' })
  @IsOptional()
  @IsString()
  animation?: string;

  @ApiPropertyOptional({ example: '#FF6A00' })
  @IsOptional()
  @IsString()
  color?: string;

  @ApiPropertyOptional({ example: 'cleaning' })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsNumber()
  sortOrder?: number;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class CreateTranslationDto {
  @ApiProperty({ example: 'en', description: 'Locale code (en, vi, etc.)' })
  @IsString()
  locale: string;

  @ApiProperty({ example: 'Vacuuming' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'Vacuum the floors and carpets' })
  @IsOptional()
  @IsString()
  description?: string;
}

export class CreateTaskTemplateWithTranslationsDto extends CreateTaskTemplateDto {
  @ApiProperty({ type: [CreateTranslationDto] })
  translations: CreateTranslationDto[];
}

// ===========================================
// RESPONSE DTOs
// ===========================================

export class TranslationResponseDto {
  @ApiProperty()
  locale: string;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  description?: string;
}

export class TaskTemplateResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  metsValue: number;

  @ApiProperty()
  defaultDuration: number;

  @ApiProperty()
  icon: string;

  @ApiPropertyOptional()
  animation?: string;

  @ApiProperty()
  color: string;

  @ApiProperty()
  category: string;

  @ApiProperty()
  sortOrder: number;

  @ApiProperty()
  isActive: boolean;

  @ApiProperty({ type: [TranslationResponseDto] })
  translations: TranslationResponseDto[];

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}

export class TaskTemplateLocalizedResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ description: 'Localized name' })
  name: string;

  @ApiPropertyOptional({ description: 'Localized description' })
  description?: string;

  @ApiProperty()
  metsValue: number;

  @ApiProperty()
  defaultDuration: number;

  @ApiProperty()
  icon: string;

  @ApiPropertyOptional()
  animation?: string;

  @ApiProperty()
  color: string;

  @ApiProperty()
  category: string;
}

export class GetTaskTemplatesResponseDto {
  @ApiProperty({ type: [TaskTemplateLocalizedResponseDto] })
  templates: TaskTemplateLocalizedResponseDto[];

  @ApiProperty()
  total: number;
}
