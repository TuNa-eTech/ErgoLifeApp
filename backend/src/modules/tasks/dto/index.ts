import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsInt,
  IsNumber,
  Min,
  Max,
  MaxLength,
} from 'class-validator';

export class CreateCustomTaskDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  exerciseName: string;

  @IsString()
  @IsOptional()
  @MaxLength(255)
  taskDescription?: string;

  @IsInt()
  @Min(1)
  @Max(120)
  durationMinutes: number;

  @IsNumber()
  @IsOptional()
  @Min(1.0)
  @Max(10.0)
  metsValue?: number;

  @IsString()
  @IsOptional()
  @MaxLength(50)
  icon?: string;
}

export class CustomTaskResponseDto {
  id: string;
  exerciseName: string;
  taskDescription: string | null;
  durationMinutes: number;
  metsValue: number;
  icon: string;
  isFavorite: boolean;
  createdAt: Date;
}

export class GetCustomTasksResponseDto {
  tasks: CustomTaskResponseDto[];
  total: number;
}
