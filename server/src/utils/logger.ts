export class Logger {
  private static instance: Logger;
  private env: string;

  private constructor() {
    this.env = process.env.NODE_ENV || 'development';
  }

  static getInstance(): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }

  info(message: string, meta?: any): void {
    if (this.env === 'test') return;
    
    console.log(JSON.stringify({
      level: 'info',
      timestamp: new Date().toISOString(),
      message,
      meta
    }));
  }

  error(message: string, error?: Error, meta?: any): void {
    if (this.env === 'test') return;
    
    console.error(JSON.stringify({
      level: 'error',
      timestamp: new Date().toISOString(),
      message,
      error: error ? {
        name: error.name,
        message: error.message,
        stack: this.env === 'development' ? error.stack : undefined
      } : undefined,
      meta
    }));
  }

  warn(message: string, meta?: any): void {
    if (this.env === 'test') return;
    
    console.warn(JSON.stringify({
      level: 'warn',
      timestamp: new Date().toISOString(),
      message,
      meta
    }));
  }

  debug(message: string, meta?: any): void {
    if (this.env !== 'development') return;
    
    console.debug(JSON.stringify({
      level: 'debug',
      timestamp: new Date().toISOString(),
      message,
      meta
    }));
  }
} 