import { Module, NestModule, MiddlewareConsumer } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { AuthModule } from "./auth/auth.module";
import { UsersModule } from "./users/users.module";
import { WorkersModule } from "./workers/workers.module";
import { OrdersModule } from "./orders/orders.module";
import { QueueModule } from "./queue/queue.module";
import { PricingModule } from "./pricing/pricing.module";
import { LoggerMiddleware } from "./common/middleware/logger.middleware";
import { AppController } from "./app.controller";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    AuthModule,
    UsersModule,
    WorkersModule,
    OrdersModule,
    QueueModule,
    PricingModule,
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(LoggerMiddleware).forRoutes("*");
  }
}
