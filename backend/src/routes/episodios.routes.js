/**
 * Rutas de Episodios
 */

import express from 'express';
import {
  obtenerEpisodioPorId,
  actualizarEpisodio,
  agregarAdjunto
} from '../controllers/historias.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requireMedico } from '../middlewares/authorize.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(authenticate);

// Rutas de episodios individuales
router.get('/:id', obtenerEpisodioPorId);
router.put('/:id', requireMedico, actualizarEpisodio);
router.post('/:id/adjuntos', requireMedico, agregarAdjunto);

export default router;
