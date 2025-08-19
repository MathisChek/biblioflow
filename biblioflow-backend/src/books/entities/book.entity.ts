import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('books')
export class Book {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'uuid', generated: 'uuid', unique: true })
  uuid: string;

  @Column({ length: 255 })
  title: string;

  @Column({ length: 255 })
  author: string;

  @Column({ length: 20, unique: true, nullable: true })
  isbn?: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ length: 100, nullable: true })
  category?: string;

  @Column({ type: 'integer', nullable: true, name: 'publication_year' })
  publicationYear?: number;

  @Column({ length: 255, nullable: true })
  publisher?: string;

  @Column({ length: 50, default: 'fr' })
  language: string;

  @Column({ type: 'integer', nullable: true })
  pages?: number;

  @Column({ default: true })
  available: boolean;

  @Column({ length: 100, nullable: true })
  location?: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;
}
