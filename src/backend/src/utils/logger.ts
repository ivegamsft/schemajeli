import winston from 'winston';

const logLevel = process.env.LOG_LEVEL || 'info';
const logFormat = process.env.LOG_FORMAT || 'json';

const customFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

export const logger = winston.createLogger({
  level: logLevel,
  format: customFormat,
  defaultMeta: { service: 'schemajeli-backend' },
  transports: [
    new winston.transports.Console({
      format: logFormat === 'json' 
        ? winston.format.json()
        : winston.format.simple()
    })
  ]
});
