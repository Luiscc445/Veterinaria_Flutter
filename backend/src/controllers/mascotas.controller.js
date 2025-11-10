/**
 * Controlador de Mascotas
 */

import { supabase } from '../config/supabase.js';
import { validationResult } from 'express-validator';
import { asyncHandler } from '../middlewares/errorHandler.js';

/**
 * Obtener todas las mascotas (Admin/Recepción)
 * GET /api/mascotas
 */
export const obtenerTodasMascotas = asyncHandler(async (req, res) => {
  const { estado, especie, page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('mascotas')
    .select(`
      *,
      tutor:tutores(
        id,
        user:users(nombre_completo, email, telefono)
      )
    `, { count: 'exact' })
    .is('deleted_at', null)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (estado) {
    query = query.eq('estado', estado);
  }

  if (especie) {
    query = query.eq('especie', especie);
  }

  const { data, error, count } = await query;

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener mascotas',
      message: error.message
    });
  }

  res.json({
    mascotas: data,
    pagination: {
      total: count,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(count / limit)
    }
  });
});

/**
 * Obtener mascotas propias del tutor
 * GET /api/mascotas/mis-mascotas
 */
export const obtenerMascotasPropias = asyncHandler(async (req, res) => {
  // Obtener el tutor_id del usuario actual
  const { data: tutorData, error: tutorError } = await supabase
    .from('tutores')
    .select('id')
    .eq('user_id', req.user.id)
    .single();

  if (tutorError || !tutorData) {
    return res.status(404).json({
      error: 'Tutor no encontrado',
      message: 'No se encontró el perfil de tutor para este usuario'
    });
  }

  const { data, error } = await supabase
    .from('mascotas')
    .select('*')
    .eq('tutor_id', tutorData.id)
    .is('deleted_at', null)
    .order('created_at', { ascending: false });

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener mascotas',
      message: error.message
    });
  }

  res.json({
    mascotas: data
  });
});

/**
 * Obtener una mascota por ID
 * GET /api/mascotas/:id
 */
export const obtenerMascotaPorId = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('mascotas')
    .select(`
      *,
      tutor:tutores(
        *,
        user:users(nombre_completo, email, telefono)
      ),
      aprobado_por_user:users!mascotas_aprobado_por_fkey(
        nombre_completo
      )
    `)
    .eq('id', id)
    .is('deleted_at', null)
    .single();

  if (error) {
    return res.status(404).json({
      error: 'Mascota no encontrada',
      message: error.message
    });
  }

  // Verificar permisos: tutores solo ven sus mascotas, personal ve todas
  if (req.user.rol === 'tutor') {
    const { data: tutorData } = await supabase
      .from('tutores')
      .select('id')
      .eq('user_id', req.user.id)
      .single();

    if (data.tutor_id !== tutorData?.id) {
      return res.status(403).json({
        error: 'Acceso denegado',
        message: 'No tienes permiso para ver esta mascota'
      });
    }
  }

  res.json({
    mascota: data
  });
});

/**
 * Crear nueva mascota
 * POST /api/mascotas
 */
export const crearMascota = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  // Obtener tutor_id del usuario actual
  const { data: tutorData, error: tutorError } = await supabase
    .from('tutores')
    .select('id')
    .eq('user_id', req.user.id)
    .single();

  if (tutorError || !tutorData) {
    return res.status(400).json({
      error: 'Tutor no encontrado',
      message: 'Debes completar tu perfil de tutor primero'
    });
  }

  const mascotaData = {
    tutor_id: tutorData.id,
    nombre: req.body.nombre,
    especie: req.body.especie,
    raza: req.body.raza,
    sexo: req.body.sexo,
    fecha_nacimiento: req.body.fecha_nacimiento,
    peso_kg: req.body.peso_kg,
    color: req.body.color,
    senias_particulares: req.body.senias_particulares,
    microchip: req.body.microchip,
    foto_url: req.body.foto_url,
    alergias: req.body.alergias,
    condiciones_preexistentes: req.body.condiciones_preexistentes,
    esterilizado: req.body.esterilizado || false,
    estado: 'pendiente', // Requiere aprobación
    activo: true
  };

  const { data, error } = await supabase
    .from('mascotas')
    .insert(mascotaData)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al crear mascota',
      message: error.message
    });
  }

  // Crear historia clínica automáticamente
  const { error: historiaError } = await supabase
    .from('historias_clinicas')
    .insert({
      mascota_id: data.id
      // El número de historia se genera automáticamente por trigger
    });

  if (historiaError) {
    console.error('Error al crear historia clínica:', historiaError);
  }

  res.status(201).json({
    message: 'Mascota registrada exitosamente. Pendiente de aprobación.',
    mascota: data
  });
});

/**
 * Actualizar mascota
 * PUT /api/mascotas/:id
 */
export const actualizarMascota = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;

  // Verificar que la mascota existe
  const { data: mascotaExistente, error: fetchError } = await supabase
    .from('mascotas')
    .select('*, tutor:tutores(user_id)')
    .eq('id', id)
    .is('deleted_at', null)
    .single();

  if (fetchError || !mascotaExistente) {
    return res.status(404).json({
      error: 'Mascota no encontrada',
      message: 'La mascota no existe'
    });
  }

  // Verificar permisos
  if (req.user.rol === 'tutor') {
    if (mascotaExistente.tutor.user_id !== req.user.id) {
      return res.status(403).json({
        error: 'Acceso denegado',
        message: 'No tienes permiso para modificar esta mascota'
      });
    }

    // Los tutores solo pueden modificar mascotas pendientes
    if (mascotaExistente.estado !== 'pendiente') {
      return res.status(403).json({
        error: 'Modificación no permitida',
        message: 'No puedes modificar una mascota que ya fue aprobada'
      });
    }
  }

  const updateData = {};
  const camposPermitidos = [
    'nombre', 'raza', 'sexo', 'fecha_nacimiento', 'peso_kg', 'color',
    'senias_particulares', 'microchip', 'foto_url', 'alergias',
    'condiciones_preexistentes', 'esterilizado'
  ];

  camposPermitidos.forEach(campo => {
    if (req.body[campo] !== undefined) {
      updateData[campo] = req.body[campo];
    }
  });

  const { data, error } = await supabase
    .from('mascotas')
    .update(updateData)
    .eq('id', id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al actualizar mascota',
      message: error.message
    });
  }

  res.json({
    message: 'Mascota actualizada exitosamente',
    mascota: data
  });
});

/**
 * Eliminar mascota (soft delete)
 * DELETE /api/mascotas/:id
 */
export const eliminarMascota = asyncHandler(async (req, res) => {
  const { id } = req.params;

  // Verificar permisos
  if (req.user.rol === 'tutor') {
    const { data: mascota } = await supabase
      .from('mascotas')
      .select('tutor:tutores(user_id)')
      .eq('id', id)
      .single();

    if (mascota?.tutor.user_id !== req.user.id) {
      return res.status(403).json({
        error: 'Acceso denegado',
        message: 'No tienes permiso para eliminar esta mascota'
      });
    }
  }

  const { error } = await supabase
    .from('mascotas')
    .update({ deleted_at: new Date().toISOString() })
    .eq('id', id);

  if (error) {
    return res.status(500).json({
      error: 'Error al eliminar mascota',
      message: error.message
    });
  }

  res.json({
    message: 'Mascota eliminada exitosamente'
  });
});

/**
 * Obtener mascotas pendientes de aprobación
 * GET /api/mascotas/estado/pendientes
 */
export const obtenerMascotasPendientes = asyncHandler(async (req, res) => {
  const { data, error } = await supabase
    .from('mascotas')
    .select(`
      *,
      tutor:tutores(
        *,
        user:users(nombre_completo, email, telefono)
      )
    `)
    .eq('estado', 'pendiente')
    .is('deleted_at', null)
    .order('created_at', { ascending: true });

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener mascotas pendientes',
      message: error.message
    });
  }

  res.json({
    mascotas: data,
    total: data.length
  });
});

/**
 * Aprobar mascota
 * POST /api/mascotas/:id/aprobar
 */
export const aprobarMascota = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('mascotas')
    .update({
      estado: 'aprobado',
      aprobado_por: req.user.id,
      fecha_aprobacion: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al aprobar mascota',
      message: error.message
    });
  }

  // TODO: Enviar notificación al tutor

  res.json({
    message: 'Mascota aprobada exitosamente',
    mascota: data
  });
});

/**
 * Rechazar mascota
 * POST /api/mascotas/:id/rechazar
 */
export const rechazarMascota = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { motivo_rechazo } = req.body;

  if (!motivo_rechazo) {
    return res.status(400).json({
      error: 'Motivo requerido',
      message: 'Debe proporcionar un motivo de rechazo'
    });
  }

  const { data, error } = await supabase
    .from('mascotas')
    .update({
      estado: 'rechazado',
      motivo_rechazo,
      aprobado_por: req.user.id,
      fecha_aprobacion: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al rechazar mascota',
      message: error.message
    });
  }

  // TODO: Enviar notificación al tutor con motivo de rechazo

  res.json({
    message: 'Mascota rechazada',
    mascota: data
  });
});

export default {
  obtenerTodasMascotas,
  obtenerMascotasPropias,
  obtenerMascotaPorId,
  crearMascota,
  actualizarMascota,
  eliminarMascota,
  aprobarMascota,
  rechazarMascota,
  obtenerMascotasPendientes
};
