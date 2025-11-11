# 📋 GUÍA: Crear Usuarios de Prueba en RamboPet

Esta guía te ayudará a crear usuarios de prueba para probar todas las funcionalidades del sistema.

## 🎯 Usuarios que Vamos a Crear

| Email | Contraseña | Rol | Descripción |
|-------|-----------|-----|-------------|
| admin@rambopet.com | Admin123! | Administrador | Acceso completo al sistema |
| medico@rambopet.com | Medico123! | Médico | Veterinario profesional |
| recepcion@rambopet.com | Recepcion123! | Recepcionista | Gestión de citas |
| tutor@rambopet.com | Tutor123! | Tutor | Dueño de mascotas |
| tutor2@rambopet.com | Tutor123! | Tutor | Segundo dueño de mascotas |

---

## 📝 MÉTODO 1: Creación Automática (Recomendado)

### Paso 1: Acceder a Supabase Dashboard

1. Ve a tu proyecto en [Supabase](https://supabase.com/dashboard)
2. Selecciona tu proyecto de RamboPet

### Paso 2: Crear Usuarios en Authentication

1. Ve a **Authentication** > **Users**
2. Haz clic en **"Add User"** (o "Invite")
3. Crea cada usuario con estos datos:

#### Usuario 1: Administrador
```
Email: admin@rambopet.com
Password: Admin123!
Auto Confirm User: ✅ (activar)
```

#### Usuario 2: Médico
```
Email: medico@rambopet.com
Password: Medico123!
Auto Confirm User: ✅ (activar)
```

#### Usuario 3: Recepcionista
```
Email: recepcion@rambopet.com
Password: Recepcion123!
Auto Confirm User: ✅ (activar)
```

#### Usuario 4: Tutor 1
```
Email: tutor@rambopet.com
Password: Tutor123!
Auto Confirm User: ✅ (activar)
```

#### Usuario 5: Tutor 2
```
Email: tutor2@rambopet.com
Password: Tutor123!
Auto Confirm User: ✅ (activar)
```

### Paso 3: Ejecutar Script SQL

1. Ve a **SQL Editor** en Supabase
2. Crea un nuevo query
3. Copia y pega el siguiente script completo:

```sql
-- Vincular usuarios de Auth con la tabla users y crear datos
DO $$
DECLARE
    admin_auth_id UUID;
    medico_auth_id UUID;
    recepcion_auth_id UUID;
    tutor1_auth_id UUID;
    tutor2_auth_id UUID;
BEGIN
    -- Obtener UUIDs de auth.users
    SELECT id INTO admin_auth_id FROM auth.users WHERE email = 'admin@rambopet.com';
    SELECT id INTO medico_auth_id FROM auth.users WHERE email = 'medico@rambopet.com';
    SELECT id INTO recepcion_auth_id FROM auth.users WHERE email = 'recepcion@rambopet.com';
    SELECT id INTO tutor1_auth_id FROM auth.users WHERE email = 'tutor@rambopet.com';
    SELECT id INTO tutor2_auth_id FROM auth.users WHERE email = 'tutor2@rambopet.com';

    -- Insertar o actualizar en tabla users
    INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol, activo)
    VALUES
        (admin_auth_id, 'admin@rambopet.com', 'Carlos Ramírez Admin', '+57 300 123 4567', 'admin', true),
        (medico_auth_id, 'medico@rambopet.com', 'Dra. María Fernández', '+57 300 234 5678', 'medico', true),
        (recepcion_auth_id, 'recepcion@rambopet.com', 'Laura González Pérez', '+57 300 345 6789', 'recepcion', true),
        (tutor1_auth_id, 'tutor@rambopet.com', 'Juan Carlos Martínez', '+57 300 456 7890', 'tutor', true),
        (tutor2_auth_id, 'tutor2@rambopet.com', 'Ana Patricia Rodríguez', '+57 300 567 8901', 'tutor', true)
    ON CONFLICT (email) DO UPDATE SET
        auth_user_id = EXCLUDED.auth_user_id,
        nombre_completo = EXCLUDED.nombre_completo,
        telefono = EXCLUDED.telefono,
        rol = EXCLUDED.rol,
        activo = EXCLUDED.activo;

    RAISE NOTICE 'Usuarios creados exitosamente';
END $$;

-- Crear profesional para el médico
INSERT INTO profesionales (user_id, numero_registro_profesional, especialidad, universidad, anio_graduacion, activo)
SELECT id, 'MP-2024-001', 'Medicina Veterinaria General', 'Universidad Nacional', 2018, true
FROM users WHERE email = 'medico@rambopet.com'
ON CONFLICT DO NOTHING;

-- Crear tutores
INSERT INTO tutores (user_id, dni, direccion, ciudad, pais, activo)
SELECT id, '1234567890', 'Calle 123 #45-67', 'Bogotá', 'Colombia', true
FROM users WHERE email = 'tutor@rambopet.com'
ON CONFLICT DO NOTHING;

INSERT INTO tutores (user_id, dni, direccion, ciudad, pais, activo)
SELECT id, '9876543210', 'Carrera 45 #12-34', 'Medellín', 'Colombia', true
FROM users WHERE email = 'tutor2@rambopet.com'
ON CONFLICT DO NOTHING;

-- Crear servicios
INSERT INTO servicios (nombre, tipo_servicio, precio_base, duracion_estimada_min, activo)
VALUES
    ('Consulta General', 'consulta_general', 50000, 30, true),
    ('Vacunación Múltiple', 'vacunacion', 80000, 20, true),
    ('Desparasitación', 'desparasitacion', 30000, 15, true),
    ('Cirugía Menor', 'cirugia', 200000, 90, true),
    ('Control Post-Operatorio', 'control', 40000, 20, true),
    ('Baño y Peluquería', 'estetica', 60000, 60, true)
ON CONFLICT DO NOTHING;

-- Crear consultorios
INSERT INTO consultorios (nombre, tipo, activo)
VALUES
    ('Consultorio 1', 'general', true),
    ('Consultorio 2', 'general', true),
    ('Sala de Cirugía', 'cirugia', true),
    ('Sala de Urgencias', 'urgencias', true)
ON CONFLICT DO NOTHING;

-- Crear medicamentos
INSERT INTO farmacos (nombre_comercial, nombre_generico, laboratorio, presentacion, forma_farmaceutica, via_administracion, stock_minimo, stock_total, requiere_receta, activo)
VALUES
    ('Drontal Plus', 'Praziquantel + Pirantel', 'Bayer', '20 comprimidos', 'Comprimido', 'Oral', 10, 50, false, true),
    ('Nexgard', 'Afoxolaner', 'Boehringer', '3 tabletas masticables', 'Tableta masticable', 'Oral', 15, 45, false, true),
    ('Metacam', 'Meloxicam', 'Boehringer', '100ml solución oral', 'Solución', 'Oral', 5, 12, true, true),
    ('Amoxicilina 500mg', 'Amoxicilina', 'Genérico', '20 comprimidos', 'Comprimido', 'Oral', 20, 100, true, true),
    ('Ranitidina 150mg', 'Ranitidina', 'Genérico', '30 comprimidos', 'Comprimido', 'Oral', 15, 8, true, true)
ON CONFLICT DO NOTHING;

-- Crear mascotas para tutor 1
INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, microchip, estado, esterilizado, activo)
SELECT t.id, 'Max', 'Canino', 'Labrador Retriever', 'Macho', '2020-03-15', 28.5, 'Dorado', 'MX123456789', 'aprobado', true, true
FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor@rambopet.com'
ON CONFLICT DO NOTHING;

INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, estado, esterilizado, activo)
SELECT t.id, 'Luna', 'Felino', 'Persa', 'Hembra', '2021-07-20', 4.2, 'Blanco', 'aprobado', true, true
FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor@rambopet.com'
ON CONFLICT DO NOTHING;

-- Crear mascotas para tutor 2
INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, estado, esterilizado, activo)
SELECT t.id, 'Rocky', 'Canino', 'Pastor Alemán', 'Macho', '2019-05-10', 35.0, 'Negro y café', 'aprobado', false, true
FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor2@rambopet.com'
ON CONFLICT DO NOTHING;

INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, estado, esterilizado, activo)
SELECT t.id, 'Toby', 'Canino', 'Beagle', 'Macho', '2023-01-15', 12.0, 'Tricolor', 'pendiente', false, true
FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor2@rambopet.com'
ON CONFLICT DO NOTHING;

-- Verificar creación
SELECT
    u.email,
    u.nombre_completo,
    u.rol,
    u.activo,
    CASE WHEN u.auth_user_id IS NOT NULL THEN '✅ Vinculado' ELSE '❌ No vinculado' END as estado_auth
FROM users u
WHERE u.email LIKE '%@rambopet.com'
ORDER BY u.rol, u.email;
```

4. Haz clic en **"Run"** o **F5**
5. Verifica que aparezca el mensaje de éxito

---

## ✅ Verificación

Ejecuta esta consulta para verificar que todo se creó correctamente:

```sql
-- Verificar usuarios
SELECT email, nombre_completo, rol, activo FROM users WHERE email LIKE '%@rambopet.com';

-- Verificar tutores
SELECT u.email, t.dni, t.direccion FROM tutores t
INNER JOIN users u ON t.user_id = u.id;

-- Verificar mascotas
SELECT m.nombre, m.especie, m.estado, u.email as tutor_email
FROM mascotas m
INNER JOIN tutores t ON m.tutor_id = t.id
INNER JOIN users u ON t.user_id = u.id;

-- Verificar servicios
SELECT nombre, tipo_servicio, precio_base FROM servicios;

-- Verificar medicamentos
SELECT nombre_comercial, stock_total, stock_minimo FROM farmacos;
```

---

## 🚀 Probar el Sistema

### 1. Login como Administrador
```
Email: admin@rambopet.com
Password: Admin123!
```

**Deberías poder ver:**
- Dashboard con todas las estadísticas
- Gestión de mascotas (aprobar/rechazar)
- Todas las citas
- Inventario completo
- Tutores y profesionales
- Historias clínicas

### 2. Login como Médico
```
Email: medico@rambopet.com
Password: Medico123!
```

### 3. Login como Tutor
```
Email: tutor@rambopet.com
Password: Tutor123!
```

**Deberías ver:**
- Tus mascotas (Max y Luna)
- Tus citas
- Historial médico de tus mascotas

---

## 📊 Datos de Prueba Creados

### Usuarios
- ✅ 1 Administrador
- ✅ 1 Médico Veterinario
- ✅ 1 Recepcionista
- ✅ 2 Tutores

### Mascotas
- ✅ 4 mascotas (3 aprobadas, 1 pendiente)
- Max (Labrador - Tutor 1)
- Luna (Persa - Tutor 1)
- Rocky (Pastor Alemán - Tutor 2)
- Toby (Beagle - Tutor 2) - **PENDIENTE DE APROBACIÓN**

### Servicios
- ✅ 6 servicios veterinarios

### Consultorios
- ✅ 4 consultorios configurados

### Medicamentos
- ✅ 5 medicamentos en inventario
- ⚠️ Ranitidina con stock bajo (8 unidades, mínimo 15)

---

## ⚠️ Notas Importantes

1. **Cambiar contraseñas**: En producción, usa contraseñas seguras
2. **Email confirmation**: Asegúrate de marcar "Auto Confirm User" al crear usuarios en Supabase
3. **Roles**: Los permisos dependen de las políticas RLS configuradas
4. **Datos de prueba**: Estos datos son solo para testing

---

## 🔧 Solución de Problemas

### Error: "Usuario no encontrado en auth.users"
- Verifica que creaste los usuarios en Authentication > Users
- Asegúrate de confirmar el email de cada usuario

### Error: "duplicate key value violates unique constraint"
- Los usuarios ya existen. Puedes eliminarlos y volver a crearlos
- O simplemente actualizar con `ON CONFLICT DO UPDATE`

### No aparecen las mascotas/datos
- Verifica que el script SQL se ejecutó sin errores
- Ejecuta las consultas de verificación
- Revisa que las políticas RLS estén aplicadas

---

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs en Supabase (Database > Logs)
2. Verifica las políticas RLS (Authentication > Policies)
3. Asegúrate de haber ejecutado los scripts de funciones RPC

¡Listo! Ahora puedes probar todo el sistema con usuarios reales. 🎉
