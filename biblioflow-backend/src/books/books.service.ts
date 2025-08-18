import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateBookDto } from './dto/create-book.dto';
import { UpdateBookDto } from './dto/update-book.dto';

export interface Book {
  id: number;
  title: string;
  author: string;
  description?: string;
  isbn: string;
  available: boolean;
  createdAt: Date;
  updatedAt: Date;
}

@Injectable()
export class BooksService {
  private books: Book[] = [
    {
      id: 1,
      title: 'Le Seigneur des Anneaux',
      author: 'J.R.R. Tolkien',
      description: 'Un classique de la fantasy',
      isbn: '978-0547928227',
      available: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];
  private nextId = 2;

  create(createBookDto: CreateBookDto): Book {
    const book: Book = {
      id: this.nextId++,
      ...createBookDto,
      available: createBookDto.available ?? true,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    this.books.push(book);
    return book;
  }

  findAll(): Book[] {
    return this.books;
  }

  findOne(id: number): Book {
    const book = this.books.find((b) => b.id === id);
    if (!book) {
      throw new NotFoundException(`Book with ID ${id} not found`);
    }
    return book;
  }

  update(id: number, updateBookDto: UpdateBookDto): Book {
    const bookIndex = this.books.findIndex((b) => b.id === id);
    if (bookIndex === -1) {
      throw new NotFoundException(`Book with ID ${id} not found`);
    }

    this.books[bookIndex] = {
      ...this.books[bookIndex],
      ...updateBookDto,
      updatedAt: new Date(),
    };

    return this.books[bookIndex];
  }

  remove(id: number): void {
    const bookIndex = this.books.findIndex((b) => b.id === id);
    if (bookIndex === -1) {
      throw new NotFoundException(`Book with ID ${id} not found`);
    }

    this.books.splice(bookIndex, 1);
  }
}
