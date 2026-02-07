/**
 * Logger utility for Kindora Platform
 */

type LogLevel = 'INFO' | 'WARN' | 'ERROR' | 'DEBUG';

class Logger {
  private prefix: string;

  constructor(prefix: string = 'KINDORA') {
    this.prefix = prefix;
  }

  private formatTimestamp(): string {
    return new Date().toISOString();
  }

  private log(level: LogLevel, message: string, data?: any) {
    const timestamp = this.formatTimestamp();
    const logMessage = `[${timestamp}] [${level}] [${this.prefix}] ${message}`;

    switch (level) {
      case 'ERROR':
        console.error(logMessage, data || '');
        break;
      case 'WARN':
        console.warn(logMessage, data || '');
        break;
      case 'DEBUG':
        if (process.env.NODE_ENV === 'development') {
          console.log(logMessage, data || '');
        }
        break;
      case 'INFO':
      default:
        console.log(logMessage, data || '');
    }
  }

  info(message: string, data?: any) {
    this.log('INFO', message, data);
  }

  warn(message: string, data?: any) {
    this.log('WARN', message, data);
  }

  error(message: string, data?: any) {
    this.log('ERROR', message, data);
  }

  debug(message: string, data?: any) {
    this.log('DEBUG', message, data);
  }
}

export default Logger;
