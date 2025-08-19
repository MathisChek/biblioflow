import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { Book } from './entities/book.entity';
import { CreateBookDto } from './dto/create-book.dto';
import { UpdateBookDto } from './dto/update-book.dto';

@Injectable()
export class BooksService {
  constructor(
    @InjectRepository(Book) private readonly repo: Repository<Book>,
  ) {}

  create(dto: CreateBookDto) {
    const entity = this.repo.create({
      ...dto,
      available: dto.available ?? true,
    });
    return this.repo.save(entity);
  }

  findAll(q?: string) {
    if (q?.trim()) {
      return this.repo.find({
        where: [
          { title: ILike(`%${q}%`) },
          { author: ILike(`%${q}%`) },
          { isbn: ILike(`%${q}%`) },
        ],
        order: { id: 'ASC' },
      });
    }
    return this.repo.find({ order: { id: 'ASC' } });
  }

  async findOne(id: number) {
    const book = await this.repo.findOne({ where: { id } });
    if (!book) throw new NotFoundException(`Book ${id} not found`);
    return book;
  }

  async update(id: number, dto: UpdateBookDto) {
    const book = await this.findOne(id);
    Object.assign(book, dto);
    return this.repo.save(book);
  }

  async remove(id: number) {
    const book = await this.findOne(id);
    await this.repo.remove(book);
  }
}
