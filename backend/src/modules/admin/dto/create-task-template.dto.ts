import { IsString, IsNumber, IsOptional, IsBoolean, IsArray, ValidateNested, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class TaskTemplateTranslationDto {
  @ApiProperty()
  @IsString()
  locale: string;

  @ApiProperty()
  @IsString()
  name: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  description?: string;
}

export class CreateTaskTemplateDto {
  @ApiProperty()
  @IsNumber()
  @Min(0)
  metsValue: number;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  defaultDuration: number;

  @ApiProperty({ default: 'fitness_center' })
  @IsString()
  icon: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  animation?: string;

  @ApiProperty({ default: '#FF6A00' })
  @IsString()
  color: string;

  @ApiProperty({ default: 'general' })
  @IsString()
  category: string;

  @ApiProperty({ default: 0 })
  @IsOptional()
  @IsNumber()
  sortOrder?: number;

  @ApiProperty({ default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiProperty({ type: [TaskTemplateTranslationDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TaskTemplateTranslationDto)
  translations: TaskTemplateTranslationDto[];
}
