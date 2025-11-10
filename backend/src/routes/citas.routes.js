import express from 'express';
import { authenticate } from '../middlewares/authenticate.js';

const router = express.Router();
router.use(authenticate);

router.get('/', (req, res) => {
  res.json({ message: 'Endpoint de citas en desarrollo' });
});

router.post('/', (req, res) => {
  res.json({ message: 'Crear cita - en desarrollo' });
});

export default router;
