import express from 'express';
import { authenticate } from '../middlewares/authenticate.js';
import { requirePersonal } from '../middlewares/authorize.js';

const router = express.Router();
router.use(authenticate);
router.use(requirePersonal);

router.get('/dashboard', (req, res) => {
  res.json({ message: 'Endpoint de reportes/dashboard en desarrollo' });
});

export default router;
