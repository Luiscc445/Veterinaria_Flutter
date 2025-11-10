/**
 * Controlador de Autenticación
 */

import { supabase, supabaseAdmin } from '../config/supabase.js';
import { validationResult } from 'express-validator';
import { asyncHandler } from '../middlewares/errorHandler.js';

/**
 * Registrar nuevo usuario
 * POST /api/auth/register
 */
export const register = asyncHandler(async (req, res) => {
  // Validar entrada
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { email, password, nombre_completo, telefono, rol = 'tutor' } = req.body;

  // Solo admin puede crear usuarios con roles diferentes a 'tutor'
  if (rol !== 'tutor' && (!req.user || req.user.rol !== 'admin')) {
    return res.status(403).json({
      error: 'Acceso denegado',
      message: 'Solo administradores pueden crear usuarios con roles especiales'
    });
  }

  // Crear usuario en Supabase Auth
  const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
    email,
    password,
    email_confirm: true, // Auto-confirmar email en desarrollo
    user_metadata: {
      nombre_completo,
      rol
    }
  });

  if (authError) {
    return res.status(400).json({
      error: 'Error al crear usuario',
      message: authError.message
    });
  }

  // Crear registro en tabla users
  const { data: userData, error: userError } = await supabaseAdmin
    .from('users')
    .insert({
      auth_user_id: authData.user.id,
      email,
      nombre_completo,
      telefono,
      rol,
      activo: true
    })
    .select()
    .single();

  if (userError) {
    // Si falla la creación en users, eliminar usuario de Auth
    await supabaseAdmin.auth.admin.deleteUser(authData.user.id);

    return res.status(500).json({
      error: 'Error al crear perfil de usuario',
      message: userError.message
    });
  }

  // Si es tutor, crear registro en tabla tutores
  if (rol === 'tutor') {
    const { error: tutorError } = await supabaseAdmin
      .from('tutores')
      .insert({
        user_id: userData.id,
        dni: req.body.dni,
        direccion: req.body.direccion,
        ciudad: req.body.ciudad,
        provincia: req.body.provincia
      });

    if (tutorError) {
      console.error('Error al crear tutor:', tutorError);
    }
  }

  // Si es médico, crear registro en tabla profesionales
  if (rol === 'medico') {
    const { error: profError } = await supabaseAdmin
      .from('profesionales')
      .insert({
        user_id: userData.id,
        matricula_profesional: req.body.matricula_profesional,
        especialidades: req.body.especialidades || [],
        anios_experiencia: req.body.anios_experiencia || 0
      });

    if (profError) {
      console.error('Error al crear profesional:', profError);
    }
  }

  res.status(201).json({
    message: 'Usuario registrado exitosamente',
    user: {
      id: userData.id,
      email: userData.email,
      nombre_completo: userData.nombre_completo,
      rol: userData.rol
    }
  });
});

/**
 * Iniciar sesión
 * POST /api/auth/login
 */
export const login = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { email, password } = req.body;

  // Autenticar con Supabase
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  });

  if (error) {
    return res.status(401).json({
      error: 'Credenciales inválidas',
      message: 'Email o contraseña incorrectos'
    });
  }

  // Obtener información del usuario
  const { data: userData, error: userError } = await supabase
    .from('users')
    .select('*')
    .eq('auth_user_id', data.user.id)
    .single();

  if (userError || !userData) {
    return res.status(404).json({
      error: 'Usuario no encontrado',
      message: 'No se encontró el perfil del usuario'
    });
  }

  if (!userData.activo) {
    return res.status(403).json({
      error: 'Cuenta desactivada',
      message: 'Tu cuenta ha sido desactivada. Contacta al administrador.'
    });
  }

  // Actualizar último acceso
  await supabase
    .from('users')
    .update({ ultimo_acceso: new Date().toISOString() })
    .eq('id', userData.id);

  res.json({
    message: 'Inicio de sesión exitoso',
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    expires_at: data.session.expires_at,
    user: {
      id: userData.id,
      email: userData.email,
      nombre_completo: userData.nombre_completo,
      rol: userData.rol,
      telefono: userData.telefono,
      avatar_url: userData.avatar_url
    }
  });
});

/**
 * Cerrar sesión
 * POST /api/auth/logout
 */
export const logout = asyncHandler(async (req, res) => {
  const { error } = await supabase.auth.signOut();

  if (error) {
    return res.status(500).json({
      error: 'Error al cerrar sesión',
      message: error.message
    });
  }

  res.json({
    message: 'Sesión cerrada exitosamente'
  });
});

/**
 * Refrescar token
 * POST /api/auth/refresh-token
 */
export const refreshToken = asyncHandler(async (req, res) => {
  const { refresh_token } = req.body;

  if (!refresh_token) {
    return res.status(400).json({
      error: 'Refresh token requerido',
      message: 'Debe proporcionar un refresh token'
    });
  }

  const { data, error } = await supabase.auth.refreshSession({
    refresh_token
  });

  if (error) {
    return res.status(401).json({
      error: 'Token inválido',
      message: 'El refresh token es inválido o ha expirado'
    });
  }

  res.json({
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    expires_at: data.session.expires_at
  });
});

/**
 * Obtener usuario actual
 * GET /api/auth/me
 */
export const getCurrentUser = asyncHandler(async (req, res) => {
  // req.user ya fue agregado por el middleware authenticate
  const user = { ...req.user };
  delete user.auth_user_id; // No exponer este ID

  res.json({
    user
  });
});

/**
 * Actualizar perfil
 * PUT /api/auth/profile
 */
export const updateProfile = asyncHandler(async (req, res) => {
  const { nombre_completo, telefono, avatar_url } = req.body;

  const updateData = {};
  if (nombre_completo) updateData.nombre_completo = nombre_completo;
  if (telefono) updateData.telefono = telefono;
  if (avatar_url) updateData.avatar_url = avatar_url;

  const { data, error } = await supabase
    .from('users')
    .update(updateData)
    .eq('id', req.user.id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al actualizar perfil',
      message: error.message
    });
  }

  res.json({
    message: 'Perfil actualizado exitosamente',
    user: data
  });
});

/**
 * Cambiar contraseña
 * POST /api/auth/change-password
 */
export const changePassword = asyncHandler(async (req, res) => {
  const { current_password, new_password } = req.body;

  if (!current_password || !new_password) {
    return res.status(400).json({
      error: 'Datos incompletos',
      message: 'Debe proporcionar la contraseña actual y la nueva'
    });
  }

  if (new_password.length < 6) {
    return res.status(400).json({
      error: 'Contraseña inválida',
      message: 'La nueva contraseña debe tener al menos 6 caracteres'
    });
  }

  // Verificar contraseña actual
  const { error: signInError } = await supabase.auth.signInWithPassword({
    email: req.user.email,
    password: current_password
  });

  if (signInError) {
    return res.status(401).json({
      error: 'Contraseña incorrecta',
      message: 'La contraseña actual es incorrecta'
    });
  }

  // Actualizar contraseña
  const { error } = await supabase.auth.updateUser({
    password: new_password
  });

  if (error) {
    return res.status(500).json({
      error: 'Error al cambiar contraseña',
      message: error.message
    });
  }

  res.json({
    message: 'Contraseña cambiada exitosamente'
  });
});

/**
 * Solicitar restablecimiento de contraseña
 * POST /api/auth/reset-password-request
 */
export const resetPasswordRequest = asyncHandler(async (req, res) => {
  const { email } = req.body;

  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${process.env.FRONTEND_URL}/reset-password`
  });

  if (error) {
    return res.status(500).json({
      error: 'Error al enviar email',
      message: error.message
    });
  }

  // Siempre devolver éxito para no revelar si el email existe
  res.json({
    message: 'Si el email existe, recibirás instrucciones para restablecer tu contraseña'
  });
});

/**
 * Restablecer contraseña
 * POST /api/auth/reset-password
 */
export const resetPassword = asyncHandler(async (req, res) => {
  const { password } = req.body;

  const { error } = await supabase.auth.updateUser({
    password
  });

  if (error) {
    return res.status(500).json({
      error: 'Error al restablecer contraseña',
      message: error.message
    });
  }

  res.json({
    message: 'Contraseña restablecida exitosamente'
  });
});

export default {
  register,
  login,
  logout,
  refreshToken,
  getCurrentUser,
  updateProfile,
  changePassword,
  resetPasswordRequest,
  resetPassword
};
