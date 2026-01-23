import { NestFactory } from "@nestjs/core";
import { ValidationPipe, INestApplication } from "@nestjs/common";
import { AppModule } from "./app.module";
import { ExpressAdapter } from "@nestjs/platform-express";
import * as express from "express";

// Cached app instance for serverless warm starts
let cachedApp: INestApplication | null = null;

async function bootstrap(): Promise<INestApplication> {
  // Return cached instance if available (warm start)
  if (cachedApp) {
    return cachedApp;
  }

  // Create Express instance
  const expressApp = express();

  const app = await NestFactory.create(
    AppModule,
    new ExpressAdapter(expressApp),
    {
      logger: ["log", "error", "warn"],
    },
  );

  // Enable CORS for all origins (configure as needed for production)
  app.enableCors({
    origin: true,
    credentials: true,
  });

  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
  app.setGlobalPrefix("api");

  // Initialize the app (required for serverless)
  await app.init();

  cachedApp = app;
  return app;
}

// Vercel Serverless Handler Export
module.exports = async function handler(req: any, res: any) {
  const app = await bootstrap();
  const expressInstance = app.getHttpAdapter().getInstance();
  return expressInstance(req, res);
};

// Local development only
if (process.env.NODE_ENV !== "production") {
  bootstrap().then(async (app) => {
    const port = process.env.PORT || 3000;
    await app.listen(port);
    console.log(`Application is running on: http://localhost:${port}/api`);
  });
}
