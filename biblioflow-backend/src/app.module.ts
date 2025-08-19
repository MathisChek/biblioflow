import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { BooksModule } from './books/books.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { Book } from './books/entities/book.entity';
import { User } from './users/entities/user.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath:
        process.env.NODE_ENV === 'production' ? '.env.production' : '.env',
    }),

    TypeOrmModule.forRootAsync({
      useFactory: (configService: ConfigService) => {
        console.log('🔌 Configuration base de données:');
        console.log('  HOST:', configService.get<string>('DATABASE_HOST'));
        console.log('  PORT:', configService.get<string>('DATABASE_PORT'));
        console.log('  USER:', configService.get<string>('DATABASE_USER'));
        console.log('  DB:', configService.get<string>('DATABASE_NAME'));

        return {
          type: 'postgres' as const,
          host: configService.get<string>('DATABASE_HOST', 'localhost'),
          port: parseInt(
            configService.get<string>('DATABASE_PORT', '5432'),
            10,
          ),
          username: configService.get<string>('DATABASE_USER', 'postgres'),
          password: configService.get<string>('DATABASE_PASSWORD', 'password'),
          database: configService.get<string>(
            'DATABASE_NAME',
            'biblioflow_dev',
          ),
          ssl:
            configService.get<string>('DATABASE_SSL') === 'true'
              ? {
                  rejectUnauthorized:
                    configService.get<string>(
                      'DATABASE_SSL_REJECT_UNAUTHORIZED',
                    ) === 'true',
                }
              : false,
          entities: [Book, User],
          synchronize:
            configService.get<string>('DATABASE_SYNCHRONIZE', 'true') ===
            'true',
          logging:
            configService.get<string>('DATABASE_LOGGING', 'false') === 'true',
          maxQueryExecutionTime: 1000,
          retryAttempts: 5,
          retryDelay: 3000,
        };
      },
      inject: [ConfigService],
    }),

    BooksModule,
    UsersModule,
    AuthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
