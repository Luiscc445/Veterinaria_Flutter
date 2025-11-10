/**
 * Controlador de Historias Clínicas
 */

import { supabase } from '../config/supabase.js';
import { validationResult } from 'express-validator';
import { asyncHandler } from '../middlewares/errorHandler.js';

/**
 * Obtener historia clínica de una mascota
 * GET /api/historias/mascota/:mascota_id
 */
export const obtenerHistoriaPorMascota = asyncHandler(async (req, res) => {
  const { mascota_id } = req.params;

  const { data, error } = await supabase
    .from('historias_clinicas')
    .select(`
      *,
      mascota:mascotas(
        id,
        nombre,
        especie,
        raza,
        fecha_nacimiento,
        peso_kg,
        foto_url,
        tutor:tutores(
          id,
          user:users(nombre_completo, telefono, email)
        )
      )
    `)
    .eq('mascota_id', mascota_id)
    .is('deleted_at', null)
    .single();

  if (error) {
    return res.status(404).json({
      error: 'Historia clínica no encontrada',
      message: error.message
    });
  }

  res.json({
    historia: data
  });
});

/**
 * Obtener historia clínica por ID
 * GET /api/historias/:id
 */
export const obtenerHistoriaPorId = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('historias_clinicas')
    .select(`
      *,
      mascota:mascotas(
        *,
        tutor:tutores(
          *,
          user:users(nombre_completo, telefono, email)
        )
      )
    `)
    .eq('id', id)
    .is('deleted_at', null)
    .single();

  if (error) {
    return res.status(404).json({
      error: 'Historia clínica no encontrada',
      message: error.message
    });
  }

  res.json({
    historia: data
  });
});

/**
 * Obtener episodios de una historia clínica
 * GET /api/historias/:id/episodios
 */
export const obtenerEpisodios = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;

  const { data, error, count } = await supabase
    .from('episodios')
    .select(`
      *,
      profesional:profesionales(
        id,
        matricula_profesional,
        user:users(nombre_completo)
      ),
      cita:citas(
        id,
        fecha_hora,
        servicio:servicios(nombre, tipo)
      )
    `, { count: 'exact' })
    .eq('historia_clinica_id', id)
    .is('deleted_at', null)
    .order('fecha_episodio', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener episodios',
      message: error.message
    });
  }

  res.json({
    episodios: data,
    pagination: {
      total: count,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(count / limit)
    }
  });
});

/**
 * Crear nuevo episodio
 * POST /api/historias/:id/episodios
 */
export const crearEpisodio = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const episodioData = {
    historia_clinica_id: id,
    ...req.body,
    fecha_episodio: req.body.fecha_episodio || new Date().toISOString()
  };

  const { data, error } = await supabase
    .from('episodios')
    .insert(episodioData)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al crear episodio',
      message: error.message
    });
  }

  res.status(201).json({
    message: 'Episodio creado exitosamente',
    episodio: data
  });
});

/**
 * Actualizar episodio
 * PUT /api/episodios/:id
 */
export const actualizarEpisodio = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const updateData = {};
  const camposPermitidos = [
    'motivo_consulta', 'anamnesis', 'examen_fisico', 'temperatura_celsius',
    'frecuencia_cardiaca', 'frecuencia_respiratoria', 'peso_kg',
    'diagnostico', 'plan_tratamiento', 'indicaciones_tutor', 'proxima_visita', 'observaciones'
  ];

  camposPermitidos.forEach(campo => {
    if (req.body[campo] !== undefined) {
      updateData[campo] = req.body[campo];
    }
  });

  const { data, error } = await supabase
    .from('episodios')
    .update(updateData)
    .eq('id', id)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al actualizar episodio',
      message: error.message
    });
  }

  res.json({
    message: 'Episodio actualizado exitosamente',
    episodio: data
  });
});

/**
 * Obtener episodio por ID con detalles completos
 * GET /api/episodios/:id
 */
export const obtenerEpisodioPorId = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from('episodios')
    .select(`
      *,
      historia_clinica:historias_clinicas(
        id,
        numero_historia,
        mascota:mascotas(
          id,
          nombre,
          especie,
          raza,
          fecha_nacimiento
        )
      ),
      profesional:profesionales(
        id,
        matricula_profesional,
        especialidades,
        user:users(nombre_completo, email)
      ),
      cita:citas(
        id,
        fecha_hora,
        servicio:servicios(nombre, tipo)
      )
    `)
    .eq('id', id)
    .is('deleted_at', null)
    .single();

  if (error) {
    return res.status(404).json({
      error: 'Episodio no encontrado',
      message: error.message
    });
  }

  // Obtener consumos de fármacos del episodio
  const { data: consumos } = await supabase
    .from('consumos_farmacos')
    .select(`
      *,
      farmaco:farmacos(
        id,
        nombre_comercial,
        nombre_generico,
        concentracion,
        forma_farmaceutica
      ),
      lote:lotes_farmacos(
        id,
        numero_lote,
        fecha_vencimiento
      )
    `)
    .eq('episodio_id', id);

  // Obtener adjuntos del episodio
  const { data: adjuntos } = await supabase
    .from('adjuntos')
    .select('*')
    .eq('episodio_id', id)
    .is('deleted_at', null);

  res.json({
    episodio: {
      ...data,
      consumos_farmacos: consumos || [],
      adjuntos: adjuntos || []
    }
  });
});

/**
 * Agregar adjunto a episodio
 * POST /api/episodios/:id/adjuntos
 */
export const agregarAdjunto = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { tipo_adjunto, nombre_archivo, url_archivo, descripcion, tamano_bytes, mime_type } = req.body;

  const { data, error } = await supabase
    .from('adjuntos')
    .insert({
      episodio_id: id,
      tipo_adjunto,
      nombre_archivo,
      url_archivo,
      descripcion,
      tamano_bytes,
      mime_type,
      subido_por: req.user.id
    })
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al agregar adjunto',
      message: error.message
    });
  }

  res.status(201).json({
    message: 'Adjunto agregado exitosamente',
    adjunto: data
  });
});

export default {
  obtenerHistoriaPorMascota,
  obtenerHistoriaPorId,
  obtenerEpisodios,
  crearEpisodio,
  actualizarEpisodio,
  obtenerEpisodioPorId,
  agregarAdjunto
};
