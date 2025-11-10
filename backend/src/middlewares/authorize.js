/**
 * Middleware de autorización por roles
 */

/**
 * Verifica que el usuario tenga uno de los roles permitidos
 * @param  {...string} rolesPermitidos - Roles que pueden acceder
 * @returns {Function} Middleware
 */
export const authorize = (...rolesPermitidos) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'No autorizado',
        message: 'Autenticación requerida'
      });
    }

    if (!rolesPermitidos.includes(req.user.rol)) {
      return res.status(403).json({
        error: 'Acceso denegado',
        message: `Se requiere uno de los siguientes roles: ${rolesPermitidos.join(', ')}`
      });
    }

    next();
  };
};

/**
 * Verifica que el usuario sea administrador
 */
export const requireAdmin = authorize('admin');

/**
 * Verifica que el usuario sea médico
 */
export const requireMedico = authorize('medico', 'admin');

/**
 * Verifica que el usuario sea recepción
 */
export const requireRecepcion = authorize('recepcion', 'admin');

/**
 * Verifica que el usuario sea tutor
 */
export const requireTutor = authorize('tutor');

/**
 * Verifica que el usuario sea personal (médico, recepción o admin)
 */
export const requirePersonal = authorize('admin', 'medico', 'recepcion');

export default authorize;
