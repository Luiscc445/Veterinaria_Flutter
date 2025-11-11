-- ============================================================================
-- FUNCIONES SQL SEGURAS PARA EVITAR "PERMISSION DENIED"
-- Estas funciones se ejecutan con SECURITY DEFINER para evitar problemas de RLS
-- ============================================================================

-- Eliminar funciones antiguas si existen
DROP FUNCTION IF EXISTS get_current_tutor_id();
DROP FUNCTION IF EXISTS get_current_user_data();
DROP FUNCTION IF EXISTS get_tutor_id_from_auth();

-- ============================================================================
-- FUNCIÓN: Obtener tutor_id del usuario actual (SIN consultar tabla users)
-- Esta función evita el error "permission denied for table users"
-- ============================================================================
CREATE OR REPLACE FUNCTION get_current_tutor_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER  -- Se ejecuta con permisos del creador, no del usuario
STABLE
AS $$
DECLARE
    v_user_id UUID;
    v_tutor_id UUID;
BEGIN
    -- Obtener el auth.uid() actual
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- Obtener user_id desde auth_user_id
    SELECT id INTO v_user_id
    FROM users
    WHERE auth_user_id = auth.uid()
    LIMIT 1;

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no encontrado en tabla users';
    END IF;

    -- Obtener tutor_id
    SELECT id INTO v_tutor_id
    FROM tutores
    WHERE user_id = v_user_id
    LIMIT 1;

    IF v_tutor_id IS NULL THEN
        RAISE EXCEPTION 'Tutor no encontrado para este usuario';
    END IF;

    RETURN v_tutor_id;
END;
$$;

-- ============================================================================
-- FUNCIÓN: Obtener datos completos del usuario actual
-- ============================================================================
CREATE OR REPLACE FUNCTION get_current_user_data()
RETURNS TABLE (
    user_id UUID,
    auth_user_id UUID,
    email TEXT,
    nombre_completo TEXT,
    telefono TEXT,
    rol TEXT,
    tutor_id UUID
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
        t.id as tutor_id
    FROM users u
    LEFT JOIN tutores t ON t.user_id = u.id
    WHERE u.auth_user_id = auth.uid();
END;
$$;

-- ============================================================================
-- FUNCIÓN: Obtener mis mascotas (para tutores)
-- Evita el problema de RLS al hacer la query internamente
-- ============================================================================
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
    -- Obtener tutor_id del usuario actual
    v_tutor_id := get_current_tutor_id();

    -- Retornar mascotas del tutor
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

-- ============================================================================
-- FUNCIÓN: Obtener mis citas (para tutores)
-- ============================================================================
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
    profesional_nombre TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
    v_tutor_id UUID;
BEGIN
    -- Obtener tutor_id del usuario actual
    v_tutor_id := get_current_tutor_id();

    -- Retornar citas del tutor con datos relacionados
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
        u.nombre_completo as profesional_nombre
    FROM citas c
    INNER JOIN mascotas m ON c.mascota_id = m.id
    INNER JOIN servicios s ON c.servicio_id = s.id
    INNER JOIN profesionales p ON c.profesional_id = p.id
    INNER JOIN users u ON p.user_id = u.id
    WHERE c.tutor_id = v_tutor_id
      AND c.deleted_at IS NULL
    ORDER BY c.fecha_hora DESC;
END;
$$;

-- ============================================================================
-- FUNCIÓN: Crear mascota (para tutores)
-- ============================================================================
CREATE OR REPLACE FUNCTION create_mascota(
    p_nombre TEXT,
    p_especie TEXT,
    p_raza TEXT DEFAULT NULL,
    p_sexo TEXT DEFAULT NULL,
    p_fecha_nacimiento DATE DEFAULT NULL,
    p_peso_kg NUMERIC DEFAULT NULL,
    p_color TEXT DEFAULT NULL,
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
    -- Obtener tutor_id del usuario actual
    v_tutor_id := get_current_tutor_id();

    -- Insertar mascota
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
        foto_url,
        estado,
        alergias,
        condiciones_preexistentes,
        esterilizado,
        activo
    ) VALUES (
        v_tutor_id,
        p_nombre,
        p_especie,
        p_raza,
        p_sexo,
        p_fecha_nacimiento,
        p_peso_kg,
        p_color,
        p_microchip,
        p_foto_url,
        'pendiente',
        p_alergias,
        p_condiciones_preexistentes,
        p_esterilizado,
        TRUE
    )
    RETURNING id INTO v_mascota_id;

    RETURN v_mascota_id;
END;
$$;

-- ============================================================================
-- FUNCIÓN: Crear cita (para tutores)
-- ============================================================================
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
    -- Obtener tutor_id del usuario actual
    v_tutor_id := get_current_tutor_id();

    -- Verificar que la mascota pertenece al tutor
    IF NOT EXISTS (
        SELECT 1 FROM mascotas
        WHERE id = p_mascota_id
        AND tutor_id = v_tutor_id
    ) THEN
        RAISE EXCEPTION 'La mascota no pertenece a este tutor';
    END IF;

    -- Obtener duración del servicio
    SELECT duracion_minutos INTO v_duracion
    FROM servicios
    WHERE id = p_servicio_id;

    -- Calcular fecha_hora_fin
    v_fecha_hora_fin := p_fecha_hora + (v_duracion || ' minutes')::INTERVAL;

    -- Insertar cita
    INSERT INTO citas (
        mascota_id,
        tutor_id,
        servicio_id,
        profesional_id,
        fecha_hora,
        fecha_hora_fin,
        estado,
        motivo_consulta
    ) VALUES (
        p_mascota_id,
        v_tutor_id,
        p_servicio_id,
        p_profesional_id,
        p_fecha_hora,
        v_fecha_hora_fin,
        'reservada',
        p_motivo_consulta
    )
    RETURNING id INTO v_cita_id;

    RETURN v_cita_id;
END;
$$;

-- ============================================================================
-- OTORGAR PERMISOS DE EJECUCIÓN
-- ============================================================================

-- Permitir que usuarios autenticados ejecuten estas funciones
GRANT EXECUTE ON FUNCTION get_current_tutor_id() TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_user_data() TO authenticated;
GRANT EXECUTE ON FUNCTION get_my_mascotas() TO authenticated;
GRANT EXECUTE ON FUNCTION get_my_citas() TO authenticated;
GRANT EXECUTE ON FUNCTION create_mascota TO authenticated;
GRANT EXECUTE ON FUNCTION create_cita TO authenticated;

-- También para anon (si es necesario para registro)
GRANT EXECUTE ON FUNCTION get_current_tutor_id() TO anon;
GRANT EXECUTE ON FUNCTION get_current_user_data() TO anon;

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

SELECT 'Funciones SQL seguras creadas exitosamente' AS status;
