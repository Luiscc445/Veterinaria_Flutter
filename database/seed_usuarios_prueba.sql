-- ============================================================================
-- SCRIPT DE USUARIOS DE PRUEBA - SISTEMA RAMBOPET
-- ============================================================================
-- Este script crea usuarios de prueba para cada rol del sistema
-- ============================================================================

-- IMPORTANTE: Antes de ejecutar este script, debes crear los usuarios
-- en Supabase Auth desde el Dashboard:
--
-- 1. Ve a Authentication > Users > Add User
-- 2. Crea estos usuarios con las credenciales indicadas abajo
-- 3. Copia el UUID generado para cada usuario
-- 4. Reemplaza los UUIDs en este script con los UUIDs reales
-- ============================================================================

-- ============================================================================
-- PASO 1: CREAR USUARIOS EN SUPABASE AUTH (HACER DESDE EL DASHBOARD)
-- ============================================================================
--
-- Usuario 1 - Administrador
-- Email: admin@rambopet.com
-- Password: Admin123!
--
-- Usuario 2 - Médico Veterinario
-- Email: medico@rambopet.com
-- Password: Medico123!
--
-- Usuario 3 - Recepcionista
-- Email: recepcion@rambopet.com
-- Password: Recepcion123!
--
-- Usuario 4 - Tutor de Mascotas
-- Email: tutor@rambopet.com
-- Password: Tutor123!
--
-- Usuario 5 - Tutor 2
-- Email: tutor2@rambopet.com
-- Password: Tutor123!
-- ============================================================================

-- ============================================================================
-- PASO 2: INSERTAR DATOS EN TABLA USERS
-- ============================================================================

-- NOTA: Reemplaza los UUIDs de auth_user_id con los UUIDs reales de Supabase Auth
-- Puedes obtenerlos desde: Authentication > Users en Supabase Dashboard

-- Limpiar datos existentes de prueba (opcional)
-- DELETE FROM users WHERE email LIKE '%@rambopet.com';

-- Usuario 1: Administrador
INSERT INTO users (
    auth_user_id,
    email,
    nombre_completo,
    telefono,
    rol,
    activo
) VALUES (
    NULL, -- REEMPLAZAR con UUID de auth.users del admin
    'admin@rambopet.com',
    'Carlos Ramírez Admin',
    '+57 300 123 4567',
    'admin',
    true
) ON CONFLICT (email) DO UPDATE SET
    nombre_completo = EXCLUDED.nombre_completo,
    telefono = EXCLUDED.telefono,
    rol = EXCLUDED.rol,
    activo = EXCLUDED.activo;

-- Usuario 2: Médico Veterinario
INSERT INTO users (
    auth_user_id,
    email,
    nombre_completo,
    telefono,
    rol,
    activo
) VALUES (
    NULL, -- REEMPLAZAR con UUID de auth.users del médico
    'medico@rambopet.com',
    'Dra. María Fernández',
    '+57 300 234 5678',
    'medico',
    true
) ON CONFLICT (email) DO UPDATE SET
    nombre_completo = EXCLUDED.nombre_completo,
    telefono = EXCLUDED.telefono,
    rol = EXCLUDED.rol,
    activo = EXCLUDED.activo;

-- Usuario 3: Recepcionista
INSERT INTO users (
    auth_user_id,
    email,
    nombre_completo,
    telefono,
    rol,
    activo
) VALUES (
    NULL, -- REEMPLAZAR con UUID de auth.users del recepcionista
    'recepcion@rambopet.com',
    'Laura González Pérez',
    '+57 300 345 6789',
    'recepcion',
    true
) ON CONFLICT (email) DO UPDATE SET
    nombre_completo = EXCLUDED.nombre_completo,
    telefono = EXCLUDED.telefono,
    rol = EXCLUDED.rol,
    activo = EXCLUDED.activo;

-- Usuario 4: Tutor de Mascotas
INSERT INTO users (
    auth_user_id,
    email,
    nombre_completo,
    telefono,
    rol,
    activo
) VALUES (
    NULL, -- REEMPLAZAR con UUID de auth.users del tutor
    'tutor@rambopet.com',
    'Juan Carlos Martínez',
    '+57 300 456 7890',
    'tutor',
    true
) ON CONFLICT (email) DO UPDATE SET
    nombre_completo = EXCLUDED.nombre_completo,
    telefono = EXCLUDED.telefono,
    rol = EXCLUDED.rol,
    activo = EXCLUDED.activo;

-- Usuario 5: Tutor 2
INSERT INTO users (
    auth_user_id,
    email,
    nombre_completo,
    telefono,
    rol,
    activo
) VALUES (
    NULL, -- REEMPLAZAR con UUID de auth.users del tutor2
    'tutor2@rambopet.com',
    'Ana Patricia Rodríguez',
    '+57 300 567 8901',
    'tutor',
    true
) ON CONFLICT (email) DO UPDATE SET
    nombre_completo = EXCLUDED.nombre_completo,
    telefono = EXCLUDED.telefono,
    rol = EXCLUDED.rol,
    activo = EXCLUDED.activo;

-- ============================================================================
-- PASO 3: CREAR DATOS COMPLEMENTARIOS
-- ============================================================================

-- Crear profesional para el médico
INSERT INTO profesionales (
    user_id,
    numero_registro_profesional,
    especialidad,
    universidad,
    anio_graduacion,
    activo
) SELECT
    id,
    'MP-2024-001',
    'Medicina Veterinaria General',
    'Universidad Nacional',
    2018,
    true
FROM users
WHERE email = 'medico@rambopet.com'
ON CONFLICT DO NOTHING;

-- Crear tutores para los usuarios tutor
INSERT INTO tutores (
    user_id,
    dni,
    direccion,
    ciudad,
    pais,
    activo
) SELECT
    id,
    '1234567890',
    'Calle 123 #45-67',
    'Bogotá',
    'Colombia',
    true
FROM users
WHERE email = 'tutor@rambopet.com'
ON CONFLICT DO NOTHING;

INSERT INTO tutores (
    user_id,
    dni,
    direccion,
    ciudad,
    pais,
    activo
) SELECT
    id,
    '9876543210',
    'Carrera 45 #12-34',
    'Medellín',
    'Colombia',
    true
FROM users
WHERE email = 'tutor2@rambopet.com'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- PASO 4: CREAR SERVICIOS DE PRUEBA
-- ============================================================================

INSERT INTO servicios (nombre, tipo_servicio, precio_base, duracion_estimada_min, activo)
VALUES
    ('Consulta General', 'consulta_general', 50000, 30, true),
    ('Vacunación Múltiple', 'vacunacion', 80000, 20, true),
    ('Desparasitación', 'desparasitacion', 30000, 15, true),
    ('Cirugía Menor', 'cirugia', 200000, 90, true),
    ('Control Post-Operatorio', 'control', 40000, 20, true),
    ('Baño y Peluquería', 'estetica', 60000, 60, true)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- PASO 5: CREAR CONSULTORIOS DE PRUEBA
-- ============================================================================

INSERT INTO consultorios (nombre, tipo, activo)
VALUES
    ('Consultorio 1', 'general', true),
    ('Consultorio 2', 'general', true),
    ('Sala de Cirugía', 'cirugia', true),
    ('Sala de Urgencias', 'urgencias', true)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- PASO 6: CREAR MEDICAMENTOS DE PRUEBA
-- ============================================================================

INSERT INTO farmacos (
    nombre_comercial,
    nombre_generico,
    laboratorio,
    presentacion,
    forma_farmaceutica,
    via_administracion,
    stock_minimo,
    requiere_receta,
    activo
) VALUES
    ('Drontal Plus', 'Praziquantel + Pirantel', 'Bayer', '20 comprimidos', 'Comprimido', 'Oral', 10, false, true),
    ('Nexgard', 'Afoxolaner', 'Boehringer', '3 tabletas masticables', 'Tableta masticable', 'Oral', 15, false, true),
    ('Metacam', 'Meloxicam', 'Boehringer', '100ml solución oral', 'Solución', 'Oral', 5, true, true),
    ('Amoxicilina 500mg', 'Amoxicilina', 'Genérico', '20 comprimidos', 'Comprimido', 'Oral', 20, true, true),
    ('Ranitidina 150mg', 'Ranitidina', 'Genérico', '30 comprimidos', 'Comprimido', 'Oral', 15, true, true)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- PASO 7: CREAR MASCOTAS DE PRUEBA
-- ============================================================================

-- Mascotas para tutor 1
INSERT INTO mascotas (
    tutor_id,
    nombre,
    especie,
    raza,
    sexo,
    fecha_nacimiento,
    peso_kg,
    color,
    microchip,
    estado,
    esterilizado,
    activo
) SELECT
    t.id,
    'Max',
    'Canino',
    'Labrador Retriever',
    'Macho',
    '2020-03-15',
    28.5,
    'Dorado',
    'MX123456789',
    'aprobado',
    true,
    true
FROM tutores t
INNER JOIN users u ON t.user_id = u.id
WHERE u.email = 'tutor@rambopet.com'
ON CONFLICT DO NOTHING;

INSERT INTO mascotas (
    tutor_id,
    nombre,
    especie,
    raza,
    sexo,
    fecha_nacimiento,
    peso_kg,
    color,
    estado,
    esterilizado,
    activo
) SELECT
    t.id,
    'Luna',
    'Felino',
    'Persa',
    'Hembra',
    '2021-07-20',
    4.2,
    'Blanco',
    'aprobado',
    true,
    true
FROM tutores t
INNER JOIN users u ON t.user_id = u.id
WHERE u.email = 'tutor@rambopet.com'
ON CONFLICT DO NOTHING;

-- Mascotas para tutor 2
INSERT INTO mascotas (
    tutor_id,
    nombre,
    especie,
    raza,
    sexo,
    fecha_nacimiento,
    peso_kg,
    color,
    estado,
    esterilizado,
    activo
) SELECT
    t.id,
    'Rocky',
    'Canino',
    'Pastor Alemán',
    'Macho',
    '2019-05-10',
    35.0,
    'Negro y café',
    'aprobado',
    false,
    true
FROM tutores t
INNER JOIN users u ON t.user_id = u.id
WHERE u.email = 'tutor2@rambopet.com'
ON CONFLICT DO NOTHING;

-- Mascota pendiente de aprobación
INSERT INTO mascotas (
    tutor_id,
    nombre,
    especie,
    raza,
    sexo,
    fecha_nacimiento,
    peso_kg,
    color,
    estado,
    esterilizado,
    activo
) SELECT
    t.id,
    'Toby',
    'Canino',
    'Beagle',
    'Macho',
    '2023-01-15',
    12.0,
    'Tricolor',
    'pendiente',
    false,
    true
FROM tutores t
INNER JOIN users u ON t.user_id = u.id
WHERE u.email = 'tutor2@rambopet.com'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- VERIFICACIÓN: Consultar usuarios creados
-- ============================================================================

SELECT
    u.email,
    u.nombre_completo,
    u.rol,
    u.activo,
    CASE
        WHEN u.auth_user_id IS NULL THEN 'FALTA VINCULAR AUTH_USER_ID'
        ELSE 'Auth vinculado'
    END as estado_auth
FROM users u
WHERE u.email LIKE '%@rambopet.com'
ORDER BY u.rol, u.email;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================

-- RECORDATORIO:
-- 1. Crear usuarios en Supabase Auth Dashboard primero
-- 2. Reemplazar los NULL de auth_user_id con los UUIDs reales
-- 3. Ejecutar este script en Supabase SQL Editor
-- 4. Verificar los resultados con la consulta SELECT al final
-- ============================================================================
