# 🏗️ ARQUITECTURA MVC COMPLETA - SISTEMA RAMBOPET

## 📐 PATRÓN MVC (Modelo-Vista-Controlador)

El sistema RamboPet implementa una arquitectura MVC completa tanto en el **frontend web (React + TypeScript)** como en la **aplicación móvil (Flutter + Dart)**.

Esta arquitectura garantiza:
- ✅ **Separación de responsabilidades**
- ✅ **Código mantenible y escalable**
- ✅ **Reutilización de lógica de negocio**
- ✅ **Facilidad para testing**
- ✅ **Sincronización perfecta Web ↔ Móvil**

---

## 🖥️ PROYECTO WEB (React + TypeScript)

### **Estructura Completa:**

```
web/src/
├── models/                    # 📦 MODELOS (13 archivos)
│   ├── User.ts               # Usuarios del sistema
│   ├── Tutor.ts              # Dueños de mascotas
│   ├── Mascota.ts            # Pacientes veterinarios
│   ├── Servicio.ts           # Catálogo de servicios
│   ├── Profesional.ts        # Médicos veterinarios
│   ├── Consultorio.ts        # Salas de atención
│   ├── Cita.ts               # Sistema de reservas
│   ├── HistoriaClinica.ts    # Historias clínicas
│   ├── Episodio.ts           # Consultas individuales
│   ├── Adjunto.ts            # Archivos/documentos
│   ├── Farmaco.ts            # Medicamentos
│   ├── LoteFarmaco.ts        # Lotes de medicamentos
│   ├── InventarioMovimiento.ts  # Movimientos de stock
│   ├── ConsumoFarmaco.ts     # Prescripciones
│   ├── Auditoria.ts          # Registro de acciones
│   └── index.ts              # Índice de exportación
│
├── controllers/               # 🎮 CONTROLADORES (12 archivos)
│   ├── UsersController.ts
│   ├── TutoresController.ts
│   ├── MascotasController.ts
│   ├── ServiciosController.ts
│   ├── ProfesionalesController.ts
│   ├── ConsultoriosController.ts
│   ├── CitasController.ts
│   ├── HistoriasClinicasController.ts
│   ├── EpisodiosController.ts
│   ├── FarmacosController.ts
│   ├── LotesFarmacosController.ts
│   ├── InventarioController.ts
│   └── index.ts              # Índice de exportación
│
├── views/                     # 👁️ VISTAS
│   ├── pages/
│   │   ├── DashboardPage.tsx
│   │   ├── MascotasPage.tsx
│   │   ├── CitasPage.tsx
│   │   ├── InventarioPage.tsx
│   │   └── auth/LoginPage.tsx
│   └── components/
│       └── layout/Layout.tsx
│
└── services/                  # 🔌 SERVICIOS
    └── supabase.ts           # Cliente Supabase
```

### **Modelos TypeScript:**

Todos los modelos definen interfaces TypeScript con:
- Tipos de datos estrictos
- Interfaces para formularios (FormData)
- Interfaces para actualizaciones (UpdateData)
- Tipos enumerados para estados

**Ejemplo - Mascota.ts:**
```typescript
export interface Mascota {
  id: string
  tutor_id: string
  nombre: string
  especie: string
  raza?: string
  sexo?: string
  fecha_nacimiento?: string
  peso_kg?: number
  estado: 'pendiente' | 'aprobado' | 'rechazado'
  activo: boolean
  created_at: string
}

export interface MascotaFormData {
  nombre: string
  especie: string
  raza?: string
  // ...
}
```

### **Controladores TypeScript:**

Todos los controladores son clases estáticas que manejan la lógica de negocio:

**Ejemplo - MascotasController.ts:**
```typescript
export class MascotasController {
  static async getAll(filtro?: string): Promise<Mascota[]> {
    const { data, error } = await supabase
      .from('mascotas')
      .select('*')
      .is('deleted_at', null)

    if (error) throw error
    return data || []
  }

  static async aprobar(id: string): Promise<void> {
    const { error } = await supabase
      .from('mascotas')
      .update({ estado: 'aprobado' })
      .eq('id', id)

    if (error) throw error
  }

  static async getStats() {
    // Retorna estadísticas
  }
}
```

### **Uso en Componentes React:**

```typescript
import { MascotasController } from '../controllers'
import type { Mascota } from '../models'

function MascotasPage() {
  const [mascotas, setMascotas] = useState<Mascota[]>([])

  useEffect(() => {
    const cargarMascotas = async () => {
      const data = await MascotasController.getAll('pendiente')
      setMascotas(data)
    }
    cargarMascotas()
  }, [])

  const handleAprobar = async (id: string) => {
    await MascotasController.aprobar(id)
    // Recargar datos
  }

  return (
    <div>
      {mascotas.map(mascota => (
        <MascotaCard
          key={mascota.id}
          mascota={mascota}
          onAprobar={handleAprobar}
        />
      ))}
    </div>
  )
}
```

---

## 📱 PROYECTO MÓVIL (Flutter + Dart)

### **Estructura Completa:**

```
mobile/lib/
├── shared/
│   └── models/                # 📦 MODELOS
│       ├── user_model.dart
│       ├── tutor_model.dart
│       ├── mascota_model.dart
│       ├── servicio_model.dart
│       ├── profesional_model.dart
│       ├── cita_model.dart
│       └── ...
│
├── features/
│   ├── user/
│   │   └── data/
│   │       └── user_service.dart         # 🎮 CONTROLADOR
│   │
│   ├── mascotas/
│   │   ├── data/                         # 🎮 CONTROLADOR
│   │   │   └── mascotas_service.dart
│   │   └── presentation/                 # 👁️ VISTA
│   │       ├── pages/
│   │       │   ├── mis_mascotas_page.dart
│   │       │   └── nueva_mascota_page.dart
│   │       ├── providers/
│   │       │   └── mascotas_provider.dart
│   │       └── widgets/
│   │           └── mascota_card.dart
│   │
│   ├── citas/
│   │   ├── data/                         # 🎮 CONTROLADORES
│   │   │   ├── citas_service.dart
│   │   │   ├── servicios_service.dart
│   │   │   ├── profesionales_service.dart
│   │   │   └── consultorios_service.dart
│   │   └── presentation/                 # 👁️ VISTAS
│   │       ├── pages/
│   │       ├── providers/
│   │       └── widgets/
│   │
│   ├── historias/
│   │   └── data/
│   │       ├── historia_clinica_service.dart
│   │       └── episodio_service.dart
│   │
│   └── farmacos/
│       └── data/
│           └── farmaco_service.dart
│
└── core/
    └── config/
        └── supabase_config.dart
```

### **Servicios Flutter (Controladores):**

Los servicios en Flutter actúan como controladores que utilizan **RPC calls** para evitar problemas de permisos:

**Ejemplo - MascotasService:**
```dart
class MascotasService {
  /// Obtener mis mascotas usando función SQL segura
  Future<List<MascotaModel>> obtenerMisMascotas() async {
    try {
      // ✅ Usa RPC call, no query directa
      final response = await supabase.rpc('get_my_mascotas');

      return (response as List)
          .map((json) => MascotaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener mascotas: $e');
    }
  }

  /// Crear mascota
  Future<String> crearMascota({
    required String nombre,
    required String especie,
    // ...
  }) async {
    try {
      final mascotaId = await supabase.rpc('create_mascota', params: {
        'p_nombre': nombre,
        'p_especie': especie,
        // ...
      });
      return mascotaId as String;
    } catch (e) {
      throw Exception('Error al crear mascota: $e');
    }
  }
}
```

**Ejemplo - CitasService:**
```dart
class CitasService {
  /// Obtener mis citas usando RPC
  Future<Map<String, List<CitaModel>>> obtenerMisCitas() async {
    try {
      final response = await supabase.rpc('get_my_citas');

      final citas = (response as List)
          .map((json) => CitaModel.fromJson(json))
          .toList();

      // Separar en próximas y pasadas
      final ahora = DateTime.now();
      final proximas = citas.where((c) =>
        c.fechaHora.isAfter(ahora) && c.estado != 'cancelada'
      ).toList();

      final pasadas = citas.where((c) =>
        c.fechaHora.isBefore(ahora) ||
        c.estado == 'cancelada'
      ).toList();

      return {'proximas': proximas, 'pasadas': pasadas};
    } catch (e) {
      throw Exception('Error al obtener citas: $e');
    }
  }

  /// Crear cita
  Future<String> crearCita({
    required String mascotaId,
    required String servicioId,
    required String profesionalId,
    required DateTime fechaHora,
    String? motivoConsulta,
  }) async {
    try {
      final citaId = await supabase.rpc('create_cita', params: {
        'p_mascota_id': mascotaId,
        'p_servicio_id': servicioId,
        'p_profesional_id': profesionalId,
        'p_fecha_hora': fechaHora.toIso8601String(),
        'p_motivo_consulta': motivoConsulta,
      });
      return citaId as String;
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }

  /// Cancelar cita
  Future<void> cancelarCita(String citaId, String motivo) async {
    try {
      await supabase.rpc('cancel_cita', params: {
        'p_cita_id': citaId,
        'p_motivo_cancelacion': motivo,
      });
    } catch (e) {
      throw Exception('Error al cancelar cita: $e');
    }
  }
}
```

### **Uso en Páginas Flutter:**

```dart
class MisMascotasPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mascotasAsyncValue = ref.watch(mascotasProvider);

    return mascotasAsyncValue.when(
      data: (mascotas) => ListView.builder(
        itemCount: mascotas.length,
        itemBuilder: (context, index) {
          final mascota = mascotas[index];
          return MascotaCard(
            mascota: mascota,
            onTap: () => _verDetalle(context, mascota),
          );
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// Provider usando el servicio
final mascotasProvider = FutureProvider<List<MascotaModel>>((ref) async {
  final service = MascotasService();
  return await service.obtenerMisMascotas();
});
```

---

## 🗄️ BASE DE DATOS - FUNCIONES SQL (RPC)

Para evitar errores de permisos como `"permission denied for table users"`, se crearon **funciones SQL con SECURITY DEFINER**:

### **Archivo:** `/database/fix_permission_functions_complete.sql`

Este archivo contiene **TODAS** las funciones RPC necesarias:

#### **Funciones de Usuario:**
- `get_current_user_data()` - Obtiene datos del usuario autenticado
- `get_current_tutor_id()` - Obtiene ID de tutor
- `get_current_profesional_id()` - Obtiene ID de profesional

#### **Funciones de Mascotas:**
- `get_my_mascotas()` - Obtiene mascotas del tutor actual
- `create_mascota(...)` - Crea nueva mascota
- `update_mascota(...)` - Actualiza mascota
- `delete_mascota(...)` - Elimina mascota (soft delete)

#### **Funciones de Citas:**
- `get_my_citas()` - Obtiene citas del tutor actual
- `create_cita(...)` - Crea nueva cita
- `update_cita_estado(...)` - Actualiza estado de cita
- `cancel_cita(...)` - Cancela cita

#### **Funciones de Catálogos:**
- `get_all_servicios()` - Obtiene servicios activos
- `get_all_profesionales()` - Obtiene profesionales activos
- `get_all_consultorios()` - Obtiene consultorios activos
- `get_all_farmacos()` - Obtiene fármacos con stock

#### **Funciones de Historias Clínicas:**
- `get_historia_clinica_by_mascota(mascota_id)` - Obtiene historia de mascota
- `get_episodios_by_historia(historia_id)` - Obtiene episodios
- `create_episodio(...)` - Crea nuevo episodio (solo profesionales)

#### **Funciones de Inventario:**
- `get_lotes_by_farmaco(farmaco_id)` - Obtiene lotes de un fármaco
- `calcular_stock_total_farmaco(farmaco_id)` - Calcula stock total
- `obtener_lotes_vencimiento(dias)` - Lotes vencidos o por vencer

### **¿Por qué SECURITY DEFINER?**

```sql
CREATE OR REPLACE FUNCTION get_my_mascotas()
RETURNS TABLE (...)
LANGUAGE plpgsql
SECURITY DEFINER  -- ← Se ejecuta con permisos del creador
STABLE
AS $$
DECLARE
    v_tutor_id UUID;
BEGIN
    -- Obtener tutor_id DENTRO de la función
    v_tutor_id := get_current_tutor_id();

    -- Retornar mascotas SIN que RLS bloquee
    RETURN QUERY
    SELECT * FROM mascotas
    WHERE tutor_id = v_tutor_id
      AND deleted_at IS NULL;
END;
$$;
```

**Ventajas:**
- ✅ El usuario **NO consulta directamente** la tabla `users` (evita "permission denied")
- ✅ La función se ejecuta con **permisos elevados**
- ✅ La lógica de seguridad está **centralizada**
- ✅ Funciona **igual para web y móvil**

---

## 🔄 FLUJO COMPLETO DE DATOS

### **Ejemplo: Crear nueva mascota desde app móvil**

```
1. VISTA (Flutter)
   Usuario completa formulario en NuevaMascotaPage
   ↓
2. PROVIDER
   Llama a MascotasService.crearMascota(...)
   ↓
3. SERVICIO (Controlador)
   Ejecuta: supabase.rpc('create_mascota', params: {...})
   ↓
4. FUNCIÓN SQL (Backend)
   create_mascota(...) se ejecuta con SECURITY DEFINER
   - Obtiene tutor_id del usuario actual
   - Inserta en tabla mascotas con estado 'pendiente'
   ↓
5. TRIGGER (Base de datos)
   - actualizar_updated_at(): Actualiza timestamp
   - notificar_nueva_mascota(): Notifica a admin
   - registrar_auditoria(): Registra en auditoría
   ↓
6. RESPUESTA
   Retorna ID de mascota creada
   ↓
7. VISTA
   Navega a pantalla de confirmación
```

### **Sincronización Web ↔ Móvil**

```
MÓVIL                              WEB
  |                                 |
  | Crea mascota                    |
  | (RPC create_mascota)            |
  ↓                                 |
DATABASE ←─────────────────────────┘
  |
  | TRIGGER: notificar_nueva_mascota
  ↓
  ✉️ pg_notify('nueva_mascota', {...})
  |                                 |
  |                                 ↓
  |                           Dashboard ve
  |                           nueva mascota
  |                                 |
  |                           Admin aprueba
  |                           (MascotasController)
  |                                 ↓
  |                          UPDATE mascotas
  |                          SET estado='aprobado'
  ↓                                 ↓
Realtime subscription        DATABASE
detecta cambio                     |
  ↓                                |
Actualiza lista de            Actualiza
mascotas en tiempo real       estadísticas
```

---

## 📋 LISTA COMPLETA DE ENTIDADES

### **Web - Modelos (15):**
1. ✅ User
2. ✅ Tutor
3. ✅ Mascota
4. ✅ Servicio
5. ✅ Profesional
6. ✅ Consultorio
7. ✅ Cita
8. ✅ HistoriaClinica
9. ✅ Episodio
10. ✅ Adjunto
11. ✅ Farmaco
12. ✅ LoteFarmaco
13. ✅ InventarioMovimiento
14. ✅ ConsumoFarmaco
15. ✅ Auditoria

### **Web - Controladores (12):**
1. ✅ UsersController
2. ✅ TutoresController
3. ✅ MascotasController
4. ✅ ServiciosController
5. ✅ ProfesionalesController
6. ✅ ConsultoriosController
7. ✅ CitasController
8. ✅ HistoriasClinicasController
9. ✅ EpisodiosController
10. ✅ FarmacosController
11. ✅ LotesFarmacosController
12. ✅ InventarioController

### **Móvil - Servicios (8):**
1. ✅ UserService
2. ✅ MascotasService
3. ✅ CitasService
4. ✅ ServiciosService
5. ✅ ProfesionalesService
6. ✅ ConsultoriosService
7. ✅ HistoriaClinicaService
8. ✅ EpisodioService
9. ✅ FarmacoService

### **SQL - Funciones RPC (20+):**
1. ✅ get_current_user_data
2. ✅ get_current_tutor_id
3. ✅ get_current_profesional_id
4. ✅ get_my_mascotas
5. ✅ create_mascota
6. ✅ update_mascota
7. ✅ delete_mascota
8. ✅ get_my_citas
9. ✅ create_cita
10. ✅ update_cita_estado
11. ✅ cancel_cita
12. ✅ get_all_servicios
13. ✅ get_all_profesionales
14. ✅ get_all_consultorios
15. ✅ get_all_farmacos
16. ✅ get_historia_clinica_by_mascota
17. ✅ get_episodios_by_historia
18. ✅ create_episodio
19. ✅ get_lotes_by_farmaco
20. ✅ calcular_stock_total_farmaco
21. ✅ obtener_lotes_vencimiento
22. ✅ validar_disponibilidad_cita

---

## 🚀 INSTRUCCIONES DE INSTALACIÓN

### **1. Ejecutar Script SQL:**

```bash
# En Supabase Dashboard → SQL Editor
# Copiar y ejecutar: database/fix_permission_functions_complete.sql
```

### **2. Verificar Funciones:**

```sql
-- Ver funciones creadas
SELECT proname, prosecdef
FROM pg_proc
WHERE proname LIKE 'get_%' OR proname LIKE 'create_%';
```

### **3. Probar desde Frontend:**

```typescript
// Web (TypeScript)
import { MascotasController } from './controllers'

const mascotas = await MascotasController.getAll()
console.log(mascotas)
```

```dart
// Móvil (Flutter)
final service = MascotasService();
final mascotas = await service.obtenerMisMascotas();
print(mascotas);
```

---

## 📝 CONVENCIONES DE CÓDIGO

### **TypeScript (Web):**

- **Modelos:** Interfaces con PascalCase
- **Controladores:** Clases estáticas con métodos async
- **Métodos:** camelCase (getAll, getById, create, update, delete)
- **Tipos:** export type, export interface

### **Dart (Flutter):**

- **Servicios:** Clases con métodos async
- **Métodos:** camelCase con español (obtenerMisMascotas, crearCita)
- **Modelos:** Clases con fromJson/toJson
- **Providers:** FutureProvider / StateNotifierProvider

### **SQL:**

- **Funciones:** snake_case (get_my_mascotas, create_cita)
- **Parámetros:** Prefijo `p_` (p_mascota_id, p_nombre)
- **Variables locales:** Prefijo `v_` (v_tutor_id, v_cita_id)
- **Siempre:** SECURITY DEFINER para funciones RPC

---

## 🎯 BUENAS PRÁCTICAS

### ✅ **DO:**
- Usar controladores/servicios para TODA lógica de negocio
- Usar funciones RPC para operaciones complejas o que requieren permisos
- Mantener las vistas simples (solo UI)
- Centralizar manejo de errores
- Documentar funciones con comentarios

### ❌ **DON'T:**
- NO hacer queries directas desde componentes/widgets
- NO duplicar lógica entre web y móvil
- NO hardcodear valores (usar constantes/enums)
- NO ignorar errores de RLS (usar funciones SQL)
- NO mezclar lógica de negocio con UI

---

## 🔍 TROUBLESHOOTING

### **Error: "permission denied for table users"**
✅ **Solución:** Usar función RPC `get_current_user_data()` en lugar de query directa

### **Error: "function does not exist"**
✅ **Solución:** Ejecutar `/database/fix_permission_functions_complete.sql`

### **Error: "RLS policy violation"**
✅ **Solución:** Verificar que las funciones RPC tengan `SECURITY DEFINER`

### **Cambios en web no se reflejan en móvil:**
✅ **Solución:** Verificar que ambos usen las mismas funciones RPC y base de datos

---

## 📚 RECURSOS

- [Documentación Supabase RPC](https://supabase.com/docs/guides/database/functions)
- [MVC Pattern](https://es.wikipedia.org/wiki/Modelo%E2%80%93vista%E2%80%93controlador)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [Flutter Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Última actualización:** Noviembre 2025
**Versión:** 2.0.0 - Arquitectura MVC Completa
