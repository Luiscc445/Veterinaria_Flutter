/**
 * Controlador de Servicios
 */

import { supabase } from '../config/supabase.js';
import { asyncHandler } from '../middlewares/errorHandler.js';

/**
 * Obtener todos los servicios activos
 * GET /api/servicios
 */
export const obtenerServicios = asyncHandler(async (req, res) => {
  const { tipo, activo = 'true' } = req.query;

  let query = supabase
    .from('servicios')
    .select('*')
    .is('deleted_at', null)
    .order('nombre', { ascending: true });

  if (activo === 'true') {
    query = query.eq('activo', true);
  }

  if (tipo) {
    query = query.eq('tipo', tipo);
  }

  const { data, error } = await query;

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener servicios',
      message: error.message
    });
  }

  res.json({
    servicios: data,
    total: data.length
  });
});

/**
 * Obtener un servicio por ID
 * GET /api/servicios/:id
 */
export const obtenerServicioPorId = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('servicios')
    .select('*')
    .eq('id', id)
    .is('deleted_at', null)
    .single();

  if (error) {
    return res.status(404).json({
      error: 'Servicio no encontrado',
      message: error.message
    });
  }

  res.json({
    servicio: data
  });
});

export default {
  obtenerServicios,
  obtenerServicioPorId
};
