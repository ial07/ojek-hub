import { Injectable, NestMiddleware, Logger } from "@nestjs/common";
import { Request, Response, NextFunction } from "express";

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  private logger = new Logger("HTTP");

  use(req: Request, res: Response, next: NextFunction) {
    const { method, originalUrl, body } = req;
    const userAgent = req.get("user-agent") || "";
    const startTime = Date.now();

    // Log request
    this.logger.log(`➡️  ${method} ${originalUrl}`);

    // Log body for POST/PUT/PATCH (hide sensitive data)
    if (
      ["POST", "PUT", "PATCH"].includes(method) &&
      Object.keys(body).length > 0
    ) {
      const sanitizedBody = { ...body };
      if (sanitizedBody.password) sanitizedBody.password = "***";
      if (sanitizedBody.token) sanitizedBody.token = "***";
      this.logger.debug(`   Body: ${JSON.stringify(sanitizedBody)}`);
    }

    // Log response
    res.on("finish", () => {
      const { statusCode } = res;
      const duration = Date.now() - startTime;
      const emoji = statusCode >= 400 ? "❌" : "✅";
      this.logger.log(
        `${emoji} ${method} ${originalUrl} ${statusCode} - ${duration}ms`,
      );
    });

    next();
  }
}
