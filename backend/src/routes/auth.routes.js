/**
 * Rutas de Autenticación
 */

import express from 'express';
import { body } from 'express-validator';
import {
  register,
  login,
  logout,
  refreshToken,
  getCurrentUser,
  updateProfile,
  changePassword,
  resetPasswordRequest,
  resetPassword
} from '../controllers/auth.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { authRateLimiter, registerRateLimiter } from '../middlewares/rateLimiter.js';

const router = express.Router();

// Validaciones
const registerValidation = [
  body('email').isEmail().withMessage('Email inválido'),
  body('password').isLength({ min: 6 }).withMessage('La contraseña debe tener al menos 6 caracteres'),
  body('nombre_completo').notEmpty().withMessage('El nombre completo es requerido'),
  body('telefono').optional().isMobilePhone('es-AR').withMessage('Teléfono inválido'),
  body('rol').optional().isIn(['tutor', 'medico', 'recepcion', 'admin']).withMessage('Rol inválido')
];

const loginValidation = [
  body('email').isEmail().withMessage('Email inválido'),
  body('password').notEmpty().withMessage('La contraseña es requerida')
];

// Rutas públicas
router.post('/register', registerRateLimiter, registerValidation, register);
router.post('/login', authRateLimiter, loginValidation, login);
router.post('/refresh-token', refreshToken);
router.post('/reset-password-request', body('email').isEmail(), resetPasswordRequest);
router.post('/reset-password', body('password').isLength({ min: 6 }), resetPassword);

// Rutas protegidas (requieren autenticación)
router.use(authenticate);

router.get('/me', getCurrentUser);
router.put('/profile', updateProfile);
router.post('/change-password', changePassword);
router.post('/logout', logout);

export default router;
