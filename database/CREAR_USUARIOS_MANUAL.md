# 🚀 MÉTODO SIMPLE - Crear Usuarios Manualmente

Si el script SQL automático no funciona, sigue estos pasos para crear usuarios manualmente:

## 📋 PASO 1: Crear Usuarios en Supabase Dashboard

1. Ve a **Supabase Dashboard**: https://supabase.com/dashboard
2. Selecciona tu proyecto
3. Ve a **Authentication** → **Users** (icono de usuario en el menú lateral)
4. Haz clic en **"Add user"** → **"Create new user"**

### 👤 Crear los 5 usuarios uno por uno:

#### Usuario 1: Admin
```
Email: admin@rambopet.com
Password: Admin123!
☑ Auto Confirm User (IMPORTANTE: marcar esta casilla)
```
Haz clic en **"Create user"**

#### Usuario 2: Médico
```
Email: medico@rambopet.com
Password: Medico123!
☑ Auto Confirm User
```

#### Usuario 3: Recepción
```
Email: recepcion@rambopet.com
Password: Recepcion123!
☑ Auto Confirm User
```

#### Usuario 4: Tutor 1
```
Email: tutor@rambopet.com
Password: Tutor123!
☑ Auto Confirm User
```

#### Usuario 5: Tutor 2
```
Email: tutor2@rambopet.com
Password: Tutor123!
☑ Auto Confirm User
```

---

## 📊 PASO 2: Vincular Datos en la Base de Datos

Después de crear los 5 usuarios, ejecuta este script SQL:

1. Ve a **SQL Editor** en Supabase
2. Crea un nuevo query
3. Copia y pega el script de abajo
4. Haz clic en **RUN**

```sql
-- ============================================================================
-- VINCULAR USUARIOS Y CREAR DATOS
-- ============================================================================

DO $$
DECLARE
    v_admin_id UUID;
    v_medico_id UUID;
    v_recepcion_id UUID;
    v_tutor1_id UUID;
    v_tutor2_id UUID;
BEGIN
    -- Obtener los IDs de auth.users
    SELECT id INTO v_admin_id FROM auth.users WHERE email = 'admin@rambopet.com';
    SELECT id INTO v_medico_id FROM auth.users WHERE email = 'medico@rambopet.com';
    SELECT id INTO v_recepcion_id FROM auth.users WHERE email = 'recepcion@rambopet.com';
    SELECT id INTO v_tutor1_id FROM auth.users WHERE email = 'tutor@rambopet.com';
    SELECT id INTO v_tutor2_id FROM auth.users WHERE email = 'tutor2@rambopet.com';

    -- Verificar que se encontraron los usuarios
    IF v_admin_id IS NULL OR v_medico_id IS NULL OR v_recepcion_id IS NULL
       OR v_tutor1_id IS NULL OR v_tutor2_id IS NULL THEN
        RAISE EXCEPTION 'ERROR: No se encontraron todos los usuarios en auth.users. Verifica que los creaste en Authentication > Users';
    END IF;

    RAISE NOTICE 'Usuarios encontrados en auth.users';

    -- Crear en tabla users
    INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol, activo)
    VALUES
        (v_admin_id, 'admin@rambopet.com', 'Carlos Ramírez Admin', '+57 300 123 4567', 'admin', true),
        (v_medico_id, 'medico@rambopet.com', 'Dra. María Fernández', '+57 300 234 5678', 'medico', true),
        (v_recepcion_id, 'recepcion@rambopet.com', 'Laura González', '+57 300 345 6789', 'recepcion', true),
        (v_tutor1_id, 'tutor@rambopet.com', 'Juan Carlos Martínez', '+57 300 456 7890', 'tutor', true),
        (v_tutor2_id, 'tutor2@rambopet.com', 'Ana Patricia Rodríguez', '+57 300 567 8901', 'tutor', true)
    ON CONFLICT (email) DO UPDATE SET
        auth_user_id = EXCLUDED.auth_user_id,
        nombre_completo = EXCLUDED.nombre_completo;

    RAISE NOTICE '✅ Usuarios vinculados en tabla users';

    -- Crear profesional
    INSERT INTO profesionales (user_id, matricula_profesional, especialidades, anios_experiencia, activo)
    SELECT id, 'MP-2024-001', ARRAY['Medicina General', 'Cirugía'], 6, true
    FROM users WHERE email = 'medico@rambopet.com'
    ON CONFLICT (matricula_profesional) DO NOTHING;

    RAISE NOTICE '✅ Profesional creado';

    -- Crear tutores
    INSERT INTO tutores (user_id, dni, direccion, ciudad, provincia)
    SELECT id, '1234567890', 'Calle 123 #45-67', 'Bogotá', 'Cundinamarca'
    FROM users WHERE email = 'tutor@rambopet.com'
    ON CONFLICT (user_id) DO NOTHING;

    INSERT INTO tutores (user_id, dni, direccion, ciudad, provincia)
    SELECT id, '9876543210', 'Carrera 45 #12-34', 'Medellín', 'Antioquia'
    FROM users WHERE email = 'tutor2@rambopet.com'
    ON CONFLICT (user_id) DO NOTHING;

    RAISE NOTICE '✅ Tutores creados';

    -- Crear servicios
    INSERT INTO servicios (nombre, tipo, duracion_minutos, precio_base, activo)
    VALUES
        ('Consulta General', 'consulta_general', 30, 50000, true),
        ('Vacunación Múltiple', 'vacunacion', 20, 80000, true),
        ('Desparasitación', 'desparasitacion', 15, 30000, true),
        ('Cirugía Menor', 'cirugia', 90, 200000, true),
        ('Control', 'control', 20, 40000, true),
        ('Baño y Peluquería', 'estetica', 60, 60000, true)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Servicios creados';

    -- Crear consultorios
    INSERT INTO consultorios (nombre, numero, piso, activo)
    VALUES
        ('Consultorio General 1', '101', '1', true),
        ('Consultorio General 2', '102', '1', true),
        ('Sala de Cirugía', '201', '2', true),
        ('Urgencias', '103', '1', true)
    ON CONFLICT (numero) DO NOTHING;

    RAISE NOTICE '✅ Consultorios creados';

    -- Crear medicamentos
    INSERT INTO farmacos (
        nombre_comercial, nombre_generico, laboratorio,
        principio_activo, concentracion, forma_farmaceutica,
        via_administracion, requiere_receta, stock_minimo, activo
    ) VALUES
        ('Drontal Plus', 'Praziquantel + Pirantel', 'Bayer',
         'Praziquantel 50mg + Pirantel 144mg', '50/144mg', 'Comprimido',
         ARRAY['oral'], false, 10, true),
        ('Nexgard', 'Afoxolaner', 'Boehringer',
         'Afoxolaner', '68mg', 'Tableta masticable',
         ARRAY['oral'], false, 15, true),
        ('Metacam', 'Meloxicam', 'Boehringer',
         'Meloxicam', '1.5mg/ml', 'Solución oral',
         ARRAY['oral'], true, 5, true),
        ('Amoxicilina', 'Amoxicilina', 'Genérico',
         'Amoxicilina', '500mg', 'Comprimido',
         ARRAY['oral'], true, 20, true),
        ('Ranitidina', 'Ranitidina', 'Genérico',
         'Ranitidina', '150mg', 'Comprimido',
         ARRAY['oral'], true, 15, true)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Medicamentos creados';

    -- Crear mascotas
    INSERT INTO mascotas (
        tutor_id, nombre, especie, raza, sexo, fecha_nacimiento,
        peso_kg, color, microchip, estado, esterilizado, activo
    )
    SELECT t.id, 'Max', 'Canino', 'Labrador Retriever', 'Macho',
           '2020-03-15', 28.5, 'Dorado', 'MX123456789', 'aprobado', true, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id
    WHERE u.email = 'tutor@rambopet.com'
    ON CONFLICT DO NOTHING;

    INSERT INTO mascotas (
        tutor_id, nombre, especie, raza, sexo, fecha_nacimiento,
        peso_kg, color, estado, esterilizado, activo, alergias
    )
    SELECT t.id, 'Luna', 'Felino', 'Persa', 'Hembra',
           '2021-07-20', 4.2, 'Blanco', 'aprobado', true, true, 'Alergia a pollo'
    FROM tutores t INNER JOIN users u ON t.user_id = u.id
    WHERE u.email = 'tutor@rambopet.com'
    ON CONFLICT DO NOTHING;

    INSERT INTO mascotas (
        tutor_id, nombre, especie, raza, sexo, fecha_nacimiento,
        peso_kg, color, estado, esterilizado, activo
    )
    SELECT t.id, 'Rocky', 'Canino', 'Pastor Alemán', 'Macho',
           '2019-05-10', 35.0, 'Negro y café', 'aprobado', false, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id
    WHERE u.email = 'tutor2@rambopet.com'
    ON CONFLICT DO NOTHING;

    INSERT INTO mascotas (
        tutor_id, nombre, especie, raza, sexo, fecha_nacimiento,
        peso_kg, color, estado, esterilizado, activo
    )
    SELECT t.id, 'Toby', 'Canino', 'Beagle', 'Macho',
           '2023-01-15', 12.0, 'Tricolor', 'pendiente', false, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id
    WHERE u.email = 'tutor2@rambopet.com'
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Mascotas creadas';

    -- Crear citas
    INSERT INTO citas (
        tutor_id, mascota_id, servicio_id, profesional_id,
        consultorio_id, fecha_hora, estado, motivo_consulta
    )
    SELECT
        t.id, m.id, s.id, p.id, c.id,
        CURRENT_DATE + INTERVAL '14 hours',
        'confirmada',
        'Consulta de control general'
    FROM tutores t
    INNER JOIN users u ON t.user_id = u.id
    INNER JOIN mascotas m ON m.tutor_id = t.id AND m.nombre = 'Max'
    CROSS JOIN (SELECT id FROM servicios WHERE nombre = 'Consulta General' LIMIT 1) s
    CROSS JOIN (SELECT id FROM profesionales LIMIT 1) p
    CROSS JOIN (SELECT id FROM consultorios WHERE numero = '101' LIMIT 1) c
    WHERE u.email = 'tutor@rambopet.com'
    ON CONFLICT DO NOTHING;

    INSERT INTO citas (
        tutor_id, mascota_id, servicio_id, profesional_id,
        consultorio_id, fecha_hora, estado, motivo_consulta
    )
    SELECT
        t.id, m.id, s.id, p.id, c.id,
        CURRENT_DATE + INTERVAL '2 days' + INTERVAL '10 hours',
        'reservada',
        'Vacunación anual'
    FROM tutores t
    INNER JOIN users u ON t.user_id = u.id
    INNER JOIN mascotas m ON m.tutor_id = t.id AND m.nombre = 'Rocky'
    CROSS JOIN (SELECT id FROM servicios WHERE nombre = 'Vacunación Múltiple' LIMIT 1) s
    CROSS JOIN (SELECT id FROM profesionales LIMIT 1) p
    CROSS JOIN (SELECT id FROM consultorios WHERE numero = '102' LIMIT 1) c
    WHERE u.email = 'tutor2@rambopet.com'
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Citas creadas';

    RAISE NOTICE '';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '✅ ¡DATOS CREADOS EXITOSAMENTE!';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '👤 Ahora puedes iniciar sesión con:';
    RAISE NOTICE '   admin@rambopet.com / Admin123!';
    RAISE NOTICE '';

END $$;

-- Verificar
SELECT
    u.email,
    u.nombre_completo,
    u.rol,
    CASE WHEN u.auth_user_id IS NOT NULL THEN '✅' ELSE '❌' END as vinculado
FROM users u
WHERE u.email LIKE '%@rambopet.com'
ORDER BY u.rol, u.email;
```

---

## ✅ PASO 3: Probar el Login

Ahora intenta iniciar sesión en tu aplicación:

```
Email: admin@rambopet.com
Contraseña: Admin123!
```

---

## 🔍 Solución de Problemas

### Si sigue sin funcionar:

1. **Verifica que los usuarios se crearon**:
   - Ve a Authentication > Users
   - Deberías ver los 5 usuarios listados
   - Verifica que tengan el estado "confirmed" (✅)

2. **Verifica la configuración de Supabase**:
   - Ve a Settings > API
   - Copia tu `SUPABASE_URL` y `SUPABASE_ANON_KEY`
   - Verifica que estén correctamente en `web/.env`

3. **Reinicia el servidor web**:
   ```bash
   cd web
   npm run dev
   ```

---

## 📝 Credenciales de Todos los Usuarios

```
Admin:      admin@rambopet.com / Admin123!
Médico:     medico@rambopet.com / Medico123!
Recepción:  recepcion@rambopet.com / Recepcion123!
Tutor 1:    tutor@rambopet.com / Tutor123!
Tutor 2:    tutor2@rambopet.com / Tutor123!
```
