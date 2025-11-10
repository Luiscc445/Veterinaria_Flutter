# 🐾 Sistema de Gestión Integral para Clínica Veterinaria "RamboPet"

Sistema completo de gestión veterinaria con Backend API REST, Frontend Web React y App Móvil Flutter, integrado con Supabase (PostgreSQL).

## 📋 Descripción del Proyecto

RamboPet es un sistema integral diseñado para clínicas veterinarias comunitarias que permite:

- **Tutores**: Registro de mascotas, reserva de citas, seguimiento de historial médico
- **Personal Médico**: Historia clínica electrónica, prescripción de medicamentos, gestión de consultas
- **Recepción**: Gestión de citas, check-in de pacientes, asignación de consultorios
- **Administración**: Control de inventario, reportes, dashboards, gestión de usuarios

## 🏗️ Arquitectura

### Stack Tecnológico

- **Backend**: Node.js + Express + TypeScript
- **Frontend Web**: React + Vite + TypeScript + TailwindCSS
- **App Móvil**: Flutter (Android e iOS)
- **Base de Datos**: Supabase (PostgreSQL)
- **Autenticación**: Supabase Auth con Row Level Security (RLS)
- **Almacenamiento**: Supabase Storage para adjuntos

### Roles de Usuario

1. **Admin**: Acceso total al sistema
2. **Médico**: Gestión de consultas, historiales clínicos, prescripción de medicamentos
3. **Recepción**: Gestión de citas, check-in, registro inicial
4. **Tutor**: Gestión de mascotas propias, reserva de citas, visualización de historial

## 📁 Estructura del Proyecto

```
rambopet/
├── backend/                 # API REST Node.js + Express
│   ├── src/
│   │   ├── config/         # Configuración (Supabase, etc.)
│   │   ├── routes/         # Rutas de la API
│   │   ├── controllers/    # Lógica de negocio
│   │   ├── middlewares/    # Autenticación, validación, errores
│   │   ├── models/         # Modelos de datos
│   │   ├── services/       # Servicios (Supabase, notificaciones)
│   │   └── utils/          # Utilidades
│   ├── .env               # Variables de entorno
│   ├── package.json
│   └── README.md
│
├── web/                    # Frontend React + Vite
│   ├── src/
│   │   ├── components/    # Componentes reutilizables
│   │   ├── pages/         # Páginas por rol
│   │   ├── services/      # Servicios API
│   │   ├── hooks/         # Custom hooks
│   │   ├── contexts/      # Contextos (Auth, Theme)
│   │   ├── types/         # TypeScript types
│   │   └── assets/        # Imágenes, íconos
│   ├── .env
│   ├── package.json
│   └── README.md
│
├── mobile/                 # App Flutter
│   ├── lib/
│   │   ├── core/          # Configuración, constantes, tema
│   │   ├── features/      # Módulos por funcionalidad
│   │   │   ├── auth/
│   │   │   ├── citas/
│   │   │   ├── mascotas/
│   │   │   ├── historial/
│   │   │   └── inventario/
│   │   └── shared/        # Widgets compartidos
│   ├── .env
│   ├── pubspec.yaml
│   └── README.md
│
└── database/               # Esquemas SQL
    ├── migrations/        # Migraciones
    ├── seeds/             # Datos iniciales
    ├── functions/         # Funciones SQL
    └── schema.sql         # Esquema completo
```

## 🚀 Inicio Rápido

### Pre-requisitos

- Node.js 18+ y npm/yarn
- Flutter 3.16+
- Git
- Cuenta de Supabase (ya configurada)

### 1. Configuración de Base de Datos

```bash
# 1. Accede a tu proyecto Supabase
# URL: https://dcahbgpeupxcqsybffhq.supabase.co

# 2. Ejecuta el esquema SQL
# Ve a SQL Editor en Supabase Dashboard
# Copia y ejecuta el contenido de database/schema.sql

# 3. Ejecuta las funciones almacenadas
# Ejecuta database/functions/*.sql

# 4. Ejecuta los seeds de datos iniciales
# Ejecuta database/seeds/*.sql
```

### 2. Configuración del Backend

```bash
cd backend

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con las credenciales de Supabase

# Iniciar servidor de desarrollo
npm run dev

# El servidor estará en http://localhost:3000
```

### 3. Configuración del Frontend Web

```bash
cd web

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con las credenciales de Supabase

# Iniciar servidor de desarrollo
npm run dev

# La app estará en http://localhost:5173
```

### 4. Configuración de App Móvil Flutter

```bash
cd mobile

# Obtener dependencias
flutter pub get

# Configurar variables de entorno
cp .env.example .env
# Editar .env con las credenciales de Supabase

# Ejecutar en dispositivo/emulador
flutter run

# Para Android
flutter run -d android

# Para iOS
flutter run -d ios
```

## 🔐 Credenciales de Supabase

Las credenciales están en los archivos `.env` de cada módulo:

```env
SUPABASE_URL=https://dcahbgpeupxcqsybffhq.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**⚠️ IMPORTANTE**: NO subas archivos `.env` a Git. Ya están incluidos en `.gitignore`.

## 📊 Funcionalidades Principales

### Para Tutores (Web + Móvil)

- ✅ Registro e inicio de sesión
- ✅ Gestión de mascotas (registro, edición, historial)
- ✅ Reserva de citas (selección de servicio, médico, horario)
- ✅ Confirmaciones y recordatorios de citas
- ✅ Visualización de historial médico de mascotas
- ✅ Notificaciones push de citas

### Para Personal Médico (Web + Móvil)

- ✅ Agenda del día con citas asignadas
- ✅ Historia clínica electrónica (HCE)
- ✅ Registro de episodios/consultas
- ✅ Prescripción de medicamentos
- ✅ Descuento automático de inventario
- ✅ Adjuntar archivos/imágenes a historiales
- ✅ Consulta rápida de pacientes

### Para Recepción (Web)

- ✅ Gestión de agenda central
- ✅ Check-in de pacientes
- ✅ Asignación de consultorios
- ✅ Aprobación de nuevas mascotas
- ✅ Gestión de estados de citas

### Para Administración (Web)

- ✅ Gestión de usuarios y roles
- ✅ Control de inventario de fármacos
- ✅ Gestión de lotes y vencimientos
- ✅ Alertas de bajo stock
- ✅ Reportes operativos
- ✅ Dashboards con KPIs
- ✅ Auditoría de acciones

## 🔒 Seguridad

- **Row Level Security (RLS)**: Políticas estrictas por rol en Supabase
- **Autenticación JWT**: Con Supabase Auth
- **Validación de datos**: En frontend y backend
- **Auditoría completa**: Registro de todas las acciones importantes
- **Soft deletes**: No se elimina información, solo se marca como inactiva
- **HTTPS obligatorio**: En producción

## 📈 Modelo de Datos

### Tablas Principales

- `users`: Usuarios del sistema con roles
- `tutores`: Dueños de mascotas
- `mascotas`: Pacientes (con aprobación)
- `citas`: Sistema de citas con estados
- `servicios`: Tipos de servicios (consulta, vacunación, etc.)
- `profesionales`: Médicos veterinarios
- `consultorios`: Salas de atención
- `historias_clinicas`: HCE por mascota
- `episodios`: Consultas individuales
- `adjuntos`: Archivos e imágenes
- `farmacos`: Catálogo de medicamentos
- `lotes_farmacos`: Control de stock y vencimientos
- `inventario_movimientos`: Entradas/salidas
- `consumos_farmacos`: Prescripciones por episodio
- `auditoria`: Trazabilidad completa

Ver esquema completo en `database/schema.sql`

## 🧪 Testing

### Backend
```bash
cd backend
npm test
npm run test:coverage
```

### Frontend Web
```bash
cd web
npm test
npm run test:e2e
```

### Mobile
```bash
cd mobile
flutter test
flutter test integration_test
```

## 📦 Deployment

### Backend (Railway, Render, DigitalOcean)

```bash
# Build de producción
npm run build

# Iniciar en producción
npm start
```

### Frontend Web (Vercel, Netlify)

```bash
# Build de producción
npm run build

# La carpeta dist/ contiene los archivos estáticos
```

### Mobile (Play Store, App Store)

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📚 Documentación Adicional

- [Backend API Documentation](backend/README.md)
- [Frontend Web Documentation](web/README.md)
- [Mobile App Documentation](mobile/README.md)
- [Database Schema](database/README.md)

## 🤝 Contribución

Este es un proyecto privado para la Clínica Veterinaria RamboPet.

## 📄 Licencia

Propietario - Clínica Veterinaria RamboPet © 2025

## 👥 Equipo de Desarrollo

Desarrollado con ❤️ para RamboPet

## 📞 Soporte

Para soporte técnico, contactar a: [soporte@rambopet.com](mailto:soporte@rambopet.com)

---

**Versión**: 1.0.0
**Última actualización**: Noviembre 2025
