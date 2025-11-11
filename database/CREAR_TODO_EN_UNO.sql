-- ============================================================================
-- SCRIPT TODO-EN-UNO: Crear Usuarios y Datos de Prueba
-- ============================================================================
-- Ejecuta este script COMPLETO en Supabase SQL Editor
-- ============================================================================

-- Habilitar extensión para contraseñas hasheadas
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- ELIMINAR USUARIOS EXISTENTES (si quieres empezar desde cero)
-- ============================================================================
-- Descomenta estas líneas si quieres eliminar usuarios existentes
-- DELETE FROM auth.users WHERE email LIKE '%@rambopet.com';
-- DELETE FROM users WHERE email LIKE '%@rambopet.com';

-- ============================================================================
-- CREAR USUARIOS CON CONTRASEÑAS HASHEADAS
-- ============================================================================

DO $$
DECLARE
    admin_id UUID;
    medico_id UUID;
    recepcion_id UUID;
    tutor1_id UUID;
    tutor2_id UUID;
BEGIN
    -- ============================================================================
    -- CREAR USUARIO ADMIN
    -- ============================================================================
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
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
        'admin@rambopet.com',
        crypt('Admin123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{"nombre_completo":"Carlos Ramírez Admin"}'::jsonb,
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    )
    ON CONFLICT (email) DO UPDATE SET
        encrypted_password = crypt('Admin123!', gen_salt('bf')),
        updated_at = NOW()
    RETURNING id INTO admin_id;

    -- ============================================================================
    -- CREAR USUARIO MÉDICO
    -- ============================================================================
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
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
        'medico@rambopet.com',
        crypt('Medico123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{"nombre_completo":"Dra. María Fernández"}'::jsonb,
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    )
    ON CONFLICT (email) DO UPDATE SET
        encrypted_password = crypt('Medico123!', gen_salt('bf')),
        updated_at = NOW()
    RETURNING id INTO medico_id;

    -- ============================================================================
    -- CREAR USUARIO RECEPCIÓN
    -- ============================================================================
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
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
        'recepcion@rambopet.com',
        crypt('Recepcion123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{"nombre_completo":"Laura González Pérez"}'::jsonb,
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    )
    ON CONFLICT (email) DO UPDATE SET
        encrypted_password = crypt('Recepcion123!', gen_salt('bf')),
        updated_at = NOW()
    RETURNING id INTO recepcion_id;

    -- ============================================================================
    -- CREAR USUARIO TUTOR 1
    -- ============================================================================
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
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
        'tutor@rambopet.com',
        crypt('Tutor123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{"nombre_completo":"Juan Carlos Martínez"}'::jsonb,
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    )
    ON CONFLICT (email) DO UPDATE SET
        encrypted_password = crypt('Tutor123!', gen_salt('bf')),
        updated_at = NOW()
    RETURNING id INTO tutor1_id;

    -- ============================================================================
    -- CREAR USUARIO TUTOR 2
    -- ============================================================================
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
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
        'tutor2@rambopet.com',
        crypt('Tutor123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{"nombre_completo":"Ana Patricia Rodríguez"}'::jsonb,
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    )
    ON CONFLICT (email) DO UPDATE SET
        encrypted_password = crypt('Tutor123!', gen_salt('bf')),
        updated_at = NOW()
    RETURNING id INTO tutor2_id;

    -- ============================================================================
    -- INSERTAR EN TABLA USERS
    -- ============================================================================
    INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol, activo)
    VALUES
        (admin_id, 'admin@rambopet.com', 'Carlos Ramírez Admin', '+57 300 123 4567', 'admin', true),
        (medico_id, 'medico@rambopet.com', 'Dra. María Fernández', '+57 300 234 5678', 'medico', true),
        (recepcion_id, 'recepcion@rambopet.com', 'Laura González Pérez', '+57 300 345 6789', 'recepcion', true),
        (tutor1_id, 'tutor@rambopet.com', 'Juan Carlos Martínez', '+57 300 456 7890', 'tutor', true),
        (tutor2_id, 'tutor2@rambopet.com', 'Ana Patricia Rodríguez', '+57 300 567 8901', 'tutor', true)
    ON CONFLICT (email) DO UPDATE SET
        auth_user_id = EXCLUDED.auth_user_id,
        nombre_completo = EXCLUDED.nombre_completo,
        telefono = EXCLUDED.telefono,
        rol = EXCLUDED.rol,
        activo = EXCLUDED.activo;

    RAISE NOTICE '✅ Usuarios creados en auth.users y users';

    -- ============================================================================
    -- CREAR PROFESIONAL
    -- ============================================================================
    INSERT INTO profesionales (user_id, numero_registro_profesional, especialidad, universidad, anio_graduacion, activo)
    SELECT id, 'MP-2024-001', 'Medicina Veterinaria General', 'Universidad Nacional', 2018, true
    FROM users WHERE email = 'medico@rambopet.com'
    ON CONFLICT DO NOTHING;

    -- ============================================================================
    -- CREAR TUTORES
    -- ============================================================================
    INSERT INTO tutores (user_id, dni, direccion, ciudad, pais, activo)
    SELECT id, '1234567890', 'Calle 123 #45-67', 'Bogotá', 'Colombia', true
    FROM users WHERE email = 'tutor@rambopet.com'
    ON CONFLICT DO NOTHING;

    INSERT INTO tutores (user_id, dni, direccion, ciudad, pais, activo)
    SELECT id, '9876543210', 'Carrera 45 #12-34', 'Medellín', 'Colombia', true
    FROM users WHERE email = 'tutor2@rambopet.com'
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Profesionales y tutores creados';

    -- ============================================================================
    -- CREAR SERVICIOS
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
    -- CREAR CONSULTORIOS
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
    -- CREAR MEDICAMENTOS
    -- ============================================================================
    INSERT INTO farmacos (nombre_comercial, nombre_generico, laboratorio, presentacion, forma_farmaceutica, via_administracion, stock_minimo, stock_total, requiere_receta, activo)
    VALUES
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
    -- CREAR MASCOTAS
    -- ============================================================================
    INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, microchip, estado, esterilizado, activo)
    SELECT t.id, 'Max', 'Canino', 'Labrador Retriever', 'Macho', '2020-03-15', 28.5, 'Dorado', 'MX123456789', 'aprobado', true, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor@rambopet.com'
    ON CONFLICT DO NOTHING;

    INSERT INTO mascotas (tutor_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg, color, estado, esterilizado, activo, alergias)
    SELECT t.id, 'Luna', 'Felino', 'Persa', 'Hembra', '2021-07-20', 4.2, 'Blanco', 'aprobado', true, true, 'Alergia a pollo'
    FROM tutores t INNER JOIN users u ON t.user_id = u.id WHERE u.email = 'tutor@rambopet.com'
    ON CONFLICT DO NOTHING;

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
    -- CREAR CITAS
    -- ============================================================================
    INSERT INTO citas (tutor_id, mascota_id, servicio_id, profesional_id, consultorio_id, fecha_hora, duracion_estimada_min, motivo_consulta, estado)
    SELECT t.id, m.id, s.id, p.id, c.id, CURRENT_DATE + INTERVAL '14 hours', 30, 'Consulta de control general', 'confirmada'
    FROM tutores t
    INNER JOIN users u ON t.user_id = u.id
    INNER JOIN mascotas m ON m.tutor_id = t.id AND m.nombre = 'Max'
    CROSS JOIN (SELECT id FROM servicios WHERE nombre = 'Consulta General' LIMIT 1) s
    CROSS JOIN (SELECT id FROM profesionales LIMIT 1) p
    CROSS JOIN (SELECT id FROM consultorios WHERE nombre = 'Consultorio 1' LIMIT 1) c
    WHERE u.email = 'tutor@rambopet.com'
    ON CONFLICT DO NOTHING;

    INSERT INTO citas (tutor_id, mascota_id, servicio_id, profesional_id, consultorio_id, fecha_hora, duracion_estimada_min, motivo_consulta, estado)
    SELECT t.id, m.id, s.id, p.id, c.id, CURRENT_DATE + INTERVAL '2 days' + INTERVAL '10 hours', 20, 'Vacunación anual', 'reservada'
    FROM tutores t
    INNER JOIN users u ON t.user_id = u.id
    INNER JOIN mascotas m ON m.tutor_id = t.id AND m.nombre = 'Rocky'
    CROSS JOIN (SELECT id FROM servicios WHERE nombre = 'Vacunación Múltiple' LIMIT 1) s
    CROSS JOIN (SELECT id FROM profesionales LIMIT 1) p
    CROSS JOIN (SELECT id FROM consultorios WHERE nombre = 'Consultorio 2' LIMIT 1) c
    WHERE u.email = 'tutor2@rambopet.com'
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Citas creadas';

    -- ============================================================================
    -- RESUMEN
    -- ============================================================================
    RAISE NOTICE '';
    RAISE NOTICE '═════════════════════════════════════════════════════════════';
    RAISE NOTICE '✅ ¡TODO CREADO EXITOSAMENTE!';
    RAISE NOTICE '═════════════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '👤 USUARIOS CON CONTRASEÑAS HASHEADAS:';
    RAISE NOTICE '   • admin@rambopet.com / Admin123!';
    RAISE NOTICE '   • medico@rambopet.com / Medico123!';
    RAISE NOTICE '   • recepcion@rambopet.com / Recepcion123!';
    RAISE NOTICE '   • tutor@rambopet.com / Tutor123!';
    RAISE NOTICE '   • tutor2@rambopet.com / Tutor123!';
    RAISE NOTICE '';
    RAISE NOTICE '🐾 5 Mascotas creadas';
    RAISE NOTICE '🏥 8 Servicios creados';
    RAISE NOTICE '🏢 4 Consultorios creados';
    RAISE NOTICE '💊 7 Medicamentos creados';
    RAISE NOTICE '📅 2 Citas creadas';
    RAISE NOTICE '';
    RAISE NOTICE 'Ahora puedes iniciar sesión en: http://localhost:5173';
    RAISE NOTICE '═════════════════════════════════════════════════════════════';

END $$;

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================
SELECT '✅ VERIFICACIÓN DE USUARIOS' as status;

SELECT
    u.email,
    u.nombre_completo,
    u.rol,
    CASE WHEN u.auth_user_id IS NOT NULL THEN '✅ Vinculado' ELSE '❌ No vinculado' END as auth_status
FROM users u
WHERE u.email LIKE '%@rambopet.com'
ORDER BY u.rol, u.email;
