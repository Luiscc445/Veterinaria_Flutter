/**
 * Rutas de Historias Clínicas
 */

import express from 'express';
import { body } from 'express-validator';
import {
  obtenerHistoriaPorMascota,
  obtenerHistoriaPorId,
  obtenerEpisodios,
  crearEpisodio,
  actualizarEpisodio,
  obtenerEpisodioPorId,
  agregarAdjunto
} from '../controllers/historias.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requireMedico, requirePersonal } from '../middlewares/authorize.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(authenticate);

// Validaciones para episodio
const episodioValidation = [
  body('profesional_id').isUUID().withMessage('profesional_id debe ser un UUID válido'),
  body('tipo_episodio').notEmpty().withMessage('El tipo de episodio es requerido'),
  body('motivo_consulta').notEmpty().withMessage('El motivo de consulta es requerido')
];

// Rutas de historias clínicas
router.get('/mascota/:mascota_id', obtenerHistoriaPorMascota);
router.get('/:id', obtenerHistoriaPorId);

// Rutas de episodios
router.get('/:id/episodios', obtenerEpisodios);
router.post('/:id/episodios', requireMedico, episodioValidation, crearEpisodio);

export default router;
