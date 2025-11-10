import express from 'express';
import { authenticate } from '../middlewares/authenticate.js';
import {
  obtenerProfesionales,
  obtenerProfesionalPorId,
  obtenerHorarioProfesional
} from '../controllers/profesionales.controller.js';

const router = express.Router();
router.use(authenticate);

router.get('/', obtenerProfesionales);
router.get('/:id', obtenerProfesionalPorId);
router.get('/:id/horario', obtenerHorarioProfesional);

export default router;
