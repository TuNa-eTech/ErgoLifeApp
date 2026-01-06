import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsInt,
  IsNumber,
  IsBoolean,
  IsArray,
  Min,
  Max,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

// ===========================================
// CREATE/UPDATE DTOs
// ===========================================

export class CreateCustomTaskDto {
  @ApiProperty({ example: 'Vacuum Lunges' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  exerciseName: string;

  @ApiPropertyOptional({ example: 'Vacuuming the living room' })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  taskDescription?: string;

  @ApiProperty({ example: 20 })
  @IsInt()
  @Min(1)
  @Max(180)
  durationMinutes: number;

  @ApiPropertyOptional({ example: 3.5 })
  @IsNumber()
  @IsOptional()
  @Min(1.0)
  @Max(20.0)
  metsValue?: number;

  @ApiPropertyOptional({ example: 'cleaning_services' })
  @IsString()
  @IsOptional()
  @MaxLength(50)
  icon?: string;

  @ApiPropertyOptional({ example: 'vacuuming.json' })
  @IsString()
  @IsOptional()
  animation?: string;

  @ApiPropertyOptional({ example: '#9C27B0' })
  @IsString()
  @IsOptional()
  color?: string;

  @ApiPropertyOptional({ description: 'Template ID if seeding from template' })
  @IsString()
  @IsOptional()
  templateId?: string;
}

export class UpdateCustomTaskDto {
  @ApiPropertyOptional({ example: 'Vacuum Lunges' })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  exerciseName?: string;

  @ApiPropertyOptional({ example: 'Vacuuming the living room' })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  taskDescription?: string;

  @ApiPropertyOptional({ example: 20 })
  @IsInt()
  @IsOptional()
  @Min(1)
  @Max(180)
  durationMinutes?: number;

  @ApiPropertyOptional({ example: 3.5 })
  @IsNumber()
  @IsOptional()
  @Min(1.0)
  @Max(20.0)
  metsValue?: number;

  @ApiPropertyOptional({ example: 'cleaning_services' })
  @IsString()
  @IsOptional()
  @MaxLength(50)
  icon?: string;

  @ApiPropertyOptional({ example: 'vacuuming.json' })
  @IsString()
  @IsOptional()
  animation?: string;

  @ApiPropertyOptional({ example: '#9C27B0' })
  @IsString()
  @IsOptional()
  color?: string;

  @ApiPropertyOptional({ example: false })
  @IsBoolean()
  @IsOptional()
  isHidden?: boolean;

  @ApiPropertyOptional({ example: false })
  @IsBoolean()
  @IsOptional()
  isFavorite?: boolean;
}

// ===========================================
// SEED DTOs
// ===========================================

export class SeedTaskDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  exerciseName: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  taskDescription?: string;

  @ApiProperty()
  @IsInt()
  @Min(1)
  durationMinutes: number;

  @ApiProperty()
  @IsNumber()
  metsValue: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  icon?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  animation?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  color?: string;

  @ApiProperty()
  @IsString()
  templateId: string;
}

export class SeedTasksDto {
  @ApiProperty({ type: [SeedTaskDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SeedTaskDto)
  tasks: SeedTaskDto[];
}

// ===========================================
// REORDER DTOs
// ===========================================

export class ReorderTaskItemDto {
  @ApiProperty()
  @IsString()
  id: string;

  @ApiProperty()
  @IsInt()
  @Min(0)
  sortOrder: number;
}

export class ReorderTasksDto {
  @ApiProperty({ type: [ReorderTaskItemDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ReorderTaskItemDto)
  tasks: ReorderTaskItemDto[];
}

// ===========================================
// RESPONSE DTOs
// ===========================================

export class CustomTaskResponseDto {
  @ApiProperty()
  id: string;

  @ApiPropertyOptional()
  templateId?: string;

  @ApiProperty()
  exerciseName: string;

  @ApiPropertyOptional()
  taskDescription?: string;

  @ApiProperty()
  durationMinutes: number;

  @ApiProperty()
  metsValue: number;

  @ApiProperty()
  icon: string;

  @ApiPropertyOptional()
  animation?: string;

  @ApiProperty()
  color: string;

  @ApiProperty()
  sortOrder: number;

  @ApiProperty()
  isHidden: boolean;

  @ApiProperty()
  isFavorite: boolean;

  @ApiProperty()
  createdAt: Date;
}

export class GetCustomTasksResponseDto {
  @ApiProperty({ type: [CustomTaskResponseDto] })
  tasks: CustomTaskResponseDto[];

  @ApiProperty()
  total: number;
}

export class SeedResultDto {
  @ApiProperty()
  seeded: boolean;

  @ApiProperty()
  tasksCreated: number;
}
