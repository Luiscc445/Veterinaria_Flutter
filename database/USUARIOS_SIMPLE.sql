-- ============================================================================
-- SCRIPT SIMPLE Y CORRECTO - Crear Usuarios de Prueba RamboPet
-- ============================================================================
-- Este script está basado en el schema REAL de la base de datos
-- ============================================================================

-- Habilitar extensión para passwords
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- PARTE 1: CREAR USUARIOS EN AUTH.USERS
-- ============================================================================

DO $$
DECLARE
    v_admin_id UUID;
    v_medico_id UUID;
    v_recepcion_id UUID;
    v_tutor1_id UUID;
    v_tutor2_id UUID;
BEGIN
    RAISE NOTICE 'Iniciando creación de usuarios...';

    -- ADMIN
    INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
        created_at, updated_at, confirmation_token, email_change,
        email_change_token_new, recovery_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(), 'authenticated', 'authenticated',
        'admin@rambopet.com',
        crypt('Admin123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{}'::jsonb,
        NOW(), NOW(), '', '', '', ''
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_admin_id;

    -- Si el usuario ya existe, obtener su ID
    IF v_admin_id IS NULL THEN
        SELECT id INTO v_admin_id FROM auth.users WHERE email = 'admin@rambopet.com';
        UPDATE auth.users SET encrypted_password = crypt('Admin123!', gen_salt('bf'))
        WHERE email = 'admin@rambopet.com';
    END IF;

    -- MEDICO
    INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
        created_at, updated_at, confirmation_token, email_change,
        email_change_token_new, recovery_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(), 'authenticated', 'authenticated',
        'medico@rambopet.com',
        crypt('Medico123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{}'::jsonb,
        NOW(), NOW(), '', '', '', ''
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_medico_id;

    IF v_medico_id IS NULL THEN
        SELECT id INTO v_medico_id FROM auth.users WHERE email = 'medico@rambopet.com';
        UPDATE auth.users SET encrypted_password = crypt('Medico123!', gen_salt('bf'))
        WHERE email = 'medico@rambopet.com';
    END IF;

    -- RECEPCION
    INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
        created_at, updated_at, confirmation_token, email_change,
        email_change_token_new, recovery_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(), 'authenticated', 'authenticated',
        'recepcion@rambopet.com',
        crypt('Recepcion123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{}'::jsonb,
        NOW(), NOW(), '', '', '', ''
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_recepcion_id;

    IF v_recepcion_id IS NULL THEN
        SELECT id INTO v_recepcion_id FROM auth.users WHERE email = 'recepcion@rambopet.com';
        UPDATE auth.users SET encrypted_password = crypt('Recepcion123!', gen_salt('bf'))
        WHERE email = 'recepcion@rambopet.com';
    END IF;

    -- TUTOR 1
    INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
        created_at, updated_at, confirmation_token, email_change,
        email_change_token_new, recovery_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(), 'authenticated', 'authenticated',
        'tutor@rambopet.com',
        crypt('Tutor123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{}'::jsonb,
        NOW(), NOW(), '', '', '', ''
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_tutor1_id;

    IF v_tutor1_id IS NULL THEN
        SELECT id INTO v_tutor1_id FROM auth.users WHERE email = 'tutor@rambopet.com';
        UPDATE auth.users SET encrypted_password = crypt('Tutor123!', gen_salt('bf'))
        WHERE email = 'tutor@rambopet.com';
    END IF;

    -- TUTOR 2
    INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
        created_at, updated_at, confirmation_token, email_change,
        email_change_token_new, recovery_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(), 'authenticated', 'authenticated',
        'tutor2@rambopet.com',
        crypt('Tutor123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{}'::jsonb,
        NOW(), NOW(), '', '', '', ''
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_tutor2_id;

    IF v_tutor2_id IS NULL THEN
        SELECT id INTO v_tutor2_id FROM auth.users WHERE email = 'tutor2@rambopet.com';
        UPDATE auth.users SET encrypted_password = crypt('Tutor123!', gen_salt('bf'))
        WHERE email = 'tutor2@rambopet.com';
    END IF;

    RAISE NOTICE '✅ Usuarios creados en auth.users';

    -- ============================================================================
    -- PARTE 2: CREAR EN TABLA USERS
    -- ============================================================================

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

    RAISE NOTICE '✅ Usuarios en tabla users';

    -- ============================================================================
    -- PARTE 3: CREAR PROFESIONAL (basado en schema real)
    -- ============================================================================

    INSERT INTO profesionales (user_id, matricula_profesional, especialidades, anios_experiencia, activo)
    SELECT id, 'MP-2024-001', ARRAY['Medicina General', 'Cirugía'], 6, true
    FROM users WHERE email = 'medico@rambopet.com'
    ON CONFLICT (matricula_profesional) DO NOTHING;

    RAISE NOTICE '✅ Profesional creado';

    -- ============================================================================
    -- PARTE 4: CREAR TUTORES (basado en schema real)
    -- ============================================================================

    INSERT INTO tutores (user_id, dni, direccion, ciudad, provincia)
    SELECT id, '1234567890', 'Calle 123 #45-67', 'Bogotá', 'Cundinamarca'
    FROM users WHERE email = 'tutor@rambopet.com';

    INSERT INTO tutores (user_id, dni, direccion, ciudad, provincia)
    SELECT id, '9876543210', 'Carrera 45 #12-34', 'Medellín', 'Antioquia'
    FROM users WHERE email = 'tutor2@rambopet.com';

    RAISE NOTICE '✅ Tutores creados';

    -- ============================================================================
    -- PARTE 5: CREAR SERVICIOS (basado en schema real)
    -- ============================================================================

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

    -- ============================================================================
    -- PARTE 6: CREAR CONSULTORIOS (basado en schema real)
    -- ============================================================================

    INSERT INTO consultorios (nombre, numero, piso, activo)
    VALUES
        ('Consultorio General 1', '101', '1', true),
        ('Consultorio General 2', '102', '1', true),
        ('Sala de Cirugía', '201', '2', true),
        ('Urgencias', '103', '1', true)
    ON CONFLICT (numero) DO NOTHING;

    RAISE NOTICE '✅ Consultorios creados';

    -- ============================================================================
    -- PARTE 7: CREAR FARMACOS (basado en schema real)
    -- ============================================================================

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

    -- ============================================================================
    -- PARTE 8: CREAR MASCOTAS
    -- ============================================================================

    INSERT INTO mascotas (
        tutor_id, nombre, especie, raza, sexo, fecha_nacimiento,
        peso_kg, color, microchip, estado, esterilizado, activo
    )
    SELECT t.id, 'Max', 'Canino', 'Labrador Retriever', 'Macho',
           '2020-03-15', 28.5, 'Dorado', 'MX123456789', 'aprobado', true, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id
    WHERE u.email = 'tutor@rambopet.com';

    INSERT INTO mascotas (
        tutor_id, nombre, especie, raza, sexo, fecha_nacimiento,
        peso_kg, color, estado, esterilizado, activo, alergias
    )
    SELECT t.id, 'Luna', 'Felino', 'Persa', 'Hembra',
           '2021-07-20', 4.2, 'Blanco', 'aprobado', true, true, 'Alergia a pollo'
    FROM tutores t INNER JOIN users u ON t.user_id = u.id
    WHERE u.email = 'tutor@rambopet.com';

    INSERT INTO mascotas (
        tutor_id, nombre, especie, raza, sexo, fecha_nacimiento,
        peso_kg, color, estado, esterilizado, activo
    )
    SELECT t.id, 'Rocky', 'Canino', 'Pastor Alemán', 'Macho',
           '2019-05-10', 35.0, 'Negro y café', 'aprobado', false, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id
    WHERE u.email = 'tutor2@rambopet.com';

    INSERT INTO mascotas (
        tutor_id, nombre, especie, raza, sexo, fecha_nacimiento,
        peso_kg, color, estado, esterilizado, activo
    )
    SELECT t.id, 'Toby', 'Canino', 'Beagle', 'Macho',
           '2023-01-15', 12.0, 'Tricolor', 'pendiente', false, true
    FROM tutores t INNER JOIN users u ON t.user_id = u.id
    WHERE u.email = 'tutor2@rambopet.com';

    RAISE NOTICE '✅ Mascotas creadas';

    -- ============================================================================
    -- PARTE 9: CREAR CITAS
    -- ============================================================================

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
    WHERE u.email = 'tutor@rambopet.com';

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
    WHERE u.email = 'tutor2@rambopet.com';

    RAISE NOTICE '✅ Citas creadas';

    -- ============================================================================
    -- RESUMEN
    -- ============================================================================
    RAISE NOTICE '';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '✅ ¡USUARIOS CREADOS EXITOSAMENTE!';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '👤 CREDENCIALES:';
    RAISE NOTICE '   admin@rambopet.com / Admin123!';
    RAISE NOTICE '   medico@rambopet.com / Medico123!';
    RAISE NOTICE '   recepcion@rambopet.com / Recepcion123!';
    RAISE NOTICE '   tutor@rambopet.com / Tutor123!';
    RAISE NOTICE '   tutor2@rambopet.com / Tutor123!';
    RAISE NOTICE '';
    RAISE NOTICE '📊 DATOS:';
    RAISE NOTICE '   • 5 Usuarios';
    RAISE NOTICE '   • 4 Mascotas (1 pendiente)';
    RAISE NOTICE '   • 6 Servicios';
    RAISE NOTICE '   • 4 Consultorios';
    RAISE NOTICE '   • 5 Medicamentos';
    RAISE NOTICE '   • 2 Citas';
    RAISE NOTICE '';
    RAISE NOTICE 'URL: http://localhost:5173';
    RAISE NOTICE '════════════════════════════════════════════════════════';

END $$;

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

SELECT
    u.email,
    u.nombre_completo,
    u.rol,
    CASE WHEN u.auth_user_id IS NOT NULL THEN '✅' ELSE '❌' END as vinculado
FROM users u
WHERE u.email LIKE '%@rambopet.com'
ORDER BY u.rol, u.email;
