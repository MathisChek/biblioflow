import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
  Check,
} from 'typeorm';

@Entity('users')
@Check(`"role" IN ('admin', 'librarian', 'user')`)
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'uuid', generated: 'uuid', unique: true })
  uuid: string;

  @Column({ length: 255, unique: true })
  email: string;

  @Column({ length: 255, name: 'password_hash' })
  passwordHash: string;

  @Column({ length: 100, nullable: true, name: 'first_name' })
  firstName?: string;

  @Column({ length: 100, nullable: true, name: 'last_name' })
  lastName?: string;

  @Column({
    length: 50,
    default: 'user',
    type: 'varchar',
  })
  role: 'admin' | 'librarian' | 'user';

  @Column({ default: true, name: 'is_active' })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;
}
