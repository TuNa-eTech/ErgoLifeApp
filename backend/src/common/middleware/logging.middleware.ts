import { Injectable, NestMiddleware, Logger } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class LoggingMiddleware implements NestMiddleware {
  private readonly logger = new Logger('HTTP');

  use(req: Request, res: Response, next: NextFunction) {
    const { method, originalUrl, body } = req;
    const startTime = Date.now();

    // Log request
    this.logger.log(`📤 ${method} ${originalUrl}`);
    if (Object.keys(body).length > 0) {
      this.logger.debug(`   Body: ${JSON.stringify(body)}`);
    }

    // Capture response
    const originalSend = res.send;
    res.send = function (data) {
      const duration = Date.now() - startTime;
      const statusCode = res.statusCode;
      const statusEmoji = statusCode >= 400 ? '❌' : '✅';

      Logger.log(
        `${statusEmoji} ${method} ${originalUrl} - ${statusCode} (${duration}ms)`,
        'HTTP',
      );

      return originalSend.call(this, data);
    };

    next();
  }
}
