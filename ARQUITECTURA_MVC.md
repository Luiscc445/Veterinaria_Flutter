# 🏗️ ARQUITECTURA MVC - PROYECTO RAMBOPET

## 📐 PATRÓN MVC (Modelo-Vista-Controlador)

Ambos proyectos (Web y Móvil) ahora siguen la arquitectura **MVC** para mejor organización, mantenibilidad y escalabilidad.

---

## 🖥️ PROYECTO WEB (React + TypeScript)

### **Estructura MVC:**

```
web/src/
├── models/              # 📦 MODELOS - Definiciones de datos
│   ├── Mascota.ts      # Interfaz y tipos de Mascota
│   ├── Cita.ts         # Interfaz y tipos de Cita
│   └── ...
├── controllers/         # 🎮 CONTROLADORES - Lógica de negocio
│   ├── MascotasController.ts    # Lógica de mascotas
│   ├── CitasController.ts       # Lógica de citas
│   └── ...
├── views/               # 👁️ VISTAS - UI Components
│   ├── pages/          # Páginas principales
│   ├── components/     # Componentes reutilizables
│   └── layout/         # Layouts
├── services/           # 🔌 SERVICIOS - Integración externa
│   └── supabase.ts    # Cliente Supabase
└── types/             # 📝 TIPOS compartidos
```

### **Flujo de Datos:**

```
Usuario → Vista → Controlador → Modelo → Supabase
                     ↓
              Vista actualizada
```

### **Ejemplo de uso:**

```typescript
// ❌ ANTES (sin MVC)
const handleAprobar = async (id: string) => {
  const { error } = await supabase
    .from('mascotas')
    .update({ estado: 'aprobado' })
    .eq('id', id)
  // ...
}

// ✅ AHORA (con MVC)
import { MascotasController } from '../controllers/MascotasController'

const handleAprobar = async (id: string) => {
  await MascotasController.aprobar(id)
  // La lógica completa está en el controlador
}
```

---

## 📱 PROYECTO MÓVIL (Flutter + Dart)

### **Estructura MVC:**

```
mobile/lib/
├── shared/
│   └── models/         # 📦 MODELOS - Definiciones de datos
│       ├── mascota_model.dart
│       ├── cita_model.dart
│       └── ...
├── features/
│   ├── mascotas/
│   │   ├── data/       # 🎮 CONTROLADOR (Servicios)
│   │   │   └── mascotas_service.dart
│   │   └── presentation/  # 👁️ VISTAS
│   │       ├── pages/
│   │       ├── providers/
│   │       └── widgets/
│   └── citas/
│       ├── data/       # 🎮 CONTROLADOR
│       │   └── citas_service.dart
│       └── presentation/  # 👁️ VISTAS
│           ├── pages/
│           ├── providers/
│           └── widgets/
└── core/
    └── config/         # 🔌 SERVICIOS
        └── supabase_config.dart
```

### **Flujo de Datos:**

```
Usuario → Widget (Vista) → Provider → Service (Controlador) → Model → Supabase
                                          ↓
                               Widget actualizado (setState)
```

### **Ejemplo de uso:**

```dart
// ❌ ANTES (sin MVC, con queries directas)
Future<void> loadMascotas() async {
  final response = await supabase
      .from('mascotas')
      .select()
      .eq('tutor_id', tutorId);
  // ...
}

// ✅ AHORA (con MVC y funciones SQL seguras)
final service = MascotasService();

Future<void> loadMascotas() async {
  final mascotas = await service.obtenerMisMascotas();
  // El servicio llama a la función SQL segura
}
```

---

## 🔐 FUNCIONES SQL SEGURAS

Para evitar errores de "permission denied", creamos **funciones SQL con SECURITY DEFINER** que se ejecutan con permisos elevados.

### **Funciones Creadas:**

| Función | Descripción | Uso |
|---------|-------------|-----|
| `get_current_tutor_id()` | Obtiene el tutor_id del usuario autenticado | Todas las operaciones de tutores |
| `get_current_user_data()` | Obtiene datos completos del usuario | Login, perfil |
| `get_my_mascotas()` | Obtiene mascotas del tutor actual | Lista de mascotas (móvil) |
| `get_my_citas()` | Obtiene citas del tutor actual | Lista de citas (móvil) |
| `create_mascota()` | Crea una mascota para el tutor actual | Registro de mascota |
| `create_cita()` | Crea una cita para el tutor actual | Agendar cita |

### **Ventajas:**

✅ **Sin errores de permisos** - SECURITY DEFINER evita problemas de RLS
✅ **Código más limpio** - No necesitas queries complejas
✅ **Seguridad mejorada** - La lógica está en el servidor
✅ **Reutilizable** - Mismas funciones para web y móvil

### **Ejemplo SQL:**

```sql
CREATE OR REPLACE FUNCTION get_my_mascotas()
RETURNS TABLE (...)
LANGUAGE plpgsql
SECURITY DEFINER  -- ← Clave: se ejecuta como propietario, no como usuario
AS $$
BEGIN
    RETURN QUERY
    SELECT ...
    FROM mascotas m
    WHERE m.tutor_id = get_current_tutor_id()
    ORDER BY m.created_at DESC;
END;
$$;
```

---

## 🔄 COMUNICACIÓN WEB ↔ MÓVIL

### **Base de Datos Compartida:**

```
┌─────────────────┐      ┌──────────────┐      ┌─────────────────┐
│   App Móvil     │      │   Supabase   │      │   Frontend Web  │
│   (Flutter)     │◄────►│  PostgreSQL  │◄────►│   (React)       │
└─────────────────┘      └──────────────┘      └─────────────────┘
       ↓                        ↓                       ↓
  get_my_mascotas()     Funciones SQL          SELECT * FROM mascotas
  get_my_citas()        SECURITY DEFINER       WHERE ...
```

### **Sincronización en Tiempo Real:**

**Ejemplo:**
1. **Tutor registra mascota en app móvil** → Estado: `pendiente`
2. **Admin aprueba mascota en web** → Estado: `aprobado`
3. **Tutor ve cambio en app móvil** → Automáticamente actualizado

### **Código de ejemplo:**

```typescript
// Web: Aprobar mascota
await MascotasController.aprobar(mascotaId)

// Móvil: Recargar automáticamente (usando providers)
final mascotas = await service.obtenerMisMascotas()
// La mascota ahora aparece como "aprobada"
```

---

## 📝 VENTAJAS DE LA ARQUITECTURA MVC

### **1. Separación de responsabilidades**
- **Modelos**: Solo definen datos
- **Controladores**: Solo lógica de negocio
- **Vistas**: Solo interfaz de usuario

### **2. Mantenibilidad**
- Cambios en la UI no afectan la lógica
- Cambios en la lógica no afectan la UI
- Fácil encontrar código

### **3. Testeabilidad**
```typescript
// Fácil testear controladores sin UI
test('Aprobar mascota', async () => {
  await MascotasController.aprobar('123')
  // Verificar estado...
})
```

### **4. Reutilización de código**
```dart
// El mismo servicio se usa en múltiples páginas
final service = MascotasService();

// Página 1
await service.obtenerMisMascotas();

// Página 2
await service.crearMascota(...);
```

---

## 🛠️ CÓMO AGREGAR NUEVA FUNCIONALIDAD

### **Paso 1: Crear el Modelo**

```typescript
// web/src/models/Inventario.ts
export interface Farmaco {
  id: string
  nombre: string
  stock: number
}
```

### **Paso 2: Crear el Controlador**

```typescript
// web/src/controllers/InventarioController.ts
export class InventarioController {
  static async getFarmacos(): Promise<Farmaco[]> {
    const { data } = await supabase
      .from('farmacos')
      .select('*')
    return data || []
  }
}
```

### **Paso 3: Usar en la Vista**

```typescript
// web/src/views/pages/InventarioPage.tsx
import { InventarioController } from '../controllers/InventarioController'

const InventarioPage = () => {
  const [farmacos, setFarmacos] = useState([])

  useEffect(() => {
    InventarioController.getFarmacos().then(setFarmacos)
  }, [])

  return <div>{/* Renderizar farmacos */}</div>
}
```

---

## 🎯 RESUMEN

| Aspecto | Antes | Después MVC |
|---------|-------|-------------|
| **Organización** | Código mezclado | Separado por capas |
| **Permisos** | ❌ Permission denied | ✅ Funciones SQL seguras |
| **Mantenibilidad** | Difícil | Fácil |
| **Testeabilidad** | Compleja | Simple |
| **Reutilización** | Poca | Alta |
| **Comunicación Web ↔ Móvil** | Inconsistente | Sincronizada |

---

## 📚 ARCHIVOS CLAVE

### **Base de Datos:**
- `/database/fix_permission_functions.sql` - Funciones SQL seguras

### **Proyecto Web:**
- `/web/src/models/` - Modelos de datos
- `/web/src/controllers/` - Lógica de negocio
- `/web/src/views/` - Componentes UI

### **Proyecto Móvil:**
- `/mobile/lib/shared/models/` - Modelos de datos
- `/mobile/lib/features/*/data/` - Servicios (controladores)
- `/mobile/lib/features/*/presentation/` - UI

---

**✅ ¡Arquitectura MVC implementada exitosamente!**

Ahora ambos proyectos tienen código limpio, organizado y sin errores de permisos.
