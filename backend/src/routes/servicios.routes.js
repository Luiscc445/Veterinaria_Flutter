import express from 'express';
import { authenticate } from '../middlewares/authenticate.js';
import {
  obtenerServicios,
  obtenerServicioPorId
} from '../controllers/servicios.controller.js';

const router = express.Router();
router.use(authenticate);

router.get('/', obtenerServicios);
router.get('/:id', obtenerServicioPorId);

export default router;
