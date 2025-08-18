// src/books/dto/create-book.dto.ts
import { IsString, IsNotEmpty, IsOptional, IsBoolean } from 'class-validator';

export class CreateBookDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  author: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsNotEmpty()
  isbn: string;

  @IsBoolean()
  @IsOptional()
  available?: boolean;
}
