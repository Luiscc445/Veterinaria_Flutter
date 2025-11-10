import express from 'express';
import { authenticate } from '../middlewares/authenticate.js';
import { requireAdmin } from '../middlewares/authorize.js';

const router = express.Router();

router.use(authenticate);

router.get('/', requireAdmin, (req, res) => {
  res.json({ message: 'Endpoint de users en desarrollo' });
});

export default router;
