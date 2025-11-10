/**
 * RamboPet Backend API
 * Punto de entrada principal del servidor
 */

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

// Importar configuración
import { supabase } from './config/supabase.js';
import { errorHandler } from './middlewares/errorHandler.js';
import { rateLimiter } from './middlewares/rateLimiter.js';

// Importar rutas
import authRoutes from './routes/auth.routes.js';
import usersRoutes from './routes/users.routes.js';
import tutoresRoutes from './routes/tutores.routes.js';
import mascotasRoutes from './routes/mascotas.routes.js';
import citasRoutes from './routes/citas.routes.js';
import serviciosRoutes from './routes/servicios.routes.js';
import profesionalesRoutes from './routes/profesionales.routes.js';
import consultoriosRoutes from './routes/consultorios.routes.js';
import historiasRoutes from './routes/historias.routes.js';
import episodiosRoutes from './routes/episodios.routes.js';
import farmacosRoutes from './routes/farmacos.routes.js';
import inventarioRoutes from './routes/inventario.routes.js';
import reportesRoutes from './routes/reportes.routes.js';

// Configurar __dirname para ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Cargar variables de entorno
dotenv.config({ path: join(__dirname, '../.env') });

const app = express();
const PORT = process.env.PORT || 3000;

// ============================================================================
// MIDDLEWARES GLOBALES
// ============================================================================

// Seguridad con Helmet
app.use(helmet());

// Compresión de respuestas
app.use(compression());

// CORS configurado
const corsOptions = {
  origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:5173'],
  credentials: true,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

// Parser de JSON y URL encoded
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logger de peticiones HTTP
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Rate limiting
app.use(rateLimiter);

// ============================================================================
// RUTAS
// ============================================================================

// Ruta de health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'RamboPet API',
    version: '1.0.0'
  });
});

// Ruta raíz con información de la API
app.get('/', (req, res) => {
  res.json({
    message: 'Bienvenido a RamboPet API',
    version: '1.0.0',
    documentation: '/api-docs',
    endpoints: {
      auth: '/api/auth',
      users: '/api/users',
      tutores: '/api/tutores',
      mascotas: '/api/mascotas',
      citas: '/api/citas',
      servicios: '/api/servicios',
      profesionales: '/api/profesionales',
      consultorios: '/api/consultorios',
      historias: '/api/historias',
      episodios: '/api/episodios',
      farmacos: '/api/farmacos',
      inventario: '/api/inventario',
      reportes: '/api/reportes'
    }
  });
});

// Rutas de la API
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/tutores', tutoresRoutes);
app.use('/api/mascotas', mascotasRoutes);
app.use('/api/citas', citasRoutes);
app.use('/api/servicios', serviciosRoutes);
app.use('/api/profesionales', profesionalesRoutes);
app.use('/api/consultorios', consultoriosRoutes);
app.use('/api/historias', historiasRoutes);
app.use('/api/episodios', episodiosRoutes);
app.use('/api/farmacos', farmacosRoutes);
app.use('/api/inventario', inventarioRoutes);
app.use('/api/reportes', reportesRoutes);

// Ruta 404 - No encontrado
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Ruta no encontrada',
    path: req.originalUrl
  });
});

// ============================================================================
// MANEJO DE ERRORES
// ============================================================================

app.use(errorHandler);

// ============================================================================
// INICIO DEL SERVIDOR
// ============================================================================

const server = app.listen(PORT, async () => {
  console.log('🐾 ========================================');
  console.log('🐾 RamboPet API - Sistema Veterinario');
  console.log('🐾 ========================================');
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
  console.log(`🌍 Entorno: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📝 Logs: ${process.env.LOG_LEVEL || 'info'}`);
  console.log(`🔗 URL: http://localhost:${PORT}`);
  console.log('🐾 ========================================');

  // Verificar conexión con Supabase
  try {
    const { data, error } = await supabase
      .from('users')
      .select('count')
      .limit(1);

    if (error) {
      console.error('❌ Error conectando con Supabase:', error.message);
    } else {
      console.log('✅ Conexión con Supabase exitosa');
    }
  } catch (error) {
    console.error('❌ Error verificando Supabase:', error.message);
  }
});

// Manejo de errores no capturados
process.on('unhandledRejection', (err) => {
  console.error('❌ UNHANDLED REJECTION:', err);
  server.close(() => {
    process.exit(1);
  });
});

process.on('uncaughtException', (err) => {
  console.error('❌ UNCAUGHT EXCEPTION:', err);
  process.exit(1);
});

// Manejo de cierre graceful
process.on('SIGTERM', () => {
  console.log('👋 SIGTERM recibido, cerrando servidor...');
  server.close(() => {
    console.log('✅ Servidor cerrado correctamente');
    process.exit(0);
  });
});

export default app;
