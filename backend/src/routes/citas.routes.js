/**
 * Rutas de Citas
 */

import express from 'express';
import { body, query } from 'express-validator';
import {
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
} from '../controllers/citas.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requirePersonal, requireMedico, requireRecepcion } from '../middlewares/authorize.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(authenticate);

// Validaciones
const citaValidation = [
  body('mascota_id').isUUID().withMessage('mascota_id debe ser un UUID válido'),
  body('servicio_id').isUUID().withMessage('servicio_id debe ser un UUID válido'),
  body('profesional_id').isUUID().withMessage('profesional_id debe ser un UUID válido'),
  body('fecha_hora').isISO8601().withMessage('fecha_hora debe ser una fecha válida'),
  body('motivo_consulta').notEmpty().withMessage('El motivo de consulta es requerido')
];

// Rutas públicas para autenticados
router.get('/mis-citas', obtenerCitasPropias);
router.get('/disponibilidad', [
  query('profesional_id').isUUID(),
  query('fecha').isDate(),
  query('servicio_id').isUUID()
], obtenerDisponibilidad);
router.get('/:id', obtenerCitaPorId);
router.post('/', citaValidation, crearCita);
router.put('/:id', actualizarCita);
router.post('/:id/cancelar', cancelarCita);

// Rutas para personal
router.get('/', requirePersonal, obtenerTodasCitas);

// Rutas para médicos
router.get('/profesional/mis-citas', requireMedico, obtenerCitasProfesional);
router.post('/:id/iniciar-atencion', requireMedico, iniciarAtencion);
router.post('/:id/finalizar-atencion', requireMedico, finalizarAtencion);

// Rutas para recepción
router.post('/:id/confirmar', requireRecepcion, confirmarCita);
router.post('/:id/check-in', requireRecepcion, checkInCita);

export default router;
