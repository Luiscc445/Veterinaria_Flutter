/**
 * Rutas de Inventario de Fármacos
 */

import express from 'express';
import { body } from 'express-validator';
import {
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
} from '../controllers/inventario.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requireAdmin, requireMedico, requirePersonal } from '../middlewares/authorize.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(authenticate);

// Validaciones
const farmacoValidation = [
  body('nombre_comercial').notEmpty().withMessage('El nombre comercial es requerido'),
  body('nombre_generico').notEmpty().withMessage('El nombre genérico es requerido'),
  body('principio_activo').notEmpty().withMessage('El principio activo es requerido')
];

const consumoValidation = [
  body('episodio_id').isUUID().withMessage('episodio_id debe ser un UUID válido'),
  body('mascota_id').isUUID().withMessage('mascota_id debe ser un UUID válido'),
  body('farmaco_id').isUUID().withMessage('farmaco_id debe ser un UUID válido'),
  body('prescrito_por').isUUID().withMessage('prescrito_por debe ser un UUID válido'),
  body('cantidad').isFloat({ min: 0 }).withMessage('La cantidad debe ser mayor a 0'),
  body('dosis_indicada').notEmpty().withMessage('La dosis indicada es requerida'),
  body('frecuencia').notEmpty().withMessage('La frecuencia es requerida'),
  body('via_administracion').notEmpty().withMessage('La vía de administración es requerida')
];

// Rutas de fármacos
router.get('/farmacos', obtenerFarmacos);
router.get('/farmacos/:id', obtenerFarmacoPorId);
router.post('/farmacos', requireAdmin, farmacoValidation, crearFarmaco);

// Rutas de lotes
router.get('/farmacos/:id/lotes', obtenerLotes);
router.post('/farmacos/:id/lotes', requireAdmin, crearLote);

// Alertas
router.get('/alertas/por-vencer', requirePersonal, obtenerLotesPorVencer);
router.get('/alertas/bajo-stock', requirePersonal, obtenerBajoStock);

// Consumos
router.post('/consumos', requireMedico, consumoValidation, registrarConsumo);
router.get('/consumos/episodio/:episodio_id', obtenerConsumosPorEpisodio);

// Movimientos
router.get('/movimientos', requirePersonal, obtenerMovimientos);

export default router;
