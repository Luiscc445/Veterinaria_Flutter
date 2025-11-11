-- ============================================================================
-- FUNCIONES SQL COMPLETAS PARA TODO EL SISTEMA RAMBOPET
-- Estas funciones se ejecutan con SECURITY DEFINER para evitar problemas de RLS
-- ============================================================================

-- Eliminar funciones antiguas si existen
DROP FUNCTION IF EXISTS get_current_tutor_id();
DROP FUNCTION IF EXISTS get_current_user_data();
DROP FUNCTION IF EXISTS get_current_profesional_id();
DROP FUNCTION IF EXISTS get_my_mascotas();
DROP FUNCTION IF EXISTS get_my_citas();
DROP FUNCTION IF EXISTS create_mascota CASCADE;
DROP FUNCTION IF EXISTS update_mascota CASCADE;
DROP FUNCTION IF EXISTS delete_mascota CASCADE;
DROP FUNCTION IF EXISTS create_cita CASCADE;
DROP FUNCTION IF EXISTS update_cita_estado CASCADE;
DROP FUNCTION IF EXISTS cancel_cita CASCADE;
DROP FUNCTION IF EXISTS get_all_servicios();
DROP FUNCTION IF EXISTS get_all_profesionales();
DROP FUNCTION IF EXISTS get_all_consultorios();
DROP FUNCTION IF EXISTS get_historia_clinica_by_mascota CASCADE;
DROP FUNCTION IF EXISTS get_episodios_by_historia CASCADE;
DROP FUNCTION IF EXISTS create_episodio CASCADE;
DROP FUNCTION IF EXISTS get_all_farmacos();
DROP FUNCTION IF EXISTS get_lotes_by_farmaco CASCADE;

-- ============================================================================
-- FUNCIONES AUXILIARES
-- ============================================================================

-- Obtener tutor_id del usuario actual
CREATE OR REPLACE FUNCTION get_current_tutor_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
    v_user_id UUID;
    v_tutor_id UUID;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    SELECT id INTO v_user_id
    FROM users
    WHERE auth_user_id = auth.uid()
    LIMIT 1;

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    SELECT id INTO v_tutor_id
    FROM tutores
    WHERE user_id = v_user_id
    LIMIT 1;

    RETURN v_tutor_id; -- Puede ser NULL si no es tutor
END;
$$;

-- Obtener profesional_id del usuario actual
CREATE OR REPLACE FUNCTION get_current_profesional_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
    v_user_id UUID;
    v_profesional_id UUID;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    SELECT id INTO v_user_id
    FROM users
    WHERE auth_user_id = auth.uid()
    LIMIT 1;

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    SELECT id INTO v_profesional_id
    FROM profesionales
    WHERE user_id = v_user_id
    LIMIT 1;

    RETURN v_profesional_id; -- Puede ser NULL si no es profesional
END;
$$;

-- Obtener datos completos del usuario actual
CREATE OR REPLACE FUNCTION get_current_user_data()
RETURNS TABLE (
    user_id UUID,
    auth_user_id UUID,
    email TEXT,
    nombre_completo TEXT,
    telefono TEXT,
    rol TEXT,
    tutor_id UUID,
    profesional_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        u.auth_user_id,
        u.email,
        u.nombre_completo,
        u.telefono,
        u.rol::text,
        t.id as tutor_id,
        p.id as profesional_id
    FROM users u
    LEFT JOIN tutores t ON t.user_id = u.id
    LEFT JOIN profesionales p ON p.user_id = u.id
    WHERE u.auth_user_id = auth.uid();
END;
$$;

-- ============================================================================
-- FUNCIONES PARA MASCOTAS
-- ============================================================================

-- Obtener mis mascotas (tutores)
CREATE OR REPLACE FUNCTION get_my_mascotas()
RETURNS TABLE (
    id UUID,
    tutor_id UUID,
    nombre TEXT,
    especie TEXT,
    raza TEXT,
    sexo TEXT,
    fecha_nacimiento DATE,
    peso_kg NUMERIC,
    color TEXT,
    senias_particulares TEXT,
    microchip TEXT,
    foto_url TEXT,
    estado TEXT,
    alergias TEXT,
    condiciones_preexistentes TEXT,
    esterilizado BOOLEAN,
    activo BOOLEAN,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
    v_tutor_id UUID;
BEGIN
    v_tutor_id := get_current_tutor_id();
    IF v_tutor_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no es tutor';
    END IF;

    RETURN QUERY
    SELECT
        m.id,
        m.tutor_id,
        m.nombre,
        m.especie,
        m.raza,
        m.sexo,
        m.fecha_nacimiento,
        m.peso_kg,
        m.color,
        m.senias_particulares,
        m.microchip,
        m.foto_url,
        m.estado::text,
        m.alergias,
        m.condiciones_preexistentes,
        m.esterilizado,
        m.activo,
        m.created_at
    FROM mascotas m
    WHERE m.tutor_id = v_tutor_id
      AND m.deleted_at IS NULL
    ORDER BY m.created_at DESC;
END;
$$;

-- Crear mascota
CREATE OR REPLACE FUNCTION create_mascota(
    p_nombre TEXT,
    p_especie TEXT,
    p_raza TEXT DEFAULT NULL,
    p_sexo TEXT DEFAULT NULL,
    p_fecha_nacimiento DATE DEFAULT NULL,
    p_peso_kg NUMERIC DEFAULT NULL,
    p_color TEXT DEFAULT NULL,
    p_senias_particulares TEXT DEFAULT NULL,
    p_microchip TEXT DEFAULT NULL,
    p_foto_url TEXT DEFAULT NULL,
    p_alergias TEXT DEFAULT NULL,
    p_condiciones_preexistentes TEXT DEFAULT NULL,
    p_esterilizado BOOLEAN DEFAULT FALSE
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tutor_id UUID;
    v_mascota_id UUID;
BEGIN
    v_tutor_id := get_current_tutor_id();
    IF v_tutor_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no es tutor';
    END IF;

    INSERT INTO mascotas (
        tutor_id, nombre, especie, raza, sexo, fecha_nacimiento,
        peso_kg, color, senias_particulares, microchip, foto_url,
        estado, alergias, condiciones_preexistentes, esterilizado, activo
    ) VALUES (
        v_tutor_id, p_nombre, p_especie, p_raza, p_sexo, p_fecha_nacimiento,
        p_peso_kg, p_color, p_senias_particulares, p_microchip, p_foto_url,
        'pendiente', p_alergias, p_condiciones_preexistentes, p_esterilizado, TRUE
    )
    RETURNING id INTO v_mascota_id;

    RETURN v_mascota_id;
END;
$$;

-- Actualizar mascota
CREATE OR REPLACE FUNCTION update_mascota(
    p_mascota_id UUID,
    p_nombre TEXT DEFAULT NULL,
    p_raza TEXT DEFAULT NULL,
    p_peso_kg NUMERIC DEFAULT NULL,
    p_alergias TEXT DEFAULT NULL,
    p_condiciones_preexistentes TEXT DEFAULT NULL,
    p_foto_url TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tutor_id UUID;
BEGIN
    v_tutor_id := get_current_tutor_id();
    IF v_tutor_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no es tutor';
    END IF;

    -- Verificar que la mascota pertenece al tutor
    IF NOT EXISTS (
        SELECT 1 FROM mascotas
        WHERE id = p_mascota_id AND tutor_id = v_tutor_id
    ) THEN
        RAISE EXCEPTION 'Mascota no encontrada o no pertenece al tutor';
    END IF;

    UPDATE mascotas
    SET
        nombre = COALESCE(p_nombre, nombre),
        raza = COALESCE(p_raza, raza),
        peso_kg = COALESCE(p_peso_kg, peso_kg),
        alergias = COALESCE(p_alergias, alergias),
        condiciones_preexistentes = COALESCE(p_condiciones_preexistentes, condiciones_preexistentes),
        foto_url = COALESCE(p_foto_url, foto_url),
        updated_at = NOW()
    WHERE id = p_mascota_id;

    RETURN TRUE;
END;
$$;

-- Eliminar mascota (soft delete)
CREATE OR REPLACE FUNCTION delete_mascota(p_mascota_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tutor_id UUID;
BEGIN
    v_tutor_id := get_current_tutor_id();
    IF v_tutor_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no es tutor';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM mascotas
        WHERE id = p_mascota_id AND tutor_id = v_tutor_id
    ) THEN
        RAISE EXCEPTION 'Mascota no encontrada';
    END IF;

    UPDATE mascotas
    SET deleted_at = NOW()
    WHERE id = p_mascota_id;

    RETURN TRUE;
END;
$$;

-- ============================================================================
-- FUNCIONES PARA CITAS
-- ============================================================================

-- Obtener mis citas
CREATE OR REPLACE FUNCTION get_my_citas()
RETURNS TABLE (
    id UUID,
    mascota_id UUID,
    tutor_id UUID,
    servicio_id UUID,
    profesional_id UUID,
    consultorio_id UUID,
    fecha_hora TIMESTAMPTZ,
    fecha_hora_fin TIMESTAMPTZ,
    estado TEXT,
    motivo_consulta TEXT,
    observaciones TEXT,
    created_at TIMESTAMPTZ,
    mascota_nombre TEXT,
    mascota_especie TEXT,
    servicio_nombre TEXT,
    profesional_nombre TEXT,
    consultorio_nombre TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
    v_tutor_id UUID;
BEGIN
    v_tutor_id := get_current_tutor_id();
    IF v_tutor_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no es tutor';
    END IF;

    RETURN QUERY
    SELECT
        c.id,
        c.mascota_id,
        c.tutor_id,
        c.servicio_id,
        c.profesional_id,
        c.consultorio_id,
        c.fecha_hora,
        c.fecha_hora_fin,
        c.estado::text,
        c.motivo_consulta,
        c.observaciones,
        c.created_at,
        m.nombre as mascota_nombre,
        m.especie as mascota_especie,
        s.nombre as servicio_nombre,
        u.nombre_completo as profesional_nombre,
        co.nombre as consultorio_nombre
    FROM citas c
    INNER JOIN mascotas m ON c.mascota_id = m.id
    INNER JOIN servicios s ON c.servicio_id = s.id
    INNER JOIN profesionales p ON c.profesional_id = p.id
    INNER JOIN users u ON p.user_id = u.id
    LEFT JOIN consultorios co ON c.consultorio_id = co.id
    WHERE c.tutor_id = v_tutor_id
      AND c.deleted_at IS NULL
    ORDER BY c.fecha_hora DESC;
END;
$$;

-- Crear cita
CREATE OR REPLACE FUNCTION create_cita(
    p_mascota_id UUID,
    p_servicio_id UUID,
    p_profesional_id UUID,
    p_fecha_hora TIMESTAMPTZ,
    p_motivo_consulta TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tutor_id UUID;
    v_cita_id UUID;
    v_duracion INTEGER;
    v_fecha_hora_fin TIMESTAMPTZ;
BEGIN
    v_tutor_id := get_current_tutor_id();
    IF v_tutor_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no es tutor';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM mascotas
        WHERE id = p_mascota_id AND tutor_id = v_tutor_id
    ) THEN
        RAISE EXCEPTION 'Mascota no pertenece al tutor';
    END IF;

    SELECT duracion_minutos INTO v_duracion
    FROM servicios
    WHERE id = p_servicio_id;

    v_fecha_hora_fin := p_fecha_hora + (v_duracion || ' minutes')::INTERVAL;

    INSERT INTO citas (
        mascota_id, tutor_id, servicio_id, profesional_id,
        fecha_hora, fecha_hora_fin, estado, motivo_consulta
    ) VALUES (
        p_mascota_id, v_tutor_id, p_servicio_id, p_profesional_id,
        p_fecha_hora, v_fecha_hora_fin, 'reservada', p_motivo_consulta
    )
    RETURNING id INTO v_cita_id;

    RETURN v_cita_id;
END;
$$;

-- Actualizar estado de cita
CREATE OR REPLACE FUNCTION update_cita_estado(
    p_cita_id UUID,
    p_estado TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tutor_id UUID;
BEGIN
    v_tutor_id := get_current_tutor_id();

    IF NOT EXISTS (
        SELECT 1 FROM citas
        WHERE id = p_cita_id AND tutor_id = v_tutor_id
    ) THEN
        RAISE EXCEPTION 'Cita no encontrada';
    END IF;

    UPDATE citas
    SET estado = p_estado::estado_cita, updated_at = NOW()
    WHERE id = p_cita_id;

    RETURN TRUE;
END;
$$;

-- Cancelar cita
CREATE OR REPLACE FUNCTION cancel_cita(
    p_cita_id UUID,
    p_motivo_cancelacion TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tutor_id UUID;
BEGIN
    v_tutor_id := get_current_tutor_id();

    IF NOT EXISTS (
        SELECT 1 FROM citas
        WHERE id = p_cita_id AND tutor_id = v_tutor_id
    ) THEN
        RAISE EXCEPTION 'Cita no encontrada';
    END IF;

    UPDATE citas
    SET
        estado = 'cancelada',
        motivo_cancelacion = p_motivo_cancelacion,
        updated_at = NOW()
    WHERE id = p_cita_id;

    RETURN TRUE;
END;
$$;

-- ============================================================================
-- FUNCIONES PARA SERVICIOS
-- ============================================================================

-- Obtener todos los servicios activos
CREATE OR REPLACE FUNCTION get_all_servicios()
RETURNS TABLE (
    id UUID,
    nombre TEXT,
    tipo TEXT,
    descripcion TEXT,
    duracion_minutos INTEGER,
    precio_base NUMERIC,
    requiere_especializacion BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id,
        s.nombre,
        s.tipo::text,
        s.descripcion,
        s.duracion_minutos,
        s.precio_base,
        s.requiere_especializacion
    FROM servicios s
    WHERE s.activo = TRUE
      AND s.deleted_at IS NULL
    ORDER BY s.nombre;
END;
$$;

-- ============================================================================
-- FUNCIONES PARA PROFESIONALES
-- ============================================================================

-- Obtener todos los profesionales activos
CREATE OR REPLACE FUNCTION get_all_profesionales()
RETURNS TABLE (
    id UUID,
    user_id UUID,
    nombre_completo TEXT,
    email TEXT,
    telefono TEXT,
    avatar_url TEXT,
    matricula_profesional TEXT,
    especialidades TEXT[],
    biografia TEXT,
    anios_experiencia INTEGER,
    horario_atencion JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.user_id,
        u.nombre_completo,
        u.email,
        u.telefono,
        u.avatar_url,
        p.matricula_profesional,
        p.especialidades,
        p.biografia,
        p.anios_experiencia,
        p.horario_atencion
    FROM profesionales p
    INNER JOIN users u ON p.user_id = u.id
    WHERE p.activo = TRUE
      AND p.deleted_at IS NULL
    ORDER BY u.nombre_completo;
END;
$$;

-- ============================================================================
-- FUNCIONES PARA CONSULTORIOS
-- ============================================================================

-- Obtener todos los consultorios activos
CREATE OR REPLACE FUNCTION get_all_consultorios()
RETURNS TABLE (
    id UUID,
    nombre TEXT,
    numero TEXT,
    piso TEXT,
    equipamiento TEXT[],
    capacidad INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.nombre,
        c.numero,
        c.piso,
        c.equipamiento,
        c.capacidad
    FROM consultorios c
    WHERE c.activo = TRUE
      AND c.deleted_at IS NULL
    ORDER BY c.numero;
END;
$$;

-- ============================================================================
-- FUNCIONES PARA HISTORIAS CLÍNICAS
-- ============================================================================

-- Obtener historia clínica por mascota
CREATE OR REPLACE FUNCTION get_historia_clinica_by_mascota(p_mascota_id UUID)
RETURNS TABLE (
    id UUID,
    mascota_id UUID,
    numero_historia TEXT,
    fecha_apertura TIMESTAMPTZ,
    observaciones_generales TEXT,
    mascota_nombre TEXT,
    mascota_especie TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
    v_tutor_id UUID;
BEGIN
    v_tutor_id := get_current_tutor_id();

    -- Verificar que la mascota pertenece al tutor
    IF v_tutor_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM mascotas
            WHERE id = p_mascota_id AND tutor_id = v_tutor_id
        ) THEN
            RAISE EXCEPTION 'Mascota no pertenece al tutor';
        END IF;
    END IF;

    RETURN QUERY
    SELECT
        h.id,
        h.mascota_id,
        h.numero_historia,
        h.fecha_apertura,
        h.observaciones_generales,
        m.nombre as mascota_nombre,
        m.especie as mascota_especie
    FROM historias_clinicas h
    INNER JOIN mascotas m ON h.mascota_id = m.id
    WHERE h.mascota_id = p_mascota_id
      AND h.deleted_at IS NULL;
END;
$$;

-- ============================================================================
-- FUNCIONES PARA EPISODIOS
-- ============================================================================

-- Obtener episodios por historia clínica
CREATE OR REPLACE FUNCTION get_episodios_by_historia(p_historia_id UUID)
RETURNS TABLE (
    id UUID,
    historia_clinica_id UUID,
    cita_id UUID,
    profesional_id UUID,
    fecha_episodio TIMESTAMPTZ,
    tipo_episodio TEXT,
    motivo_consulta TEXT,
    anamnesis TEXT,
    examen_fisico TEXT,
    temperatura_celsius NUMERIC,
    frecuencia_cardiaca INTEGER,
    frecuencia_respiratoria INTEGER,
    peso_kg NUMERIC,
    diagnostico TEXT,
    plan_tratamiento TEXT,
    indicaciones_tutor TEXT,
    proxima_visita DATE,
    observaciones TEXT,
    profesional_nombre TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.historia_clinica_id,
        e.cita_id,
        e.profesional_id,
        e.fecha_episodio,
        e.tipo_episodio::text,
        e.motivo_consulta,
        e.anamnesis,
        e.examen_fisico,
        e.temperatura_celsius,
        e.frecuencia_cardiaca,
        e.frecuencia_respiratoria,
        e.peso_kg,
        e.diagnostico,
        e.plan_tratamiento,
        e.indicaciones_tutor,
        e.proxima_visita,
        e.observaciones,
        u.nombre_completo as profesional_nombre
    FROM episodios e
    INNER JOIN profesionales p ON e.profesional_id = p.id
    INNER JOIN users u ON p.user_id = u.id
    WHERE e.historia_clinica_id = p_historia_id
      AND e.deleted_at IS NULL
    ORDER BY e.fecha_episodio DESC;
END;
$$;

-- Crear episodio (solo profesionales)
CREATE OR REPLACE FUNCTION create_episodio(
    p_historia_clinica_id UUID,
    p_cita_id UUID,
    p_tipo_episodio TEXT,
    p_motivo_consulta TEXT,
    p_anamnesis TEXT DEFAULT NULL,
    p_examen_fisico TEXT DEFAULT NULL,
    p_temperatura_celsius NUMERIC DEFAULT NULL,
    p_frecuencia_cardiaca INTEGER DEFAULT NULL,
    p_frecuencia_respiratoria INTEGER DEFAULT NULL,
    p_peso_kg NUMERIC DEFAULT NULL,
    p_diagnostico TEXT DEFAULT NULL,
    p_plan_tratamiento TEXT DEFAULT NULL,
    p_indicaciones_tutor TEXT DEFAULT NULL,
    p_proxima_visita DATE DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profesional_id UUID;
    v_episodio_id UUID;
BEGIN
    v_profesional_id := get_current_profesional_id();
    IF v_profesional_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no es profesional';
    END IF;

    INSERT INTO episodios (
        historia_clinica_id, cita_id, profesional_id,
        fecha_episodio, tipo_episodio, motivo_consulta,
        anamnesis, examen_fisico, temperatura_celsius,
        frecuencia_cardiaca, frecuencia_respiratoria, peso_kg,
        diagnostico, plan_tratamiento, indicaciones_tutor,
        proxima_visita, observaciones
    ) VALUES (
        p_historia_clinica_id, p_cita_id, v_profesional_id,
        NOW(), p_tipo_episodio::tipo_servicio, p_motivo_consulta,
        p_anamnesis, p_examen_fisico, p_temperatura_celsius,
        p_frecuencia_cardiaca, p_frecuencia_respiratoria, p_peso_kg,
        p_diagnostico, p_plan_tratamiento, p_indicaciones_tutor,
        p_proxima_visita, p_observaciones
    )
    RETURNING id INTO v_episodio_id;

    RETURN v_episodio_id;
END;
$$;

-- ============================================================================
-- FUNCIONES PARA FÁRMACOS
-- ============================================================================

-- Obtener todos los fármacos
CREATE OR REPLACE FUNCTION get_all_farmacos()
RETURNS TABLE (
    id UUID,
    nombre_comercial TEXT,
    nombre_generico TEXT,
    laboratorio TEXT,
    principio_activo TEXT,
    concentracion TEXT,
    forma_farmaceutica TEXT,
    unidad_medida TEXT,
    via_administracion TEXT[],
    indicaciones TEXT,
    stock_total INTEGER,
    stock_minimo INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id,
        f.nombre_comercial,
        f.nombre_generico,
        f.laboratorio,
        f.principio_activo,
        f.concentracion,
        f.forma_farmaceutica,
        f.unidad_medida,
        f.via_administracion,
        f.indicaciones,
        COALESCE(SUM(l.cantidad_actual)::INTEGER, 0) as stock_total,
        f.stock_minimo
    FROM farmacos f
    LEFT JOIN lotes_farmacos l ON f.id = l.farmaco_id
        AND l.activo = TRUE
        AND l.deleted_at IS NULL
        AND l.fecha_vencimiento > CURRENT_DATE
    WHERE f.activo = TRUE
      AND f.deleted_at IS NULL
    GROUP BY f.id
    ORDER BY f.nombre_comercial;
END;
$$;

-- Obtener lotes por fármaco
CREATE OR REPLACE FUNCTION get_lotes_by_farmaco(p_farmaco_id UUID)
RETURNS TABLE (
    id UUID,
    farmaco_id UUID,
    numero_lote TEXT,
    fecha_vencimiento DATE,
    cantidad_inicial INTEGER,
    cantidad_actual INTEGER,
    precio_compra NUMERIC,
    precio_venta NUMERIC,
    proveedor TEXT,
    fecha_ingreso DATE,
    ubicacion_almacen TEXT,
    dias_para_vencer INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id,
        l.farmaco_id,
        l.numero_lote,
        l.fecha_vencimiento,
        l.cantidad_inicial,
        l.cantidad_actual,
        l.precio_compra,
        l.precio_venta,
        l.proveedor,
        l.fecha_ingreso,
        l.ubicacion_almacen,
        (l.fecha_vencimiento - CURRENT_DATE)::INTEGER as dias_para_vencer
    FROM lotes_farmacos l
    WHERE l.farmaco_id = p_farmaco_id
      AND l.activo = TRUE
      AND l.deleted_at IS NULL
      AND l.cantidad_actual > 0
    ORDER BY l.fecha_vencimiento ASC;
END;
$$;

-- ============================================================================
-- OTORGAR PERMISOS DE EJECUCIÓN
-- ============================================================================

GRANT EXECUTE ON FUNCTION get_current_tutor_id() TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_profesional_id() TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_user_data() TO authenticated;

-- Mascotas
GRANT EXECUTE ON FUNCTION get_my_mascotas() TO authenticated;
GRANT EXECUTE ON FUNCTION create_mascota TO authenticated;
GRANT EXECUTE ON FUNCTION update_mascota TO authenticated;
GRANT EXECUTE ON FUNCTION delete_mascota TO authenticated;

-- Citas
GRANT EXECUTE ON FUNCTION get_my_citas() TO authenticated;
GRANT EXECUTE ON FUNCTION create_cita TO authenticated;
GRANT EXECUTE ON FUNCTION update_cita_estado TO authenticated;
GRANT EXECUTE ON FUNCTION cancel_cita TO authenticated;

-- Servicios, Profesionales, Consultorios
GRANT EXECUTE ON FUNCTION get_all_servicios() TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_profesionales() TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_consultorios() TO authenticated;

-- Historias y Episodios
GRANT EXECUTE ON FUNCTION get_historia_clinica_by_mascota TO authenticated;
GRANT EXECUTE ON FUNCTION get_episodios_by_historia TO authenticated;
GRANT EXECUTE ON FUNCTION create_episodio TO authenticated;

-- Fármacos
GRANT EXECUTE ON FUNCTION get_all_farmacos() TO authenticated;
GRANT EXECUTE ON FUNCTION get_lotes_by_farmaco TO authenticated;

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

SELECT 'Funciones SQL completas creadas exitosamente' AS status;
