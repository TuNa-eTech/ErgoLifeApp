import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response } from 'express';

export interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
  };
}

// Map HTTP status to error codes
const STATUS_TO_CODE: Record<number, string> = {
  400: 'BAD_REQUEST',
  401: 'UNAUTHORIZED',
  403: 'FORBIDDEN',
  404: 'NOT_FOUND',
  409: 'CONFLICT',
  422: 'VALIDATION_ERROR',
  429: 'RATE_LIMITED',
  500: 'INTERNAL_ERROR',
};

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';
    let code = 'INTERNAL_ERROR';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
      } else if (typeof exceptionResponse === 'object') {
        const responseObj = exceptionResponse as Record<string, unknown>;
        // Support custom error codes
        if (responseObj.code && typeof responseObj.code === 'string') {
          code = responseObj.code;
        }
        if (responseObj.message) {
          message = Array.isArray(responseObj.message)
            ? responseObj.message.join(', ')
            : String(responseObj.message);
        }
      }
    } else if (exception instanceof Error) {
      message = exception.message;
      this.logger.error('Unhandled exception', exception.stack);
    }

    // Use custom code or map from status
    if (code === 'INTERNAL_ERROR' && status !== 500) {
      code = STATUS_TO_CODE[status] || 'INTERNAL_ERROR';
    }

    const errorResponse: ApiErrorResponse = {
      success: false,
      error: {
        code,
        message,
      },
    };

    response.status(status).json(errorResponse);
  }
}
