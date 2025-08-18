export class CreateBookDto {
  title: string;
  author: string;
  description?: string;
  isbn: string;
  available?: boolean;
}
