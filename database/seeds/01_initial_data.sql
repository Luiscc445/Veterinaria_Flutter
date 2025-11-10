-- ============================================================================
-- SEEDS DE DATOS INICIALES - SISTEMA RAMBOPET
-- ============================================================================
-- Este archivo contiene datos iniciales para iniciar el sistema
-- EJECUTAR DESPUÉS de schema.sql
-- ============================================================================

-- ============================================================================
-- 1. SERVICIOS VETERINARIOS BÁSICOS
-- ============================================================================

INSERT INTO servicios (nombre, tipo, descripcion, duracion_minutos, precio_base, activo) VALUES
('Consulta General', 'consulta_general', 'Consulta veterinaria general para evaluación y diagnóstico', 30, 25.00, true),
('Vacunación Antirrábica', 'vacunacion', 'Aplicación de vacuna contra la rabia', 15, 15.00, true),
('Vacunación Polivalente', 'vacunacion', 'Vacuna múltiple (parvovirus, moquillo, hepatitis, etc.)', 15, 20.00, true),
('Desparasitación Interna', 'desparasitacion', 'Tratamiento contra parásitos intestinales', 15, 12.00, true),
('Desparasitación Externa', 'desparasitacion', 'Tratamiento contra pulgas, garrapatas y ácaros', 15, 12.00, true),
('Cirugía Menor', 'cirugia', 'Procedimientos quirúrgicos menores (sutura, extracción, etc.)', 60, 80.00, true),
('Esterilización - Hembra', 'cirugia', 'Ovariohisterectomía', 120, 120.00, true),
('Castración - Macho', 'cirugia', 'Orquiectomía', 90, 80.00, true),
('Emergencia Veterinaria', 'emergencia', 'Atención de urgencia veterinaria', 45, 50.00, true),
('Control Post-Operatorio', 'control', 'Revisión y seguimiento post-cirugía', 20, 15.00, true),
('Baño y Peluquería', 'estetica', 'Servicio de estética y aseo', 60, 25.00, true),
('Corte de Uñas', 'estetica', 'Corte de uñas y limado', 15, 8.00, true),
('Limpieza Dental', 'estetica', 'Profilaxis dental profesional', 45, 40.00, true),
('Análisis Sangre Básico', 'laboratorio', 'Hemograma y química sanguínea básica', 30, 35.00, true),
('Análisis de Orina', 'laboratorio', 'Urianálisis completo', 20, 20.00, true),
('Rayos X', 'laboratorio', 'Estudio radiográfico', 30, 40.00, true),
('Ecografía', 'laboratorio', 'Estudio ecográfico', 30, 50.00, true),
('Hospitalización Día', 'hospitalizacion', 'Internación veterinaria por día', 1440, 60.00, true);

-- ============================================================================
-- 2. CONSULTORIOS
-- ============================================================================

INSERT INTO consultorios (nombre, numero, piso, equipamiento, capacidad, activo) VALUES
('Consultorio 1', '101', 'PB', ARRAY['Camilla', 'Estetoscopio', 'Termómetro', 'Balanza'], 1, true),
('Consultorio 2', '102', 'PB', ARRAY['Camilla', 'Estetoscopio', 'Termómetro', 'Balanza', 'Otoscopio'], 1, true),
('Quirófano', '201', '1P', ARRAY['Mesa quirúrgica', 'Anestesia', 'Monitor signos vitales', 'Instrumental quirúrgico'], 2, true),
('Sala Emergencias', '103', 'PB', ARRAY['Camilla', 'Desfibrilador', 'Oxígeno', 'Monitor'], 2, true),
('Sala Peluquería', '104', 'PB', ARRAY['Bañera', 'Mesa de grooming', 'Secador', 'Herramientas de corte'], 1, true);

-- ============================================================================
-- 3. FÁRMACOS BÁSICOS (Catálogo)
-- ============================================================================

INSERT INTO farmacos (
    nombre_comercial,
    nombre_generico,
    laboratorio,
    principio_activo,
    concentracion,
    forma_farmaceutica,
    unidad_medida,
    via_administracion,
    indicaciones,
    contraindicaciones,
    dosis_recomendada,
    requiere_receta,
    stock_minimo,
    activo
) VALUES
(
    'Amoxidal',
    'Amoxicilina',
    'Lab Richmond',
    'Amoxicilina',
    '500 mg',
    'Comprimido',
    'comp',
    ARRAY['oral'],
    'Infecciones bacterianas de vías respiratorias, piel y tejidos',
    'Hipersensibilidad a penicilinas',
    '10-20 mg/kg c/12h',
    true,
    20,
    true
),
(
    'Rimadyl',
    'Carprofeno',
    'Zoetis',
    'Carprofeno',
    '100 mg',
    'Comprimido',
    'comp',
    ARRAY['oral'],
    'Antiinflamatorio no esteroideo para dolor e inflamación',
    'Insuficiencia renal o hepática',
    '2-4 mg/kg c/24h',
    true,
    15,
    true
),
(
    'Advocate',
    'Imidacloprid',
    'Bayer',
    'Imidacloprid',
    '10%',
    'Pipeta',
    'ml',
    ARRAY['topica'],
    'Prevención y tratamiento de pulgas, dirofilariasis',
    'Cachorros < 7 semanas',
    'Según peso',
    false,
    30,
    true
),
(
    'Frontline Plus',
    'Fipronil',
    'Boehringer',
    'Fipronil',
    '9.8%',
    'Pipeta',
    'ml',
    ARRAY['topica'],
    'Control de pulgas, garrapatas y piojos',
    'Cachorros < 8 semanas',
    'Según peso',
    false,
    30,
    true
),
(
    'Drontal Plus',
    'Praziquantel',
    'Bayer',
    'Praziquantel',
    '50mg',
    'Comprimido',
    'comp',
    ARRAY['oral'],
    'Tratamiento de cestodos y nematodos intestinales',
    'Cachorros < 2 semanas',
    '1 comp/10kg',
    false,
    25,
    true
),
(
    'Tramadol',
    'Tramadol',
    'Gador',
    'Tramadol HCl',
    '50 mg',
    'Comprimido',
    'comp',
    ARRAY['oral'],
    'Analgésico para dolor moderado a severo',
    'Epilepsia no controlada',
    '2-4 mg/kg c/8h',
    true,
    20,
    true
),
(
    'Metronidazol',
    'Metronidazol',
    'Elea',
    'Metronidazol',
    '250 mg',
    'Comprimido',
    'comp',
    ARRAY['oral'],
    'Infecciones por protozoarios y bacterias anaerobias',
    'Hipersensibilidad',
    '15-25 mg/kg c/12h',
    true,
    15,
    true
),
(
    'Prednisolona',
    'Prednisolona',
    'Fabop',
    'Prednisolona',
    '20 mg',
    'Comprimido',
    'comp',
    ARRAY['oral'],
    'Antiinflamatorio corticoide, alergias',
    'Infecciones fúngicas',
    '0.5-2 mg/kg c/12h',
    true,
    10,
    true
),
(
    'Meloxicam',
    'Meloxicam',
    'Over',
    'Meloxicam',
    '15 mg',
    'Comprimido',
    'comp',
    ARRAY['oral'],
    'AINE, dolor crónico',
    'Insuficiencia renal',
    '0.1 mg/kg c/24h',
    true,
    15,
    true
),
(
    'Suero Fisiológico',
    'NaCl 0.9%',
    'Baxter',
    'Cloruro Sodio',
    '0.9%',
    'Inyectable',
    'ml',
    ARRAY['IV', 'SC'],
    'Rehidratación, vehículo para medicamentos',
    'Ninguna',
    'Según necesidad',
    false,
    50,
    true
);

-- ============================================================================
-- 4. LOTES DE FÁRMACOS (Stock inicial)
-- ============================================================================

-- Lote para Amoxidal
INSERT INTO lotes_farmacos (
    farmaco_id,
    numero_lote,
    fecha_vencimiento,
    cantidad_inicial,
    cantidad_actual,
    precio_compra,
    precio_venta,
    proveedor,
    ubicacion_almacen
) SELECT
    id,
    'AMOX-001',
    '2026-12-31',
    100,
    100,
    0.50,
    1.20,
    'Droguería Sur',
    'A-1'
FROM farmacos WHERE nombre_comercial = 'Amoxidal';

-- Lote para Rimadyl
INSERT INTO lotes_farmacos (
    farmaco_id,
    numero_lote,
    fecha_vencimiento,
    cantidad_inicial,
    cantidad_actual,
    precio_compra,
    precio_venta,
    proveedor,
    ubicacion_almacen
) SELECT
    id,
    'RIM-001',
    '2026-06-30',
    50,
    50,
    1.80,
    3.50,
    'Zoetis ARG',
    'A-2'
FROM farmacos WHERE nombre_comercial = 'Rimadyl';

-- Lote para Advocate
INSERT INTO lotes_farmacos (
    farmaco_id,
    numero_lote,
    fecha_vencimiento,
    cantidad_inicial,
    cantidad_actual,
    precio_compra,
    precio_venta,
    proveedor,
    ubicacion_almacen
) SELECT
    id,
    'ADV-001',
    '2026-09-30',
    100,
    100,
    3.20,
    6.50,
    'Bayer ARG',
    'B-1'
FROM farmacos WHERE nombre_comercial = 'Advocate';

-- Lote para Frontline Plus
INSERT INTO lotes_farmacos (
    farmaco_id,
    numero_lote,
    fecha_vencimiento,
    cantidad_inicial,
    cantidad_actual,
    precio_compra,
    precio_venta,
    proveedor,
    ubicacion_almacen
) SELECT
    id,
    'FRT-001',
    '2026-08-31',
    100,
    100,
    2.80,
    5.50,
    'Boehringer',
    'B-2'
FROM farmacos WHERE nombre_comercial = 'Frontline Plus';

-- Lote para Drontal Plus
INSERT INTO lotes_farmacos (
    farmaco_id,
    numero_lote,
    fecha_vencimiento,
    cantidad_inicial,
    cantidad_actual,
    precio_compra,
    precio_venta,
    proveedor,
    ubicacion_almacen
) SELECT
    id,
    'DRT-001',
    '2026-11-30',
    80,
    80,
    1.50,
    3.00,
    'Bayer ARG',
    'B-3'
FROM farmacos WHERE nombre_comercial = 'Drontal Plus';

-- Lotes adicionales para otros fármacos
INSERT INTO lotes_farmacos (farmaco_id, numero_lote, fecha_vencimiento, cantidad_inicial, cantidad_actual, precio_compra, precio_venta, proveedor, ubicacion_almacen)
SELECT id, 'TRM-001', '2026-10-31', 60, 60, 0.80, 1.80, 'Gador', 'C-1'
FROM farmacos WHERE nombre_comercial = 'Tramadol';

INSERT INTO lotes_farmacos (farmaco_id, numero_lote, fecha_vencimiento, cantidad_inicial, cantidad_actual, precio_compra, precio_venta, proveedor, ubicacion_almacen)
SELECT id, 'MTZ-001', '2026-07-31', 50, 50, 0.40, 1.00, 'Elea', 'C-2'
FROM farmacos WHERE nombre_comercial = 'Metronidazol';

INSERT INTO lotes_farmacos (farmaco_id, numero_lote, fecha_vencimiento, cantidad_inicial, cantidad_actual, precio_compra, precio_venta, proveedor, ubicacion_almacen)
SELECT id, 'PRD-001', '2026-05-31', 40, 40, 0.60, 1.50, 'Fabop', 'C-3'
FROM farmacos WHERE nombre_comercial = 'Prednisolona';

INSERT INTO lotes_farmacos (farmaco_id, numero_lote, fecha_vencimiento, cantidad_inicial, cantidad_actual, precio_compra, precio_venta, proveedor, ubicacion_almacen)
SELECT id, 'MLX-001', '2026-12-31', 50, 50, 0.70, 1.60, 'Over', 'C-4'
FROM farmacos WHERE nombre_comercial = 'Meloxicam';

INSERT INTO lotes_farmacos (farmaco_id, numero_lote, fecha_vencimiento, cantidad_inicial, cantidad_actual, precio_compra, precio_venta, proveedor, ubicacion_almacen)
SELECT id, 'SF-001', '2027-12-31', 200, 200, 0.30, 0.50, 'Baxter', 'D-1'
FROM farmacos WHERE nombre_comercial = 'Suero Fisiológico';

-- ============================================================================
-- NOTAS IMPORTANTES
-- ============================================================================

-- Para crear usuarios demo, necesitas primero registrarlos en Supabase Auth
-- y luego vincularlos con la tabla users.
-- Esto se puede hacer desde la aplicación o manualmente:

-- EJEMPLO DE USUARIOS DEMO (ejecutar DESPUÉS de crear en Supabase Auth):
/*
-- Admin
INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol, activo)
VALUES (
    'UUID-del-usuario-en-auth',
    'admin@rambopet.com',
    'Dr. Admin RamboPet',
    '+591 2 123-4567',
    'admin',
    true
);

-- Médico Veterinario
INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol, activo)
VALUES (
    'UUID-del-usuario-en-auth',
    'dra.martinez@rambopet.com',
    'Dra. María Martínez',
    '+591 2 234-5678',
    'medico',
    true
);

-- Crear perfil de profesional para el médico
INSERT INTO profesionales (user_id, matricula_profesional, especialidades, biografia, anios_experiencia, activo)
SELECT
    id,
    'MV-12345',
    ARRAY['Clínica General', 'Cirugía'],
    'Veterinaria con 10 años de experiencia',
    10,
    true
FROM users WHERE email = 'dra.martinez@rambopet.com';

-- Recepcionista
INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol, activo)
VALUES (
    'UUID-del-usuario-en-auth',
    'recepcion@rambopet.com',
    'Carla Fernández',
    '+591 2 345-6789',
    'recepcion',
    true
);

-- Tutor de ejemplo
INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol, activo)
VALUES (
    'UUID-del-usuario-en-auth',
    'tutor@example.com',
    'Juan Pérez',
    '+591 2 456-7890',
    'tutor',
    true
);

-- Crear perfil de tutor
INSERT INTO tutores (user_id, dni, direccion, ciudad, provincia, contacto_emergencia, telefono_emergencia)
SELECT
    id,
    '35123456',
    'Av. Principal 1234',
    'La Paz',
    'La Paz',
    'María Pérez',
    '+591 2 567-8901'
FROM users WHERE email = 'tutor@example.com';
*/

-- ============================================================================
-- FIN DE SEEDS
-- ============================================================================

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Seeds cargados correctamente';
    RAISE NOTICE 'Servicios: %', (SELECT COUNT(*) FROM servicios);
    RAISE NOTICE 'Consultorios: %', (SELECT COUNT(*) FROM consultorios);
    RAISE NOTICE 'Fármacos: %', (SELECT COUNT(*) FROM farmacos);
    RAISE NOTICE 'Lotes: %', (SELECT COUNT(*) FROM lotes_farmacos);
END $$;