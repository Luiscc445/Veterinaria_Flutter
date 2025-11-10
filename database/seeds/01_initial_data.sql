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
('Análisis de Sangre Básico', 'laboratorio', 'Hemograma y química sanguínea básica', 30, 35.00, true),
('Análisis de Orina', 'laboratorio', 'Urianálisis completo', 20, 20.00, true),
('Rayos X', 'laboratorio', 'Estudio radiográfico', 30, 40.00, true),
('Ecografía', 'laboratorio', 'Estudio ecográfico', 30, 50.00, true),
('Hospitalización - Día', 'hospitalizacion', 'Internación veterinaria por día', 1440, 60.00, true);

-- ============================================================================
-- 2. CONSULTORIOS
-- ============================================================================

INSERT INTO consultorios (nombre, numero, piso, equipamiento, capacidad, activo) VALUES
('Consultorio 1', '101', 'Planta Baja', ARRAY['Camilla', 'Estetoscopio', 'Termómetro', 'Balanza'], 1, true),
('Consultorio 2', '102', 'Planta Baja', ARRAY['Camilla', 'Estetoscopio', 'Termómetro', 'Balanza', 'Otoscopio'], 1, true),
('Quirófano', '201', 'Primer Piso', ARRAY['Mesa quirúrgica', 'Anestesia', 'Monitor signos vitales', 'Instrumental quirúrgico'], 2, true),
('Sala de Emergencias', '103', 'Planta Baja', ARRAY['Camilla', 'Desfibrilador', 'Oxígeno', 'Monitor'], 2, true),
('Sala de Peluquería', '104', 'Planta Baja', ARRAY['Bañera', 'Mesa de grooming', 'Secador', 'Herramientas de corte'], 1, true);

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
    'Laboratorios Richmond',
    'Amoxicilina',
    '500 mg',
    'Comprimido',
    'comprimido',
    ARRAY['oral'],
    'Infecciones bacterianas de vías respiratorias, piel, tejidos blandos y urinarias',
    'Hipersensibilidad a penicilinas',
    '10-20 mg/kg cada 12 horas',
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
    'comprimido',
    ARRAY['oral'],
    'Antiinflamatorio no esteroideo para dolor y inflamación',
    'Insuficiencia renal o hepática',
    '2-4 mg/kg cada 24 horas',
    true,
    15,
    true
),
(
    'Advocate',
    'Imidacloprid + Moxidectina',
    'Bayer',
    'Imidacloprid 10% + Moxidectina 2.5%',
    '0.4 ml',
    'Pipeta',
    'ml',
    ARRAY['topica'],
    'Prevención y tratamiento de pulgas, prevención de dirofilariasis',
    'Cachorros menores de 7 semanas',
    'Según peso del animal',
    false,
    30,
    true
),
(
    'Frontline Plus',
    'Fipronil + Methoprene',
    'Boehringer Ingelheim',
    'Fipronil 9.8% + (S)-methoprene 8.8%',
    '0.67 ml',
    'Pipeta',
    'ml',
    ARRAY['topica'],
    'Control de pulgas, garrapatas y piojos',
    'Cachorros menores de 8 semanas',
    'Según peso del animal',
    false,
    30,
    true
),
(
    'Drontal Plus',
    'Praziquantel + Pirantel + Febantel',
    'Bayer',
    'Praziquantel 50mg + Pirantel 144mg + Febantel 150mg',
    '1 comprimido',
    'Comprimido',
    'comprimido',
    ARRAY['oral'],
    'Tratamiento de cestodos y nematodos intestinales',
    'Cachorros menores de 2 semanas',
    '1 comprimido por 10 kg de peso',
    false,
    25,
    true
),
(
    'Tramadol',
    'Tramadol',
    'Gador',
    'Clorhidrato de Tramadol',
    '50 mg',
    'Comprimido',
    'comprimido',
    ARRAY['oral'],
    'Analgésico para dolor moderado a severo',
    'Epilepsia no controlada',
    '2-4 mg/kg cada 8-12 horas',
    true,
    20,
    true
),
(
    'Metronidazol',
    'Metronidazol',
    'Laboratorio Elea',
    'Metronidazol',
    '250 mg',
    'Comprimido',
    'comprimido',
    ARRAY['oral'],
    'Infecciones por protozoarios y bacterias anaerobias',
    'Hipersensibilidad al metronidazol',
    '15-25 mg/kg cada 12 horas',
    true,
    15,
    true
),
(
    'Prednisolona',
    'Prednisolona',
    'Laboratorio Fabop',
    'Prednisolona',
    '20 mg',
    'Comprimido',
    'comprimido',
    ARRAY['oral'],
    'Antiinflamatorio corticoide, alergias, enfermedades autoinmunes',
    'Infecciones fúngicas sistémicas',
    '0.5-2 mg/kg cada 12-24 horas',
    true,
    10,
    true
),
(
    'Meloxicam',
    'Meloxicam',
    'Laboratorio Over',
    'Meloxicam',
    '15 mg',
    'Comprimido',
    'comprimido',
    ARRAY['oral'],
    'Antiinflamatorio no esteroideo, dolor crónico',
    'Insuficiencia renal o hepática severa',
    '0.1 mg/kg cada 24 horas',
    true,
    15,
    true
),
(
    'Suero Fisiológico',
    'Cloruro de Sodio 0.9%',
    'Baxter',
    'Cloruro de Sodio',
    '0.9%',
    'Solución inyectable',
    'ml',
    ARRAY['intravenosa', 'subcutánea'],
    'Rehidratación, vehículo para medicamentos',
    'Ninguna conocida',
    'Según necesidad del paciente',
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
    'AMOX-2025-001',
    '2026-12-31',
    100,
    100,
    0.50,
    1.20,
    'Droguería del Sud',
    'Estante A-1'
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
    'RIM-2025-001',
    '2026-06-30',
    50,
    50,
    1.80,
    3.50,
    'Zoetis Argentina',
    'Estante A-2'
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
    'ADV-2025-001',
    '2026-09-30',
    100,
    100,
    3.20,
    6.50,
    'Bayer Argentina',
    'Estante B-1'
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
    'FRT-2025-001',
    '2026-08-31',
    100,
    100,
    2.80,
    5.50,
    'Boehringer Ingelheim',
    'Estante B-2'
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
    'DRT-2025-001',
    '2026-11-30',
    80,
    80,
    1.50,
    3.00,
    'Bayer Argentina',
    'Estante B-3'
FROM farmacos WHERE nombre_comercial = 'Drontal Plus';

-- Lotes adicionales para otros fármacos
INSERT INTO lotes_farmacos (farmaco_id, numero_lote, fecha_vencimiento, cantidad_inicial, cantidad_actual, precio_compra, precio_venta, proveedor, ubicacion_almacen)
SELECT id, 'TRM-2025-001', '2026-10-31', 60, 60, 0.80, 1.80, 'Gador', 'Estante C-1'
FROM farmacos WHERE nombre_comercial = 'Tramadol';

INSERT INTO lotes_farmacos (farmaco_id, numero_lote, fecha_vencimiento, cantidad_inicial, cantidad_actual, precio_compra, precio_venta, proveedor, ubicacion_almacen)
SELECT id, 'MTZ-2025-001', '2026-07-31', 50, 50, 0.40, 1.00, 'Elea', 'Estante C-2'
FROM farmacos WHERE nombre_comercial = 'Metronidazol';

INSERT INTO lotes_farmacos (farmaco_id, numero_lote, fecha_vencimiento, cantidad_inicial, cantidad_actual, precio_compra, precio_venta, proveedor, ubicacion_almacen)
SELECT id, 'PRD-2025-001', '2026-05-31', 40, 40, 0.60, 1.50, 'Fabop', 'Estante C-3'
FROM farmacos WHERE nombre_comercial = 'Prednisolona';

INSERT INTO lotes_farmacos (farmaco_id, numero_lote, fecha_vencimiento, cantidad_inicial, cantidad_actual, precio_compra, precio_venta, proveedor, ubicacion_almacen)
SELECT id, 'MLX-2025-001', '2026-12-31', 50, 50, 0.70, 1.60, 'Over', 'Estante C-4'
FROM farmacos WHERE nombre_comercial = 'Meloxicam';

INSERT INTO lotes_farmacos (farmaco_id, numero_lote, fecha_vencimiento, cantidad_inicial, cantidad_actual, precio_compra, precio_venta, proveedor, ubicacion_almacen)
SELECT id, 'SF-2025-001', '2027-12-31', 200, 200, 0.30, 0.50, 'Baxter', 'Estante D-1'
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
    'Dr. Administrador RamboPet',
    '+54 9 11 1234-5678',
    'admin',
    true
);

-- Médico Veterinario
INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol, activo)
VALUES (
    'UUID-del-usuario-en-auth',
    'dra.martinez@rambopet.com',
    'Dra. María Martínez',
    '+54 9 11 2345-6789',
    'medico',
    true
);

-- Crear perfil de profesional para el médico
INSERT INTO profesionales (user_id, matricula_profesional, especialidades, biografia, anios_experiencia, activo)
SELECT
    id,
    'MV-12345',
    ARRAY['Clínica General', 'Cirugía'],
    'Veterinaria con 10 años de experiencia en clínica de pequeños animales',
    10,
    true
FROM users WHERE email = 'dra.martinez@rambopet.com';

-- Recepcionista
INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol, activo)
VALUES (
    'UUID-del-usuario-en-auth',
    'recepcion@rambopet.com',
    'Carla Fernández',
    '+54 9 11 3456-7890',
    'recepcion',
    true
);

-- Tutor de ejemplo
INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol, activo)
VALUES (
    'UUID-del-usuario-en-auth',
    'tutor@example.com',
    'Juan Pérez',
    '+54 9 11 4567-8901',
    'tutor',
    true
);

-- Crear perfil de tutor
INSERT INTO tutores (user_id, dni, direccion, ciudad, provincia, contacto_emergencia, telefono_emergencia)
SELECT
    id,
    '35123456',
    'Av. Rivadavia 1234',
    'Buenos Aires',
    'CABA',
    'María Pérez (Esposa)',
    '+54 9 11 5678-9012'
FROM users WHERE email = 'tutor@example.com';
*/

-- ============================================================================
-- FIN DE SEEDS
-- ============================================================================

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Seeds de datos iniciales cargados correctamente';
    RAISE NOTICE 'Servicios: %', (SELECT COUNT(*) FROM servicios);
    RAISE NOTICE 'Consultorios: %', (SELECT COUNT(*) FROM consultorios);
    RAISE NOTICE 'Fármacos: %', (SELECT COUNT(*) FROM farmacos);
    RAISE NOTICE 'Lotes de fármacos: %', (SELECT COUNT(*) FROM lotes_farmacos);
END $$;
