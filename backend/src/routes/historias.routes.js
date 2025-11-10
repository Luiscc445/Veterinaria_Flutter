import express from 'express';
import { authenticate } from '../middlewares/authenticate.js';

const router = express.Router();
router.use(authenticate);

router.get('/', (req, res) => {
  res.json({ message: 'Endpoint de historias clínicas en desarrollo' });
});

export default router;
