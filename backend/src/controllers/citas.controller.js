/**
 * Controlador de Citas
 */

import { supabase } from '../config/supabase.js';
import { validationResult } from 'express-validator';
import { asyncHandler } from '../middlewares/errorHandler.js';

/**
 * Obtener todas las citas (Admin/Recepción)
 * GET /api/citas
 */
export const obtenerTodasCitas = asyncHandler(async (req, res) => {
  const { estado, fecha_desde, fecha_hasta, profesional_id, page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('citas')
    .select(`
      *,
      mascota:mascotas(id, nombre, especie, foto_url),
      tutor:tutores(
        id,
        user:users(nombre_completo, telefono, email)
      ),
      servicio:servicios(id, nombre, tipo, duracion_minutos),
      profesional:profesionales(
        id,
        user:users(nombre_completo)
      ),
      consultorio:consultorios(id, nombre, numero)
    `, { count: 'exact' })
    .is('deleted_at', null)
    .order('fecha_hora', { ascending: false })
    .range(offset, offset + limit - 1);

  if (estado) {
    query = query.eq('estado', estado);
  }

  if (fecha_desde) {
    query = query.gte('fecha_hora', fecha_desde);
  }

  if (fecha_hasta) {
    query = query.lte('fecha_hora', fecha_hasta);
  }

  if (profesional_id) {
    query = query.eq('profesional_id', profesional_id);
  }

  const { data, error, count } = await query;

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener citas',
      message: error.message
    });
  }

  res.json({
    citas: data,
    pagination: {
      total: count,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(count / limit)
    }
  });
});

/**
 * Obtener citas propias del tutor
 * GET /api/citas/mis-citas
 */
export const obtenerCitasPropias = asyncHandler(async (req, res) => {
  const { estado } = req.query;

  // Obtener tutor_id del usuario actual
  const { data: tutorData, error: tutorError } = await supabase
    .from('tutores')
    .select('id')
    .eq('user_id', req.user.id)
    .single();

  if (tutorError || !tutorData) {
    return res.status(404).json({
      error: 'Tutor no encontrado',
      message: 'No se encontró el perfil de tutor'
    });
  }

  let query = supabase
    .from('citas')
    .select(`
      *,
      mascota:mascotas(id, nombre, especie, foto_url),
      servicio:servicios(id, nombre, tipo, duracion_minutos, precio_base),
      profesional:profesionales(
        id,
        user:users(nombre_completo),
        especialidades
      ),
      consultorio:consultorios(id, nombre, numero)
    `)
    .eq('tutor_id', tutorData.id)
    .is('deleted_at', null)
    .order('fecha_hora', { ascending: false });

  if (estado) {
    query = query.eq('estado', estado);
  }

  const { data, error } = await query;

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener citas',
      message: error.message
    });
  }

  // Separar en próximas y pasadas
  const ahora = new Date();
  const proximas = data.filter(c => new Date(c.fecha_hora) >= ahora && c.estado !== 'cancelada');
  const pasadas = data.filter(c => new Date(c.fecha_hora) < ahora || c.estado === 'cancelada' || c.estado === 'atendida');

  res.json({
    proximas,
    pasadas,
    total: data.length
  });
});

/**
 * Obtener citas de un profesional (Médico)
 * GET /api/citas/mis-citas-profesional
 */
export const obtenerCitasProfesional = asyncHandler(async (req, res) => {
  const { fecha } = req.query;

  // Obtener profesional_id del usuario actual
  const { data: profesionalData, error: profError } = await supabase
    .from('profesionales')
    .select('id')
    .eq('user_id', req.user.id)
    .single();

  if (profError || !profesionalData) {
    return res.status(404).json({
      error: 'Profesional no encontrado',
      message: 'No se encontró el perfil de profesional'
    });
  }

  let query = supabase
    .from('citas')
    .select(`
      *,
      mascota:mascotas(id, nombre, especie, raza, foto_url),
      tutor:tutores(
        id,
        user:users(nombre_completo, telefono)
      ),
      servicio:servicios(id, nombre, tipo, duracion_minutos),
      consultorio:consultorios(id, nombre, numero)
    `)
    .eq('profesional_id', profesionalData.id)
    .is('deleted_at', null)
    .order('fecha_hora', { ascending: true });

  // Si se especifica fecha, filtrar por ese día
  if (fecha) {
    const fechaInicio = `${fecha}T00:00:00`;
    const fechaFin = `${fecha}T23:59:59`;
    query = query.gte('fecha_hora', fechaInicio).lte('fecha_hora', fechaFin);
  } else {
    // Por defecto, mostrar del día actual en adelante
    const hoy = new Date().toISOString().split('T')[0];
    query = query.gte('fecha_hora', `${hoy}T00:00:00`);
  }

  const { data, error } = await query;

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener citas',
      message: error.message
    });
  }

  res.json({
    citas: data,
    total: data.length
  });
});

/**
 * Obtener una cita por ID
 * GET /api/citas/:id
 */
export const obtenerCitaPorId = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('citas')
    .select(`
      *,
      mascota:mascotas(
        *,
        historia_clinica:historias_clinicas(id, numero_historia)
      ),
      tutor:tutores(
        *,
        user:users(nombre_completo, telefono, email)
      ),
      servicio:servicios(*),
      profesional:profesionales(
        *,
        user:users(nombre_completo, email, telefono)
      ),
      consultorio:consultorios(*),
      confirmada_por_user:users!citas_confirmada_por_fkey(nombre_completo)
    `)
    .eq('id', id)
    .is('deleted_at', null)
    .single();

  if (error) {
    return res.status(404).json({
      error: 'Cita no encontrada',
      message: error.message
    });
  }

  res.json({
    cita: data
  });
});

/**
 * Crear nueva cita (Tutor)
 * POST /api/citas
 */
export const crearCita = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const {
    mascota_id,
    servicio_id,
    profesional_id,
    fecha_hora,
    motivo_consulta,
    observaciones
  } = req.body;

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

  // Verificar que la mascota pertenece al tutor
  const { data: mascotaData, error: mascotaError } = await supabase
    .from('mascotas')
    .select('tutor_id, estado')
    .eq('id', mascota_id)
    .single();

  if (mascotaError || !mascotaData) {
    return res.status(404).json({
      error: 'Mascota no encontrada',
      message: 'La mascota no existe'
    });
  }

  if (mascotaData.tutor_id !== tutorData.id) {
    return res.status(403).json({
      error: 'Acceso denegado',
      message: 'Esta mascota no te pertenece'
    });
  }

  if (mascotaData.estado !== 'aprobado') {
    return res.status(400).json({
      error: 'Mascota no aprobada',
      message: 'La mascota debe estar aprobada para agendar citas'
    });
  }

  // Obtener duración del servicio
  const { data: servicioData } = await supabase
    .from('servicios')
    .select('duracion_minutos')
    .eq('id', servicio_id)
    .single();

  const duracionMinutos = servicioData?.duracion_minutos || 30;
  const fechaHoraFin = new Date(new Date(fecha_hora).getTime() + duracionMinutos * 60000).toISOString();

  // Verificar disponibilidad del profesional
  const { data: citasConflictivas } = await supabase
    .from('citas')
    .select('id')
    .eq('profesional_id', profesional_id)
    .not('estado', 'in', '(cancelada,reprogramada)')
    .is('deleted_at', null)
    .or(`and(fecha_hora.lte.${fecha_hora},fecha_hora_fin.gte.${fecha_hora}),and(fecha_hora.lte.${fechaHoraFin},fecha_hora_fin.gte.${fechaHoraFin})`);

  if (citasConflictivas && citasConflictivas.length > 0) {
    return res.status(400).json({
      error: 'Horario no disponible',
      message: 'El profesional ya tiene una cita en ese horario'
    });
  }

  // Crear cita
  const citaData = {
    mascota_id,
    tutor_id: tutorData.id,
    servicio_id,
    profesional_id,
    fecha_hora,
    fecha_hora_fin: fechaHoraFin,
    estado: 'reservada',
    motivo_consulta,
    observaciones
  };

  const { data, error } = await supabase
    .from('citas')
    .insert(citaData)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al crear cita',
      message: error.message
    });
  }

  res.status(201).json({
    message: 'Cita creada exitosamente',
    cita: data
  });
});

/**
 * Actualizar cita
 * PUT /api/citas/:id
 */
export const actualizarCita = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { fecha_hora, motivo_consulta, observaciones, estado } = req.body;

  // Verificar que la cita existe
  const { data: citaExistente, error: fetchError } = await supabase
    .from('citas')
    .select('*, tutor:tutores(user_id)')
    .eq('id', id)
    .is('deleted_at', null)
    .single();

  if (fetchError || !citaExistente) {
    return res.status(404).json({
      error: 'Cita no encontrada',
      message: 'La cita no existe'
    });
  }

  // Verificar permisos
  const esPersonal = ['admin', 'medico', 'recepcion'].includes(req.user.rol);
  const esPropietario = citaExistente.tutor.user_id === req.user.id;

  if (!esPersonal && !esPropietario) {
    return res.status(403).json({
      error: 'Acceso denegado',
      message: 'No tienes permiso para modificar esta cita'
    });
  }

  const updateData = {};

  if (fecha_hora) updateData.fecha_hora = fecha_hora;
  if (motivo_consulta) updateData.motivo_consulta = motivo_consulta;
  if (observaciones) updateData.observaciones = observaciones;

  // Solo personal puede cambiar estado
  if (estado && esPersonal) {
    updateData.estado = estado;
  }

  const { data, error } = await supabase
    .from('citas')
    .update(updateData)
    .eq('id', id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al actualizar cita',
      message: error.message
    });
  }

  res.json({
    message: 'Cita actualizada exitosamente',
    cita: data
  });
});

/**
 * Cancelar cita
 * POST /api/citas/:id/cancelar
 */
export const cancelarCita = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { motivo_cancelacion } = req.body;

  const { data, error } = await supabase
    .from('citas')
    .update({
      estado: 'cancelada',
      motivo_cancelacion
    })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al cancelar cita',
      message: error.message
    });
  }

  res.json({
    message: 'Cita cancelada exitosamente',
    cita: data
  });
});

/**
 * Confirmar cita (Recepción)
 * POST /api/citas/:id/confirmar
 */
export const confirmarCita = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('citas')
    .update({
      estado: 'confirmada',
      confirmada_por: req.user.id,
      fecha_confirmacion: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al confirmar cita',
      message: error.message
    });
  }

  res.json({
    message: 'Cita confirmada exitosamente',
    cita: data
  });
});

/**
 * Check-in de cita (Recepción)
 * POST /api/citas/:id/check-in
 */
export const checkInCita = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { consultorio_id } = req.body;

  const { data, error } = await supabase
    .from('citas')
    .update({
      estado: 'en_sala',
      check_in_realizado: true,
      hora_check_in: new Date().toISOString(),
      consultorio_id
    })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al realizar check-in',
      message: error.message
    });
  }

  res.json({
    message: 'Check-in realizado exitosamente',
    cita: data
  });
});

/**
 * Iniciar atención (Médico)
 * POST /api/citas/:id/iniciar-atencion
 */
export const iniciarAtencion = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('citas')
    .update({
      hora_inicio_atencion: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al iniciar atención',
      message: error.message
    });
  }

  res.json({
    message: 'Atención iniciada',
    cita: data
  });
});

/**
 * Finalizar atención (Médico)
 * POST /api/citas/:id/finalizar-atencion
 */
export const finalizarAtencion = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('citas')
    .update({
      estado: 'atendida',
      hora_fin_atencion: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al finalizar atención',
      message: error.message
    });
  }

  res.json({
    message: 'Atención finalizada exitosamente',
    cita: data
  });
});

/**
 * Obtener horarios disponibles
 * GET /api/citas/disponibilidad
 */
export const obtenerDisponibilidad = asyncHandler(async (req, res) => {
  const { profesional_id, fecha, servicio_id } = req.query;

  if (!profesional_id || !fecha || !servicio_id) {
    return res.status(400).json({
      error: 'Parámetros faltantes',
      message: 'Se requiere profesional_id, fecha y servicio_id'
    });
  }

  // Obtener duración del servicio
  const { data: servicioData } = await supabase
    .from('servicios')
    .select('duracion_minutos')
    .eq('id', servicio_id)
    .single();

  const duracionMinutos = servicioData?.duracion_minutos || 30;

  // Obtener citas del profesional en esa fecha
  const fechaInicio = `${fecha}T00:00:00`;
  const fechaFin = `${fecha}T23:59:59`;

  const { data: citasOcupadas } = await supabase
    .from('citas')
    .select('fecha_hora, fecha_hora_fin')
    .eq('profesional_id', profesional_id)
    .not('estado', 'in', '(cancelada,reprogramada)')
    .gte('fecha_hora', fechaInicio)
    .lte('fecha_hora', fechaFin)
    .is('deleted_at', null);

  // Generar horarios disponibles (ejemplo: 9:00 a 18:00 cada 30 min)
  const horarios = [];
  const horaInicio = 9;
  const horaFin = 18;

  for (let hora = horaInicio; hora < horaFin; hora++) {
    for (let minuto = 0; minuto < 60; minuto += 30) {
      const horaStr = `${hora.toString().padStart(2, '0')}:${minuto.toString().padStart(2, '0')}`;
      const fechaHora = `${fecha}T${horaStr}:00`;

      // Verificar si está ocupado
      const estaOcupado = citasOcupadas?.some(cita => {
        const inicio = new Date(cita.fecha_hora);
        const fin = new Date(cita.fecha_hora_fin);
        const actual = new Date(fechaHora);
        return actual >= inicio && actual < fin;
      });

      if (!estaOcupado) {
        horarios.push({
          hora: horaStr,
          fecha_hora: fechaHora,
          disponible: true
        });
      }
    }
  }

  res.json({
    fecha,
    profesional_id,
    horarios_disponibles: horarios
  });
});

export default {
  obtenerTodasCitas,
  obtenerCitasPropias,
  obtenerCitasProfesional,
  obtenerCitaPorId,
  crearCita,
  actualizarCita,
  cancelarCita,
  confirmarCita,
  checkInCita,
  iniciarAtencion,
  finalizarAtencion,
  obtenerDisponibilidad
};
