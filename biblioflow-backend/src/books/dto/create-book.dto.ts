import {
  IsBoolean,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsNumber,
  Length,
  IsIn,
} from 'class-validator';

export class CreateBookDto {
  @IsString()
  @IsNotEmpty()
  @Length(1, 255)
  title: string;

  @IsString()
  @IsNotEmpty()
  @Length(1, 255)
  author: string;

  @IsString()
  @IsOptional()
  @Length(1, 20)
  isbn?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  @Length(1, 100)
  category?: string;

  @IsNumber()
  @IsOptional()
  publicationYear?: number;

  @IsString()
  @IsOptional()
  @Length(1, 255)
  publisher?: string;

  @IsString()
  @IsOptional()
  @IsIn(['fr', 'en', 'es', 'de', 'it'])
  language?: string;

  @IsNumber()
  @IsOptional()
  pages?: number;

  @IsBoolean()
  @IsOptional()
  available?: boolean;

  @IsString()
  @IsOptional()
  @Length(1, 100)
  location?: string;
}
