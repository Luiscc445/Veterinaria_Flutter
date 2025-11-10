/**
 * Middleware de Rate Limiting
 */

import rateLimit from 'express-rate-limit';

/**
 * Rate limiter general
 */
export const rateLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutos
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // 100 requests por ventana
  message: {
    error: 'Demasiadas peticiones',
    message: 'Has excedido el límite de peticiones. Por favor, intenta más tarde.'
  },
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => {
    // Saltar rate limiting para health check
    return req.path === '/health';
  }
});

/**
 * Rate limiter estricto para autenticación
 */
export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // 5 intentos por ventana
  message: {
    error: 'Demasiados intentos de inicio de sesión',
    message: 'Has excedido el límite de intentos. Por favor, espera 15 minutos.'
  },
  standardHeaders: true,
  legacyHeaders: false
});

/**
 * Rate limiter para registro de usuarios
 */
export const registerRateLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hora
  max: 3, // 3 registros por hora
  message: {
    error: 'Demasiados registros',
    message: 'Has excedido el límite de registros. Por favor, intenta más tarde.'
  },
  standardHeaders: true,
  legacyHeaders: false
});

export default rateLimiter;
