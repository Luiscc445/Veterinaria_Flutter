# 🐾 RamboPet Web - Frontend Administrativo

Frontend web administrativo del Sistema de Gestión Veterinaria RamboPet, desarrollado con React, Vite, TypeScript y TailwindCSS.

## 🚀 Tecnologías

- **React 18** - Biblioteca UI
- **Vite** - Build tool y dev server
- **TypeScript** - Tipado estático
- **TailwindCSS** - Framework CSS
- **Supabase** - Backend as a Service
- **React Router** - Enrutamiento
- **date-fns** - Manejo de fechas

## 📋 Requisitos Previos

- Node.js 18+ y npm
- Cuenta de Supabase configurada
- Base de datos ejecutada (ver `/database/schema.sql`)

## 🔧 Instalación

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de Supabase

# Iniciar servidor de desarrollo
npm run dev
```

La aplicación estará disponible en `http://localhost:5173`

## 📁 Estructura del Proyecto

```
web/
├── src/
│   ├── components/       # Componentes reutilizables
│   │   ├── auth/        # Componentes de autenticación
│   │   ├── dashboard/   # Componentes del dashboard
│   │   ├── layout/      # Layout principal y sidebar
│   │   ├── mascotas/    # Componentes de mascotas
│   │   ├── citas/       # Componentes de citas
│   │   └── inventario/  # Componentes de inventario
│   ├── pages/           # Páginas principales
│   │   ├── auth/        # Login, Register
│   │   ├── DashboardPage.tsx
│   │   ├── MascotasPage.tsx
│   │   ├── CitasPage.tsx
│   │   └── InventarioPage.tsx
│   ├── services/        # Servicios API
│   │   └── supabase.ts  # Cliente de Supabase
│   ├── types/           # TypeScript types
│   ├── App.tsx          # Componente principal
│   ├── main.tsx         # Punto de entrada
│   └── index.css        # Estilos globales
├── index.html
├── package.json
├── vite.config.ts
├── tailwind.config.js
└── tsconfig.json
```

## 🎯 Funcionalidades

### Dashboard
- ✅ Estadísticas generales (total mascotas, citas, etc.)
- ✅ Resumen de actividad del día
- ✅ Alertas y notificaciones

### Gestión de Mascotas
- ✅ Lista de todas las mascotas registradas
- ✅ Filtros por estado (pendiente, aprobado, rechazado)
- ✅ Aprobación/rechazo de nuevas mascotas
- ✅ Visualización de detalles

### Gestión de Citas
- ✅ Lista de todas las citas
- ✅ Filtros por estado
- ✅ Confirmación de citas reservadas
- ✅ Visualización de detalles de mascota y servicio

### Gestión de Inventario
- ✅ Lista de medicamentos disponibles
- ✅ Control de stock actual vs stock mínimo
- ✅ Alertas de stock bajo
- ✅ Visualización de lotes

## 🔒 Autenticación

El sistema utiliza Supabase Auth para autenticación:

- Login con email y contraseña
- Sesión persistente con JWT
- Cierre de sesión seguro

## 🎨 Estilos

El proyecto utiliza TailwindCSS con una paleta de colores personalizada:

- **Primary**: Azul (#2196f3)
- **Secondary**: Naranja (#ff9800)
- **Accent**: Verde (#4caf50)

## 🛠️ Scripts Disponibles

```bash
# Desarrollo
npm run dev

# Build de producción
npm run build

# Preview del build
npm run preview

# Linting
npm run lint
```

## 📦 Build de Producción

```bash
# Crear build optimizado
npm run build

# La carpeta dist/ contendrá los archivos estáticos
```

## 🌐 Deploy

### Vercel
```bash
vercel --prod
```

### Netlify
```bash
netlify deploy --prod
```

## 🔧 Variables de Entorno

```env
VITE_SUPABASE_URL=tu_supabase_url
VITE_SUPABASE_ANON_KEY=tu_supabase_anon_key
```

## 📝 Notas Importantes

- Todas las variables de entorno deben tener el prefijo `VITE_`
- El archivo `.env` no debe subirse a Git
- Las políticas RLS de Supabase deben estar correctamente configuradas
- Se recomienda ejecutar el script `fix_rls_policies_v2.sql` antes de usar la app

## 🤝 Integración con App Móvil

El frontend web comparte la misma base de datos con la app móvil Flutter:

- Ambas usan el mismo proyecto de Supabase
- Los cambios se reflejan en tiempo real
- Autenticación compartida

## 📄 Licencia

Propietario - Clínica Veterinaria RamboPet © 2025
