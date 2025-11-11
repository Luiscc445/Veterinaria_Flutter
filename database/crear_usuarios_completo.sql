-- ============================================================================
-- SCRIPT COMPLETO: Crear Usuarios con Contraseñas en Supabase
-- ============================================================================
-- Este script crea usuarios directamente en auth.users con contraseñas hasheadas
-- y los vincula con la tabla users
-- ============================================================================

-- IMPORTANTE: Este script debe ejecutarse con privilegios de administrador
-- Si da error de permisos, usa el método alternativo en GUIA_CREAR_USUARIOS.md
-- ============================================================================

-- Función auxiliar para crear usuarios en auth.users
CREATE OR REPLACE FUNCTION create_user_with_password(
    user_email TEXT,
    user_password TEXT,
    user_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_id UUID;
    encrypted_pw TEXT;
BEGIN
    -- Generar hash de contraseña usando crypt
    encrypted_pw := crypt(user_password, gen_salt('bf'));

    -- Insertar en auth.users
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        recovery_sent_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        user_email,
        encrypted_pw,
        NOW(),
        NOW(),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        user_metadata,
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    )
    RETURNING id INTO user_id;

    RETURN user_id;
END;
$$;

-- ============================================================================
-- PASO 1: Crear usuarios en auth.users con contraseñas
-- ============================================================================

DO $$
DECLARE
    admin_auth_id UUID;
    medico_auth_id UUID;
    recepcion_auth_id UUID;
    tutor1_auth_id UUID;
    tutor2_auth_id UUID;
BEGIN
    -- Verificar si ya existen y eliminar si es necesario
    DELETE FROM auth.users WHERE email IN (
        'admin@rambopet.com',
        'medico@rambopet.com',
        'recepcion@rambopet.com',
        'tutor@rambopet.com',
        'tutor2@rambopet.com'
    );

    -- Crear usuario Administrador
    admin_auth_id := create_user_with_password(
        'admin@rambopet.com',
        'Admin123!',
        '{"nombre_completo": "Carlos Ramírez Admin"}'::jsonb
    );
    RAISE NOTICE 'Admin creado: %', admin_auth_id;

    -- Crear usuario Médico
    medico_auth_id := create_user_with_password(
        'medico@rambopet.com',
        'Medico123!',
        '{"nombre_completo": "Dra. María Fernández"}'::jsonb
    );
    RAISE NOTICE 'Médico creado: %', medico_auth_id;

    -- Crear usuario Recepcionista
    recepcion_auth_id := create_user_with_password(
        'recepcion@rambopet.com',
        'Recepcion123!',
        '{"nombre_completo": "Laura González Pérez"}'::jsonb
    );
    RAISE NOTICE 'Recepcionista creado: %', recepcion_auth_id;

    -- Crear usuario Tutor 1
    tutor1_auth_id := create_user_with_password(
        'tutor@rambopet.com',
        'Tutor123!',
        '{"nombre_completo": "Juan Carlos Martínez"}'::jsonb
    );
    RAISE NOTICE 'Tutor 1 creado: %', tutor1_auth_id;

    -- Crear usuario Tutor 2
    tutor2_auth_id := create_user_with_password(
        'tutor2@rambopet.com',
        'Tutor123!',
        '{"nombre_completo": "Ana Patricia Rodríguez"}'::jsonb
    );
    RAISE NOTICE 'Tutor 2 creado: %', tutor2_auth_id;

    -- ============================================================================
    -- PASO 2: Insertar en tabla users
    -- ============================================================================

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

    RAISE NOTICE '✅ Usuarios creados en tabla users';

    -- ============================================================================
    -- PASO 3: Crear datos complementarios
    -- ============================================================================

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

    RAISE NOTICE '✅ Tutores y profesionales creados';

    -- ============================================================================
    -- PASO 4: Crear servicios
    -- ============================================================================

    INSERT INTO servicios (nombre, tipo_servicio, precio_base, duracion_estimada_min, activo)
    VALUES
        ('Consulta General', 'consulta_general', 50000, 30, true),
        ('Vacunación Múltiple', 'vacunacion', 80000, 20, true),
        ('Desparasitación', 'desparasitacion', 30000, 15, true),
        ('Cirugía Menor', 'cirugia', 200000, 90, true),
        ('Control Post-Operatorio', 'control', 40000, 20, true),
        ('Baño y Peluquería', 'estetica', 60000, 60, true),
        ('Urgencias 24h', 'emergencia', 100000, 45, true),
        ('Análisis de Laboratorio', 'laboratorio', 75000, 60, true)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Servicios creados';

    -- ============================================================================
    -- PASO 5: Crear consultorios
    -- ============================================================================

    INSERT INTO consultorios (nombre, tipo, activo)
    VALUES
        ('Consultorio 1', 'general', true),
        ('Consultorio 2', 'general', true),
        ('Sala de Cirugía', 'cirugia', true),
        ('Sala de Urgencias', 'urgencias', true)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Consultorios creados';

    -- ============================================================================
    -- PASO 6: Crear medicamentos
    -- ============================================================================

    INSERT INTO farmacos (
        nombre_comercial,
        nombre_generico,
        laboratorio,
        presentacion,
        forma_farmaceutica,
        via_administracion,
        stock_minimo,
        stock_total,
        requiere_receta,
        activo
    ) VALUES
        ('Drontal Plus', 'Praziquantel + Pirantel', 'Bayer', '20 comprimidos', 'Comprimido', 'Oral', 10, 50, false, true),
        ('Nexgard', 'Afoxolaner', 'Boehringer', '3 tabletas', 'Tableta masticable', 'Oral', 15, 45, false, true),
        ('Metacam', 'Meloxicam', 'Boehringer', '100ml', 'Solución', 'Oral', 5, 12, true, true),
        ('Amoxicilina 500mg', 'Amoxicilina', 'Genérico', '20 comprimidos', 'Comprimido', 'Oral', 20, 100, true, true),
        ('Ranitidina 150mg', 'Ranitidina', 'Genérico', '30 comprimidos', 'Comprimido', 'Oral', 15, 8, true, true),
        ('Frontline Plus', 'Fipronil + Methoprene', 'Boehringer', '3 pipetas', 'Pipeta', 'Tópico', 12, 30, false, true),
        ('Cefalexina 500mg', 'Cefalexina', 'Genérico', '20 cápsulas', 'Cápsula', 'Oral', 15, 60, true, true)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Medicamentos creados';

    -- ============================================================================
    -- PASO 7: Crear mascotas
    -- ============================================================================

    -- Mascotas para tutor 1 (Juan Carlos)
    INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, microchip, estado, esterilizado, activo)
    SELECT t.id, 'Max', 'Canino', 'Labrador Retriever', 'Macho', '2020-03-15', 28.5, 'Dorado', 'MX123456789', 'aprobado', true, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor@rambopet.com'
    ON CONFLICT DO NOTHING;

    INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, estado, esterilizado, activo, alergias)
    SELECT t.id, 'Luna', 'Felino', 'Persa', 'Hembra', '2021-07-20', 4.2, 'Blanco', 'aprobado', true, true, 'Alergia a pollo'
    FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor@rambopet.com'
    ON CONFLICT DO NOTHING;

    -- Mascotas para tutor 2 (Ana Patricia)
    INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, estado, esterilizado, activo)
    SELECT t.id, 'Rocky', 'Canino', 'Pastor Alemán', 'Macho', '2019-05-10', 35.0, 'Negro y café', 'aprobado', false, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor2@rambopet.com'
    ON CONFLICT DO NOTHING;

    INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, estado, esterilizado, activo)
    SELECT t.id, 'Toby', 'Canino', 'Beagle', 'Macho', '2023-01-15', 12.0, 'Tricolor', 'pendiente', false, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor2@rambopet.com'
    ON CONFLICT DO NOTHING;

    INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, estado, esterilizado, activo)
    SELECT t.id, 'Mia', 'Felino', 'Siamés', 'Hembra', '2022-09-05', 3.8, 'Crema', 'aprobado', true, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor2@rambopet.com'
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Mascotas creadas';

    -- ============================================================================
    -- PASO 8: Crear citas de ejemplo
    -- ============================================================================

    -- Cita para hoy
    INSERT INTO citas (
        tutor_id,
        mascota_id,
        servicio_id,
        profesional_id,
        consultorio_id,
        fecha_hora,
        duracion_estimada_min,
        motivo_consulta,
        estado
    )
    SELECT
        t.id,
        m.id,
        s.id,
        p.id,
        c.id,
        CURRENT_DATE + INTERVAL '14 hours',
        30,
        'Consulta de control general',
        'confirmada'
    FROM tutores t
    INNER JOIN users u ON t.user_id = u.id
    INNER JOIN mascotas m ON m.tutor_id = t.id AND m.nombre = 'Max'
    CROSS JOIN (SELECT id FROM servicios WHERE nombre = 'Consulta General' LIMIT 1) s
    CROSS JOIN (SELECT id FROM profesionales LIMIT 1) p
    CROSS JOIN (SELECT id FROM consultorios WHERE nombre = 'Consultorio 1' LIMIT 1) c
    WHERE u.email = 'tutor@rambopet.com'
    ON CONFLICT DO NOTHING;

    -- Cita reservada (pendiente)
    INSERT INTO citas (
        tutor_id,
        mascota_id,
        servicio_id,
        profesional_id,
        consultorio_id,
        fecha_hora,
        duracion_estimada_min,
        motivo_consulta,
        estado
    )
    SELECT
        t.id,
        m.id,
        s.id,
        p.id,
        c.id,
        CURRENT_DATE + INTERVAL '2 days' + INTERVAL '10 hours',
        20,
        'Vacunación anual',
        'reservada'
    FROM tutores t
    INNER JOIN users u ON t.user_id = u.id
    INNER JOIN mascotas m ON m.tutor_id = t.id AND m.nombre = 'Rocky'
    CROSS JOIN (SELECT id FROM servicios WHERE nombre = 'Vacunación Múltiple' LIMIT 1) s
    CROSS JOIN (SELECT id FROM profesionales LIMIT 1) p
    CROSS JOIN (SELECT id FROM consultorios WHERE nombre = 'Consultorio 2' LIMIT 1) c
    WHERE u.email = 'tutor2@rambopet.com'
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Citas creadas';

END $$;

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================

-- Verificar usuarios creados
SELECT
    '👤 USUARIOS' as tipo,
    u.email,
    u.nombre_completo,
    u.rol,
    CASE WHEN u.auth_user_id IS NOT NULL THEN '✅' ELSE '❌' END as auth_vinculado
FROM users u
WHERE u.email LIKE '%@rambopet.com'
ORDER BY u.rol, u.email;

-- Verificar mascotas
SELECT
    '🐾 MASCOTAS' as tipo,
    m.nombre,
    m.especie,
    m.estado,
    u.email as tutor_email
FROM mascotas m
INNER JOIN tutores t ON m.tutor_id = t.id
INNER JOIN users u ON t.user_id = u.id
ORDER BY u.email, m.nombre;

-- Verificar servicios
SELECT '🏥 SERVICIOS' as tipo, COUNT(*) as total FROM servicios;

-- Verificar medicamentos
SELECT '💊 MEDICAMENTOS' as tipo, COUNT(*) as total FROM farmacos;

-- Verificar citas
SELECT '📅 CITAS' as tipo, COUNT(*) as total FROM citas;

-- ============================================================================
-- LIMPIAR FUNCIÓN TEMPORAL
-- ============================================================================
DROP FUNCTION IF EXISTS create_user_with_password(TEXT, TEXT, JSONB);

-- ============================================================================
-- RESUMEN
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════════════';
    RAISE NOTICE '✅ USUARIOS DE PRUEBA CREADOS EXITOSAMENTE';
    RAISE NOTICE '═══════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE 'Credenciales de acceso:';
    RAISE NOTICE '';
    RAISE NOTICE '👤 ADMIN:        admin@rambopet.com / Admin123!';
    RAISE NOTICE '👨‍⚕️ MÉDICO:       medico@rambopet.com / Medico123!';
    RAISE NOTICE '📋 RECEPCIÓN:    recepcion@rambopet.com / Recepcion123!';
    RAISE NOTICE '👥 TUTOR 1:      tutor@rambopet.com / Tutor123!';
    RAISE NOTICE '👥 TUTOR 2:      tutor2@rambopet.com / Tutor123!';
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════════════';
END $$;
