# 🐾 RamboPet Backend API

API REST para el Sistema de Gestión Veterinaria RamboPet construida con Node.js, Express y Supabase.

## 📋 Características

- Autenticación JWT con Supabase Auth
- Row Level Security (RLS) para control de acceso
- Endpoints RESTful documentados
- Validación de datos con express-validator
- Rate limiting para seguridad
- Manejo de errores estandarizado
- Auditoría automática de acciones
- Soporte para múltiples roles (admin, médico, recepción, tutor)

## 🛠️ Tecnologías

- Node.js 18+
- Express 4.18
- Supabase Client 2.39
- PostgreSQL (vía Supabase)
- ES Modules

## 📦 Instalación

```bash
# Clonar el repositorio
cd backend

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de Supabase

# Iniciar servidor de desarrollo
npm run dev
```

## ⚙️ Configuración

### Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto backend:

```env
PORT=3000
NODE_ENV=development

SUPABASE_URL=https://dcahbgpeupxcqsybffhq.supabase.co
SUPABASE_ANON_KEY=tu_clave_anonima
SUPABASE_SERVICE_KEY=tu_clave_de_servicio

JWT_SECRET=tu_secret_muy_seguro
CORS_ORIGIN=http://localhost:5173,http://localhost:3000
```

### Base de Datos

Antes de ejecutar el backend, asegúrate de:

1. Ejecutar el esquema SQL: `database/schema.sql`
2. Ejecutar los seeds: `database/seeds/01_initial_data.sql`

## 🚀 Uso

### Iniciar el servidor

```bash
# Modo desarrollo (con hot-reload)
npm run dev

# Modo producción
npm start
```

### Verificar que funciona

```bash
# Health check
curl http://localhost:3000/health

# Respuesta esperada:
# {"status":"ok","timestamp":"2025-11-10T...","service":"RamboPet API","version":"1.0.0"}
```

## 📚 Endpoints

### Autenticación

```
POST   /api/auth/register          - Registrar nuevo usuario
POST   /api/auth/login             - Iniciar sesión
POST   /api/auth/logout            - Cerrar sesión
POST   /api/auth/refresh-token     - Refrescar token
GET    /api/auth/me                - Obtener usuario actual
PUT    /api/auth/profile           - Actualizar perfil
POST   /api/auth/change-password   - Cambiar contraseña
POST   /api/auth/reset-password-request  - Solicitar reset
```

### Mascotas

```
GET    /api/mascotas               - Listar todas (admin/recepción)
GET    /api/mascotas/mis-mascotas  - Mascotas propias (tutor)
GET    /api/mascotas/:id           - Obtener una mascota
POST   /api/mascotas               - Crear mascota
PUT    /api/mascotas/:id           - Actualizar mascota
DELETE /api/mascotas/:id           - Eliminar mascota
GET    /api/mascotas/estado/pendientes - Mascotas pendientes
POST   /api/mascotas/:id/aprobar   - Aprobar mascota
POST   /api/mascotas/:id/rechazar  - Rechazar mascota
```

### Citas

```
GET    /api/citas                  - Listar citas
POST   /api/citas                  - Crear cita
GET    /api/citas/:id              - Obtener cita
PUT    /api/citas/:id              - Actualizar cita
DELETE /api/citas/:id              - Cancelar cita
```

### Otros Módulos

- `/api/users` - Gestión de usuarios
- `/api/tutores` - Gestión de tutores
- `/api/servicios` - Catálogo de servicios
- `/api/profesionales` - Médicos veterinarios
- `/api/consultorios` - Salas de atención
- `/api/historias` - Historias clínicas
- `/api/episodios` - Consultas/episodios
- `/api/farmacos` - Catálogo de medicamentos
- `/api/inventario` - Control de inventario
- `/api/reportes` - Reportes y dashboards

## 🔐 Autenticación

Todos los endpoints (excepto registro y login) requieren un token JWT válido en el header:

```bash
Authorization: Bearer <tu_token_jwt>
```

### Ejemplo de uso

```javascript
// Login
const response = await fetch('http://localhost:3000/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123'
  })
});

const { access_token, user } = await response.json();

// Usar token en otras peticiones
const mascotas = await fetch('http://localhost:3000/api/mascotas/mis-mascotas', {
  headers: { 'Authorization': `Bearer ${access_token}` }
});
```

## 👥 Roles y Permisos

### Admin
- Acceso total al sistema
- Gestión de usuarios
- Aprobación de mascotas
- Reportes completos

### Médico
- Gestión de historias clínicas
- Prescripción de medicamentos
- Acceso a agenda de citas
- Consulta de pacientes asignados

### Recepción
- Gestión de citas
- Check-in de pacientes
- Aprobación de mascotas
- Asignación de consultorios

### Tutor
- Gestión de mascotas propias
- Reserva de citas
- Visualización de historial médico
- Actualización de perfil

## 🧪 Testing

```bash
# Ejecutar tests
npm test

# Con coverage
npm run test:coverage
```

## 📝 Lint

```bash
# Verificar código
npm run lint

# Corregir automáticamente
npm run lint:fix
```

## 🐛 Debugging

El servidor usa `morgan` para logging de peticiones HTTP.

En modo desarrollo, verás logs detallados de cada petición:

```
POST /api/auth/login 200 245ms
GET /api/mascotas/mis-mascotas 200 89ms
```

## 🚦 Rate Limiting

- General: 100 requests por 15 minutos
- Login: 5 intentos por 15 minutos
- Registro: 3 registros por hora

## ⚠️ Errores Comunes

### Error: "Token inválido o expirado"
- Verifica que el token esté en el header correcto
- El token expira después de 1 hora, usa refresh token

### Error: "Acceso denegado"
- Tu rol no tiene permisos para ese endpoint
- Verifica que tu usuario esté activo

### Error: "Conexión con Supabase fallida"
- Verifica las credenciales en `.env`
- Asegúrate que el esquema SQL esté ejecutado

## 📦 Estructura del Código

```
src/
├── config/          # Configuración (Supabase, etc.)
├── controllers/     # Lógica de negocio
├── middlewares/     # Auth, validación, errores
├── models/          # Modelos de datos
├── routes/          # Definición de rutas
├── services/        # Servicios externos
├── utils/           # Utilidades
└── index.js         # Punto de entrada
```

## 🔄 Ciclo de vida de una petición

1. Cliente envía petición con token
2. `authenticate` middleware verifica token
3. `authorize` middleware verifica permisos
4. `validationResult` valida datos de entrada
5. Controller ejecuta lógica de negocio
6. Supabase ejecuta query con RLS
7. Response enviada al cliente
8. `errorHandler` captura cualquier error

## 📄 Licencia

Propietario - RamboPet © 2025

## 👨‍💻 Desarrollador

Desarrollado para RamboPet Veterinaria

---

**Versión**: 1.0.0
