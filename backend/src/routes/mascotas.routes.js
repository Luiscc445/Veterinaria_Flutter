/**
 * Rutas de Mascotas
 */

import express from 'express';
import { body } from 'express-validator';
import {
  obtenerTodasMascotas,
  obtenerMascotasPropias,
  obtenerMascotaPorId,
  crearMascota,
  actualizarMascota,
  eliminarMascota,
  aprobarMascota,
  rechazarMascota,
  obtenerMascotasPendientes
} from '../controllers/mascotas.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requireAdmin, requireRecepcion, requirePersonal } from '../middlewares/authorize.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(authenticate);

// Validaciones
const mascotaValidation = [
  body('nombre').notEmpty().withMessage('El nombre es requerido'),
  body('especie').notEmpty().withMessage('La especie es requerida'),
  body('sexo').optional().isIn(['macho', 'hembra']).withMessage('Sexo inválido'),
  body('fecha_nacimiento').optional().isISO8601().withMessage('Fecha inválida')
];

// Rutas para todos los autenticados
router.get('/mis-mascotas', obtenerMascotasPropias);
router.get('/:id', obtenerMascotaPorId);
router.post('/', mascotaValidation, crearMascota);
router.put('/:id', mascotaValidation, actualizarMascota);
router.delete('/:id', eliminarMascota);

// Rutas solo para admin y recepción
router.get('/', requirePersonal, obtenerTodasMascotas);
router.get('/estado/pendientes', requirePersonal, obtenerMascotasPendientes);
router.post('/:id/aprobar', requirePersonal, aprobarMascota);
router.post('/:id/rechazar', requirePersonal, rechazarMascota);

export default router;
