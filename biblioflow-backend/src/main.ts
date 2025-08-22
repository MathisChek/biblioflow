import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';

async function bootstrap() {
  try {
    console.log("🚀 Démarrage de l'application...");
    const app = await NestFactory.create(AppModule);

    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );

    app.enableCors({
      origin: ['http://localhost:4200', 'http://localhost:8080'],
      credentials: true,
    });

    const configService = app.get(ConfigService);
    const port = configService.get<number>('PORT', 3000);

    await app.listen(port);
    console.log(`🚀 BiblioFlow API running on port ${port}`);
    console.log(`📚 Routes disponibles:`);
    console.log(`  GET  http://localhost:${port}/health`);
    console.log(`  GET  http://localhost:${port}/books`);
    console.log(`  POST http://localhost:${port}/auth/login`);
  } catch (error) {
    console.error('❌ Erreur au démarrage:', error);
    process.exit(1);
  }
}
bootstrap();
