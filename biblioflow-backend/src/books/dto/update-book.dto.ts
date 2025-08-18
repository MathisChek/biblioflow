// src/books/dto/update-book.dto.ts
import { IsString, IsOptional, IsBoolean } from 'class-validator';

export class UpdateBookDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsString()
  @IsOptional()
  author?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  isbn?: string;

  @IsBoolean()
  @IsOptional()
  available?: boolean;
}
