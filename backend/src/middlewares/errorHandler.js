/**
 * Middleware global de manejo de errores
 */

export const errorHandler = (err, req, res, next) => {
  console.error('❌ Error:', err);

  // Error de Supabase
  if (err.code) {
    return res.status(err.status || 500).json({
      error: 'Error de base de datos',
      message: err.message,
      details: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }

  // Error de validación
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      error: 'Error de validación',
      message: err.message,
      details: err.errors
    });
  }

  // Error de autenticación
  if (err.name === 'UnauthorizedError' || err.status === 401) {
    return res.status(401).json({
      error: 'No autorizado',
      message: 'Token inválido o expirado'
    });
  }

  // Error de permisos
  if (err.status === 403) {
    return res.status(403).json({
      error: 'Acceso denegado',
      message: 'No tienes permisos para realizar esta acción'
    });
  }

  // Error genérico
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Error interno del servidor';

  res.status(statusCode).json({
    error: statusCode === 500 ? 'Error interno del servidor' : message,
    message: message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

/**
 * Wrapper para funciones async que captura errores
 */
export const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

export default errorHandler;
