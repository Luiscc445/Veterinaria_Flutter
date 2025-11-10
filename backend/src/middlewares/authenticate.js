/**
 * Middleware de autenticación con Supabase
 */

import { supabase } from '../config/supabase.js';

/**
 * Middleware para verificar token JWT de Supabase
 */
export const authenticate = async (req, res, next) => {
  try {
    // Obtener token del header Authorization
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'No autorizado',
        message: 'Token de autenticación requerido'
      });
    }

    const token = authHeader.substring(7); // Remover 'Bearer '

    // Verificar token con Supabase
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      return res.status(401).json({
        error: 'No autorizado',
        message: 'Token inválido o expirado'
      });
    }

    // Obtener información completa del usuario desde la tabla users
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('auth_user_id', user.id)
      .single();

    if (userError || !userData) {
      return res.status(401).json({
        error: 'No autorizado',
        message: 'Usuario no encontrado en el sistema'
      });
    }

    // Verificar si el usuario está activo
    if (!userData.activo) {
      return res.status(403).json({
        error: 'Cuenta desactivada',
        message: 'Tu cuenta ha sido desactivada. Contacta al administrador.'
      });
    }

    // Agregar usuario y token al request
    req.user = userData;
    req.token = token;

    // Actualizar último acceso
    await supabase
      .from('users')
      .update({ ultimo_acceso: new Date().toISOString() })
      .eq('id', userData.id);

    next();
  } catch (error) {
    console.error('Error en autenticación:', error);
    return res.status(500).json({
      error: 'Error de autenticación',
      message: 'Error al verificar token'
    });
  }
};

/**
 * Middleware opcional de autenticación (no falla si no hay token)
 */
export const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(); // Continuar sin autenticación
    }

    const token = authHeader.substring(7);
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (!error && user) {
      const { data: userData } = await supabase
        .from('users')
        .select('*')
        .eq('auth_user_id', user.id)
        .single();

      if (userData && userData.activo) {
        req.user = userData;
        req.token = token;
      }
    }

    next();
  } catch (error) {
    next(); // Continuar sin autenticación en caso de error
  }
};

export default authenticate;
