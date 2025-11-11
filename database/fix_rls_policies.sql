-- ============================================================================
-- SCRIPT DE CORRECCIÓN DE POLÍTICAS RLS
-- Soluciona la recursión infinita y errores de permisos
-- ============================================================================
-- Fecha: Noviembre 2025
-- Base de Datos: PostgreSQL (Supabase)
-- ============================================================================

-- ============================================================================
-- PASO 1: ELIMINAR TODAS LAS POLÍTICAS DEFECTUOSAS
-- ============================================================================

-- Eliminar políticas de users
DROP POLICY IF EXISTS "Admin acceso total a users" ON users;
DROP POLICY IF EXISTS "Usuarios ven su perfil" ON users;
DROP POLICY IF EXISTS "Usuarios actualizan su perfil" ON users;

-- Eliminar políticas de tutores
DROP POLICY IF EXISTS "Admin y recepción acceso total a tutores" ON tutores;
DROP POLICY IF EXISTS "Tutores ven su registro" ON tutores;
DROP POLICY IF EXISTS "Tutores actualizan su registro" ON tutores;
DROP POLICY IF EXISTS "Médicos ven tutores de pacientes" ON tutores;

-- Eliminar políticas de mascotas
DROP POLICY IF EXISTS "Admin y recepción acceso total a mascotas" ON mascotas;
DROP POLICY IF EXISTS "Tutores ven sus mascotas" ON mascotas;
DROP POLICY IF EXISTS "Tutores crean mascotas" ON mascotas;
DROP POLICY IF EXISTS "Tutores actualizan sus mascotas" ON mascotas;
DROP POLICY IF EXISTS "Médicos ven mascotas de sus citas" ON mascotas;

-- Eliminar políticas de citas
DROP POLICY IF EXISTS "Admin y recepción acceso total a citas" ON citas;
DROP POLICY IF EXISTS "Tutores ven sus citas" ON citas;
DROP POLICY IF EXISTS "Tutores crean citas" ON citas;
DROP POLICY IF EXISTS "Tutores cancelan sus citas" ON citas;
DROP POLICY IF EXISTS "Médicos ven sus citas" ON citas;
DROP POLICY IF EXISTS "Médicos actualizan sus citas" ON citas;

-- Eliminar políticas de historias clínicas y episodios
DROP POLICY IF EXISTS "Admin acceso total a historias" ON historias_clinicas;
DROP POLICY IF EXISTS "Tutores ven historias de sus mascotas" ON historias_clinicas;
DROP POLICY IF EXISTS "Médicos acceso a historias de sus pacientes" ON historias_clinicas;
DROP POLICY IF EXISTS "Admin acceso total a episodios" ON episodios;
DROP POLICY IF EXISTS "Tutores ven episodios de sus mascotas" ON episodios;
DROP POLICY IF EXISTS "Médicos gestionan sus episodios" ON episodios;

-- Eliminar políticas de inventario
DROP POLICY IF EXISTS "Autenticados ven fármacos" ON farmacos;
DROP POLICY IF EXISTS "Solo admin gestiona fármacos" ON farmacos;
DROP POLICY IF EXISTS "Autenticados ven lotes" ON lotes_farmacos;
DROP POLICY IF EXISTS "Solo admin gestiona lotes" ON lotes_farmacos;
DROP POLICY IF EXISTS "Médicos crean consumos" ON consumos_farmacos;
DROP POLICY IF EXISTS "Admin ve todos los consumos" ON consumos_farmacos;
DROP POLICY IF EXISTS "Tutores ven consumos de sus mascotas" ON consumos_farmacos;

-- Eliminar políticas de auditoría
DROP POLICY IF EXISTS "Solo admin ve auditoría" ON auditoria;

-- Eliminar políticas de servicios, profesionales, consultorios
DROP POLICY IF EXISTS "Autenticados ven servicios" ON servicios;
DROP POLICY IF EXISTS "Solo admin gestiona servicios" ON servicios;
DROP POLICY IF EXISTS "Autenticados ven profesionales" ON profesionales;
DROP POLICY IF EXISTS "Solo admin gestiona profesionales" ON profesionales;
DROP POLICY IF EXISTS "Autenticados ven consultorios" ON consultorios;
DROP POLICY IF EXISTS "Admin y recepción gestionan consultorios" ON consultorios;

-- Eliminar políticas de adjuntos
DROP POLICY IF EXISTS "Admin acceso total a adjuntos" ON adjuntos;
DROP POLICY IF EXISTS "Tutores ven adjuntos de sus mascotas" ON adjuntos;
DROP POLICY IF EXISTS "Médicos gestionan adjuntos de sus episodios" ON adjuntos;

-- Eliminar políticas de inventario_movimientos
DROP POLICY IF EXISTS "Admin ve movimientos" ON inventario_movimientos;

-- ============================================================================
-- PASO 2: CREAR FUNCIONES HELPER (SIN RECURSIÓN)
-- ============================================================================

-- Función para obtener el rol del usuario actual desde JWT metadata
-- Esta función NO consulta la tabla users, evitando recursión infinita
CREATE OR REPLACE FUNCTION get_user_rol()
RETURNS TEXT AS $$
BEGIN
    -- Obtener el rol desde el JWT metadata (raw_app_meta_data)
    RETURN COALESCE(
        auth.jwt()->>'rol',
        (auth.jwt()->'user_metadata'->>'rol'),
        'tutor' -- Valor por defecto si no existe
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Función para obtener el user_id (UUID) del usuario actual
-- Convierte auth.uid() a UUID de forma segura
CREATE OR REPLACE FUNCTION get_user_id_from_auth()
RETURNS UUID AS $$
BEGIN
    RETURN auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Función para sincronizar el rol del usuario al JWT metadata
-- Se ejecuta automáticamente mediante trigger
CREATE OR REPLACE FUNCTION sync_user_rol_to_jwt()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar el metadata del JWT con el rol del usuario
    -- Esto permite que get_user_rol() obtenga el rol sin consultar users
    UPDATE auth.users
    SET raw_app_meta_data =
        COALESCE(raw_app_meta_data, '{}'::jsonb) ||
        jsonb_build_object('rol', NEW.rol)
    WHERE id = NEW.auth_user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para sincronizar rol al JWT automáticamente
DROP TRIGGER IF EXISTS trigger_sync_user_rol ON users;
CREATE TRIGGER trigger_sync_user_rol
    AFTER INSERT OR UPDATE OF rol ON users
    FOR EACH ROW
    EXECUTE FUNCTION sync_user_rol_to_jwt();

-- ============================================================================
-- PASO 3: CREAR POLÍTICAS RLS CORREGIDAS (SIN RECURSIÓN)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: users
-- ----------------------------------------------------------------------------

-- Usuarios pueden ver su propio perfil
CREATE POLICY "users_select_own"
ON users FOR SELECT
USING (auth_user_id = get_user_id_from_auth());

-- Usuarios pueden actualizar su propio perfil (excepto rol)
CREATE POLICY "users_update_own"
ON users FOR UPDATE
USING (auth_user_id = get_user_id_from_auth())
WITH CHECK (
    auth_user_id = get_user_id_from_auth() AND
    rol = (SELECT rol FROM users WHERE auth_user_id = get_user_id_from_auth())
);

-- Admin tiene acceso total
CREATE POLICY "users_admin_all"
ON users FOR ALL
USING (get_user_rol() = 'admin');

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: tutores
-- ----------------------------------------------------------------------------

-- Tutores pueden ver su propio registro
CREATE POLICY "tutores_select_own"
ON tutores FOR SELECT
USING (
    user_id IN (
        SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
    )
);

-- Tutores pueden crear su registro (INSERT solo cuando se registran)
CREATE POLICY "tutores_insert_own"
ON tutores FOR INSERT
WITH CHECK (
    user_id IN (
        SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
    )
);

-- Tutores pueden actualizar su propio registro
CREATE POLICY "tutores_update_own"
ON tutores FOR UPDATE
USING (
    user_id IN (
        SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
    )
);

-- Admin y recepción tienen acceso total
CREATE POLICY "tutores_admin_recepcion_all"
ON tutores FOR ALL
USING (get_user_rol() IN ('admin', 'recepcion'));

-- Médicos pueden ver tutores de sus pacientes (mascotas con citas asignadas)
CREATE POLICY "tutores_medicos_select_pacientes"
ON tutores FOR SELECT
USING (
    get_user_rol() = 'medico' AND
    EXISTS (
        SELECT 1 FROM profesionales p
        INNER JOIN citas c ON p.id = c.profesional_id
        INNER JOIN mascotas m ON c.mascota_id = m.id
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
        AND m.tutor_id = tutores.id
    )
);

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: mascotas
-- ----------------------------------------------------------------------------

-- Tutores pueden ver sus propias mascotas
CREATE POLICY "mascotas_tutores_select_own"
ON mascotas FOR SELECT
USING (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

-- Tutores pueden crear mascotas
CREATE POLICY "mascotas_tutores_insert"
ON mascotas FOR INSERT
WITH CHECK (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

-- Tutores pueden actualizar sus mascotas (solo si están pendientes)
CREATE POLICY "mascotas_tutores_update_pendientes"
ON mascotas FOR UPDATE
USING (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
    AND estado = 'pendiente'
);

-- Admin y recepción tienen acceso total
CREATE POLICY "mascotas_admin_recepcion_all"
ON mascotas FOR ALL
USING (get_user_rol() IN ('admin', 'recepcion'));

-- Médicos pueden ver mascotas de sus citas
CREATE POLICY "mascotas_medicos_select_citas"
ON mascotas FOR SELECT
USING (
    get_user_rol() = 'medico' AND
    EXISTS (
        SELECT 1 FROM citas c
        INNER JOIN profesionales p ON c.profesional_id = p.id
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
        AND c.mascota_id = mascotas.id
    )
);

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: citas
-- ----------------------------------------------------------------------------

-- Tutores pueden ver sus propias citas
CREATE POLICY "citas_tutores_select_own"
ON citas FOR SELECT
USING (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

-- Tutores pueden crear citas
CREATE POLICY "citas_tutores_insert"
ON citas FOR INSERT
WITH CHECK (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

-- Tutores pueden cancelar sus citas (solo si no están atendidas)
CREATE POLICY "citas_tutores_update_cancelar"
ON citas FOR UPDATE
USING (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
    AND estado NOT IN ('atendida')
)
WITH CHECK (estado = 'cancelada');

-- Admin y recepción tienen acceso total
CREATE POLICY "citas_admin_recepcion_all"
ON citas FOR ALL
USING (get_user_rol() IN ('admin', 'recepcion'));

-- Médicos pueden ver sus citas asignadas
CREATE POLICY "citas_medicos_select_asignadas"
ON citas FOR SELECT
USING (
    get_user_rol() = 'medico' AND
    profesional_id IN (
        SELECT p.id FROM profesionales p
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
    )
);

-- Médicos pueden actualizar sus citas asignadas
CREATE POLICY "citas_medicos_update_asignadas"
ON citas FOR UPDATE
USING (
    get_user_rol() = 'medico' AND
    profesional_id IN (
        SELECT p.id FROM profesionales p
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
    )
);

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: historias_clinicas
-- ----------------------------------------------------------------------------

-- Tutores pueden ver historias de sus mascotas
CREATE POLICY "historias_tutores_select_mascotas"
ON historias_clinicas FOR SELECT
USING (
    mascota_id IN (
        SELECT m.id FROM mascotas m
        INNER JOIN tutores t ON m.tutor_id = t.id
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

-- Admin tiene acceso total
CREATE POLICY "historias_admin_all"
ON historias_clinicas FOR ALL
USING (get_user_rol() = 'admin');

-- Médicos pueden ver y gestionar historias de sus pacientes
CREATE POLICY "historias_medicos_all_pacientes"
ON historias_clinicas FOR ALL
USING (
    get_user_rol() = 'medico' AND
    EXISTS (
        SELECT 1 FROM citas c
        INNER JOIN profesionales p ON c.profesional_id = p.id
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
        AND c.mascota_id = historias_clinicas.mascota_id
    )
);

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: episodios
-- ----------------------------------------------------------------------------

-- Tutores pueden ver episodios de sus mascotas
CREATE POLICY "episodios_tutores_select_mascotas"
ON episodios FOR SELECT
USING (
    historia_clinica_id IN (
        SELECT hc.id FROM historias_clinicas hc
        INNER JOIN mascotas m ON hc.mascota_id = m.id
        INNER JOIN tutores t ON m.tutor_id = t.id
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

-- Admin tiene acceso total
CREATE POLICY "episodios_admin_all"
ON episodios FOR ALL
USING (get_user_rol() = 'admin');

-- Médicos pueden gestionar sus episodios
CREATE POLICY "episodios_medicos_all_propios"
ON episodios FOR ALL
USING (
    get_user_rol() = 'medico' AND
    profesional_id IN (
        SELECT p.id FROM profesionales p
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
    )
);

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: servicios, profesionales, consultorios
-- ----------------------------------------------------------------------------

-- Todos los autenticados pueden ver servicios activos
CREATE POLICY "servicios_select_autenticados"
ON servicios FOR SELECT
USING (get_user_id_from_auth() IS NOT NULL AND activo = TRUE);

-- Solo admin puede gestionar servicios
CREATE POLICY "servicios_admin_all"
ON servicios FOR ALL
USING (get_user_rol() = 'admin');

-- Todos los autenticados pueden ver profesionales activos
CREATE POLICY "profesionales_select_autenticados"
ON profesionales FOR SELECT
USING (get_user_id_from_auth() IS NOT NULL AND activo = TRUE);

-- Solo admin puede gestionar profesionales
CREATE POLICY "profesionales_admin_all"
ON profesionales FOR ALL
USING (get_user_rol() = 'admin');

-- Todos los autenticados pueden ver consultorios
CREATE POLICY "consultorios_select_autenticados"
ON consultorios FOR SELECT
USING (get_user_id_from_auth() IS NOT NULL);

-- Admin y recepción pueden gestionar consultorios
CREATE POLICY "consultorios_admin_recepcion_all"
ON consultorios FOR ALL
USING (get_user_rol() IN ('admin', 'recepcion'));

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: farmacos y lotes_farmacos
-- ----------------------------------------------------------------------------

-- Todos los autenticados pueden ver fármacos
CREATE POLICY "farmacos_select_autenticados"
ON farmacos FOR SELECT
USING (get_user_id_from_auth() IS NOT NULL);

-- Solo admin puede gestionar fármacos
CREATE POLICY "farmacos_admin_all"
ON farmacos FOR ALL
USING (get_user_rol() = 'admin');

-- Todos los autenticados pueden ver lotes
CREATE POLICY "lotes_select_autenticados"
ON lotes_farmacos FOR SELECT
USING (get_user_id_from_auth() IS NOT NULL);

-- Solo admin puede gestionar lotes
CREATE POLICY "lotes_admin_all"
ON lotes_farmacos FOR ALL
USING (get_user_rol() = 'admin');

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: consumos_farmacos
-- ----------------------------------------------------------------------------

-- Médicos pueden crear consumos
CREATE POLICY "consumos_medicos_insert"
ON consumos_farmacos FOR INSERT
WITH CHECK (
    get_user_rol() = 'medico' AND
    prescrito_por IN (
        SELECT p.id FROM profesionales p
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
    )
);

-- Admin y médicos pueden ver todos los consumos
CREATE POLICY "consumos_admin_medicos_select"
ON consumos_farmacos FOR SELECT
USING (get_user_rol() IN ('admin', 'medico'));

-- Tutores pueden ver consumos de sus mascotas
CREATE POLICY "consumos_tutores_select_mascotas"
ON consumos_farmacos FOR SELECT
USING (
    mascota_id IN (
        SELECT m.id FROM mascotas m
        INNER JOIN tutores t ON m.tutor_id = t.id
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: inventario_movimientos
-- ----------------------------------------------------------------------------

-- Solo admin puede ver movimientos de inventario
CREATE POLICY "inventario_movimientos_admin_select"
ON inventario_movimientos FOR SELECT
USING (get_user_rol() = 'admin');

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: adjuntos
-- ----------------------------------------------------------------------------

-- Admin tiene acceso total
CREATE POLICY "adjuntos_admin_all"
ON adjuntos FOR ALL
USING (get_user_rol() = 'admin');

-- Tutores pueden ver adjuntos de sus mascotas
CREATE POLICY "adjuntos_tutores_select_mascotas"
ON adjuntos FOR SELECT
USING (
    mascota_id IN (
        SELECT m.id FROM mascotas m
        INNER JOIN tutores t ON m.tutor_id = t.id
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

-- Médicos pueden gestionar adjuntos de sus episodios
CREATE POLICY "adjuntos_medicos_all_episodios"
ON adjuntos FOR ALL
USING (
    get_user_rol() = 'medico' AND
    episodio_id IN (
        SELECT e.id FROM episodios e
        INNER JOIN profesionales p ON e.profesional_id = p.id
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
    )
);

-- ----------------------------------------------------------------------------
-- POLÍTICAS PARA: auditoria
-- ----------------------------------------------------------------------------

-- Solo admin puede ver auditoría
CREATE POLICY "auditoria_admin_select"
ON auditoria FOR SELECT
USING (get_user_rol() = 'admin');

-- ============================================================================
-- PASO 4: FUNCIÓN TRANSACCIONAL DE REGISTRO DE TUTORES
-- ============================================================================

-- Función para registrar un nuevo tutor (se llama desde el backend)
CREATE OR REPLACE FUNCTION registrar_tutor(
    p_email TEXT,
    p_password TEXT,
    p_nombre_completo TEXT,
    p_telefono TEXT DEFAULT NULL,
    p_dni TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_auth_user_id UUID;
    v_user_id UUID;
    v_tutor_id UUID;
    v_result JSON;
BEGIN
    -- Crear usuario en Supabase Auth
    -- NOTA: Esta función debe ser llamada desde el backend con privilegios de service_role
    -- ya que no podemos crear usuarios auth desde SQL directamente

    -- Insertar en tabla users
    INSERT INTO users (auth_user_id, email, nombre_completo, telefono, rol)
    VALUES (
        gen_random_uuid(), -- Temporal, será reemplazado por el real desde el backend
        p_email,
        p_nombre_completo,
        p_telefono,
        'tutor'
    )
    RETURNING id INTO v_user_id;

    -- Insertar en tabla tutores
    INSERT INTO tutores (user_id, dni)
    VALUES (v_user_id, p_dni)
    RETURNING id INTO v_tutor_id;

    -- Retornar resultado
    v_result := json_build_object(
        'success', true,
        'user_id', v_user_id,
        'tutor_id', v_tutor_id,
        'email', p_email
    );

    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PASO 5: ACTUALIZAR USUARIOS EXISTENTES CON ROL EN JWT
-- ============================================================================

-- Sincronizar todos los usuarios existentes con el JWT metadata
DO $$
DECLARE
    user_record RECORD;
BEGIN
    FOR user_record IN SELECT id, auth_user_id, rol FROM users WHERE auth_user_id IS NOT NULL
    LOOP
        UPDATE auth.users
        SET raw_app_meta_data =
            COALESCE(raw_app_meta_data, '{}'::jsonb) ||
            jsonb_build_object('rol', user_record.rol)
        WHERE id = user_record.auth_user_id;
    END LOOP;
END $$;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================

-- Verificar que todo funcione correctamente
SELECT 'Script de corrección RLS ejecutado exitosamente' AS status;
