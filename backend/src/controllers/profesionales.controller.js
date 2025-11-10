/**
 * Controlador de Profesionales
 */

import { supabase } from '../config/supabase.js';
import { asyncHandler } from '../middlewares/errorHandler.js';

/**
 * Obtener todos los profesionales activos
 * GET /api/profesionales
 */
export const obtenerProfesionales = asyncHandler(async (req, res) => {
  const { especialidad, activo = 'true' } = req.query;

  let query = supabase
    .from('profesionales')
    .select(`
      *,
      user:users(
        id,
        nombre_completo,
        telefono,
        email,
        avatar_url
      )
    `)
    .is('deleted_at', null)
    .order('created_at', { ascending: false });

  if (activo === 'true') {
    query = query.eq('activo', true);
  }

  const { data, error } = await query;

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener profesionales',
      message: error.message
    });
  }

  // Filtrar por especialidad si se proporciona
  let profesionales = data;
  if (especialidad) {
    profesionales = data.filter(p =>
      p.especialidades && p.especialidades.includes(especialidad)
    );
  }

  res.json({
    profesionales,
    total: profesionales.length
  });
});

/**
 * Obtener un profesional por ID
 * GET /api/profesionales/:id
 */
export const obtenerProfesionalPorId = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('profesionales')
    .select(`
      *,
      user:users(
        id,
        nombre_completo,
        telefono,
        email,
        avatar_url
      )
    `)
    .eq('id', id)
    .is('deleted_at', null)
    .single();

  if (error) {
    return res.status(404).json({
      error: 'Profesional no encontrado',
      message: error.message
    });
  }

  res.json({
    profesional: data
  });
});

/**
 * Obtener horario de un profesional
 * GET /api/profesionales/:id/horario
 */
export const obtenerHorarioProfesional = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('profesionales')
    .select('horario_atencion')
    .eq('id', id)
    .single();

  if (error) {
    return res.status(404).json({
      error: 'Profesional no encontrado',
      message: error.message
    });
  }

  res.json({
    horario: data.horario_atencion || {}
  });
});

export default {
  obtenerProfesionales,
  obtenerProfesionalPorId,
  obtenerHorarioProfesional
};
