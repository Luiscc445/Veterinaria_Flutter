/**
 * Controlador de Inventario de Fármacos
 */

import { supabase } from '../config/supabase.js';
import { validationResult } from 'express-validator';
import { asyncHandler } from '../middlewares/errorHandler.js';

/**
 * Obtener todos los fármacos
 * GET /api/inventario/farmacos
 */
export const obtenerFarmacos = asyncHandler(async (req, res) => {
  const { activo = 'true', search } = req.query;

  let query = supabase
    .from('farmacos')
    .select('*')
    .is('deleted_at', null)
    .order('nombre_comercial', { ascending: true });

  if (activo === 'true') {
    query = query.eq('activo', true);
  }

  if (search) {
    query = query.or(`nombre_comercial.ilike.%${search}%,nombre_generico.ilike.%${search}%`);
  }

  const { data, error } = await query;

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener fármacos',
      message: error.message
    });
  }

  // Calcular stock total para cada fármaco
  const farmacosConStock = await Promise.all(
    data.map(async (farmaco) => {
      const { data: stockData } = await supabase
        .rpc('calcular_stock_total_farmaco', { farmaco_uuid: farmaco.id });

      return {
        ...farmaco,
        stock_total: stockData || 0
      };
    })
  );

  res.json({
    farmacos: farmacosConStock,
    total: farmacosConStock.length
  });
});

/**
 * Obtener fármaco por ID con lotes
 * GET /api/inventario/farmacos/:id
 */
export const obtenerFarmacoPorId = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: farmaco, error } = await supabase
    .from('farmacos')
    .select('*')
    .eq('id', id)
    .is('deleted_at', null)
    .single();

  if (error) {
    return res.status(404).json({
      error: 'Fármaco no encontrado',
      message: error.message
    });
  }

  // Obtener lotes del fármaco
  const { data: lotes } = await supabase
    .from('lotes_farmacos')
    .select('*')
    .eq('farmaco_id', id)
    .is('deleted_at', null)
    .eq('activo', true)
    .order('fecha_vencimiento', { ascending: true });

  // Calcular stock total
  const stockTotal = lotes?.reduce((sum, lote) => sum + lote.cantidad_actual, 0) || 0;

  res.json({
    farmaco: {
      ...farmaco,
      stock_total: stockTotal,
      lotes: lotes || []
    }
  });
});

/**
 * Crear nuevo fármaco
 * POST /api/inventario/farmacos
 */
export const crearFarmaco = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { data, error } = await supabase
    .from('farmacos')
    .insert(req.body)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al crear fármaco',
      message: error.message
    });
  }

  res.status(201).json({
    message: 'Fármaco creado exitosamente',
    farmaco: data
  });
});

/**
 * Obtener lotes de un fármaco
 * GET /api/inventario/farmacos/:id/lotes
 */
export const obtenerLotes = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { incluir_vencidos = 'false' } = req.query;

  let query = supabase
    .from('lotes_farmacos')
    .select('*')
    .eq('farmaco_id', id)
    .is('deleted_at', null)
    .order('fecha_vencimiento', { ascending: true });

  if (incluir_vencidos === 'false') {
    const hoy = new Date().toISOString().split('T')[0];
    query = query.gte('fecha_vencimiento', hoy);
  }

  const { data, error } = await query;

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener lotes',
      message: error.message
    });
  }

  res.json({
    lotes: data,
    total: data.length
  });
});

/**
 * Crear nuevo lote
 * POST /api/inventario/farmacos/:id/lotes
 */
export const crearLote = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const loteData = {
    farmaco_id: id,
    ...req.body,
    cantidad_actual: req.body.cantidad_inicial
  };

  const { data, error } = await supabase
    .from('lotes_farmacos')
    .insert(loteData)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al crear lote',
      message: error.message
    });
  }

  // Registrar movimiento de entrada
  await supabase
    .from('inventario_movimientos')
    .insert({
      lote_farmaco_id: data.id,
      tipo_movimiento: 'entrada',
      cantidad: data.cantidad_inicial,
      cantidad_anterior: 0,
      cantidad_posterior: data.cantidad_inicial,
      motivo: 'Ingreso inicial de lote',
      documento_referencia: req.body.documento_referencia,
      realizado_por: req.user.id
    });

  res.status(201).json({
    message: 'Lote creado exitosamente',
    lote: data
  });
});

/**
 * Obtener lotes próximos a vencer
 * GET /api/inventario/alertas/por-vencer
 */
export const obtenerLotesPorVencer = asyncHandler(async (req, res) => {
  const { dias = 90 } = req.query;

  const hoy = new Date();
  const fechaLimite = new Date();
  fechaLimite.setDate(hoy.getDate() + parseInt(dias));

  const { data, error } = await supabase
    .from('lotes_farmacos')
    .select(`
      *,
      farmaco:farmacos(
        id,
        nombre_comercial,
        nombre_generico,
        concentracion
      )
    `)
    .gte('fecha_vencimiento', hoy.toISOString().split('T')[0])
    .lte('fecha_vencimiento', fechaLimite.toISOString().split('T')[0])
    .eq('activo', true)
    .gt('cantidad_actual', 0)
    .is('deleted_at', null)
    .order('fecha_vencimiento', { ascending: true });

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener lotes por vencer',
      message: error.message
    });
  }

  res.json({
    lotes: data,
    total: data.length,
    dias_advertencia: parseInt(dias)
  });
});

/**
 * Obtener fármacos con bajo stock
 * GET /api/inventario/alertas/bajo-stock
 */
export const obtenerBajoStock = asyncHandler(async (req, res) => {
  const { data: farmacos, error } = await supabase
    .from('farmacos')
    .select('*')
    .eq('activo', true)
    .is('deleted_at', null);

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener fármacos',
      message: error.message
    });
  }

  // Filtrar fármacos con stock bajo
  const farmacosBajoStock = [];

  for (const farmaco of farmacos) {
    const { data: stockTotal } = await supabase
      .rpc('calcular_stock_total_farmaco', { farmaco_uuid: farmaco.id });

    if (stockTotal <= farmaco.stock_minimo) {
      farmacosBajoStock.push({
        ...farmaco,
        stock_actual: stockTotal || 0,
        diferencia: farmaco.stock_minimo - (stockTotal || 0)
      });
    }
  }

  res.json({
    farmacos: farmacosBajoStock,
    total: farmacosBajoStock.length
  });
});

/**
 * Registrar consumo de fármaco
 * POST /api/inventario/consumos
 */
export const registrarConsumo = asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const consumoData = {
    ...req.body,
    fecha_prescripcion: new Date().toISOString(),
    descontado_inventario: false // Se descuenta automáticamente con trigger
  };

  const { data, error } = await supabase
    .from('consumos_farmacos')
    .insert(consumoData)
    .select()
    .single();

  if (error) {
    return res.status(500).json({
      error: 'Error al registrar consumo',
      message: error.message
    });
  }

  res.status(201).json({
    message: 'Consumo registrado y descontado del inventario exitosamente',
    consumo: data
  });
});

/**
 * Obtener consumos de un episodio
 * GET /api/inventario/consumos/episodio/:episodio_id
 */
export const obtenerConsumosPorEpisodio = asyncHandler(async (req, res) => {
  const { episodio_id } = req.params;

  const { data, error } = await supabase
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
      ),
      prescrito_por_profesional:profesionales!consumos_farmacos_prescrito_por_fkey(
        id,
        matricula_profesional,
        user:users(nombre_completo)
      )
    `)
    .eq('episodio_id', episodio_id);

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener consumos',
      message: error.message
    });
  }

  res.json({
    consumos: data,
    total: data.length
  });
});

/**
 * Obtener movimientos de inventario
 * GET /api/inventario/movimientos
 */
export const obtenerMovimientos = asyncHandler(async (req, res) => {
  const {
    lote_id,
    tipo_movimiento,
    fecha_desde,
    fecha_hasta,
    page = 1,
    limit = 50
  } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('inventario_movimientos')
    .select(`
      *,
      lote:lotes_farmacos(
        id,
        numero_lote,
        farmaco:farmacos(nombre_comercial)
      ),
      usuario:users(nombre_completo)
    `, { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (lote_id) {
    query = query.eq('lote_farmaco_id', lote_id);
  }

  if (tipo_movimiento) {
    query = query.eq('tipo_movimiento', tipo_movimiento);
  }

  if (fecha_desde) {
    query = query.gte('created_at', fecha_desde);
  }

  if (fecha_hasta) {
    query = query.lte('created_at', fecha_hasta);
  }

  const { data, error, count } = await query;

  if (error) {
    return res.status(500).json({
      error: 'Error al obtener movimientos',
      message: error.message
    });
  }

  res.json({
    movimientos: data,
    pagination: {
      total: count,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(count / limit)
    }
  });
});

export default {
  obtenerFarmacos,
  obtenerFarmacoPorId,
  crearFarmaco,
  obtenerLotes,
  crearLote,
  obtenerLotesPorVencer,
  obtenerBajoStock,
  registrarConsumo,
  obtenerConsumosPorEpisodio,
  obtenerMovimientos
};
