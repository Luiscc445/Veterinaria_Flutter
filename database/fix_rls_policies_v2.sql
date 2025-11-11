-- ============================================================================
-- SCRIPT DE CORRECCIÓN DE POLÍTICAS RLS - VERSION 2
-- Elimina TODAS las políticas existentes y recrea desde cero
-- ============================================================================

-- ============================================================================
-- PASO 1: ELIMINAR TODAS LAS POLÍTICAS EXISTENTES (SIN IMPORTAR EL NOMBRE)
-- ============================================================================

DO $$
DECLARE
    policy_record RECORD;
BEGIN
    -- Eliminar todas las políticas de users
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'users'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON users', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de tutores
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'tutores'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON tutores', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de mascotas
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'mascotas'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON mascotas', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de citas
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'citas'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON citas', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de historias_clinicas
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'historias_clinicas'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON historias_clinicas', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de episodios
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'episodios'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON episodios', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de servicios
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'servicios'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON servicios', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de profesionales
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'profesionales'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON profesionales', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de consultorios
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'consultorios'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON consultorios', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de farmacos
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'farmacos'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON farmacos', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de lotes_farmacos
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'lotes_farmacos'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON lotes_farmacos', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de consumos_farmacos
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'consumos_farmacos'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON consumos_farmacos', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de inventario_movimientos
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'inventario_movimientos'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON inventario_movimientos', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de adjuntos
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'adjuntos'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON adjuntos', policy_record.policyname);
    END LOOP;

    -- Eliminar todas las políticas de auditoria
    FOR policy_record IN
        SELECT policyname FROM pg_policies WHERE tablename = 'auditoria'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON auditoria', policy_record.policyname);
    END LOOP;
END $$;

-- ============================================================================
-- PASO 2: CREAR FUNCIONES HELPER (ELIMINAR SI EXISTEN)
-- ============================================================================

DROP FUNCTION IF EXISTS get_user_rol();
DROP FUNCTION IF EXISTS get_user_id_from_auth();
DROP FUNCTION IF EXISTS sync_user_rol_to_jwt();

-- Función para obtener el rol del usuario actual desde JWT metadata
CREATE OR REPLACE FUNCTION get_user_rol()
RETURNS TEXT AS $$
BEGIN
    RETURN COALESCE(
        auth.jwt()->>'rol',
        (auth.jwt()->'user_metadata'->>'rol'),
        'tutor'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Función para obtener el user_id (UUID) del usuario actual
CREATE OR REPLACE FUNCTION get_user_id_from_auth()
RETURNS UUID AS $$
BEGIN
    RETURN auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Función para sincronizar el rol del usuario al JWT metadata
CREATE OR REPLACE FUNCTION sync_user_rol_to_jwt()
RETURNS TRIGGER AS $$
BEGIN
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
-- PASO 3: CREAR POLÍTICAS RLS NUEVAS
-- ============================================================================

-- USERS
CREATE POLICY "users_select_own" ON users FOR SELECT
USING (auth_user_id = get_user_id_from_auth());

CREATE POLICY "users_update_own" ON users FOR UPDATE
USING (auth_user_id = get_user_id_from_auth())
WITH CHECK (
    auth_user_id = get_user_id_from_auth() AND
    rol = (SELECT rol FROM users WHERE auth_user_id = get_user_id_from_auth())
);

CREATE POLICY "users_admin_all" ON users FOR ALL
USING (get_user_rol() = 'admin');

-- TUTORES
CREATE POLICY "tutores_select_own" ON tutores FOR SELECT
USING (
    user_id IN (
        SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
    )
);

CREATE POLICY "tutores_insert_own" ON tutores FOR INSERT
WITH CHECK (
    user_id IN (
        SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
    )
);

CREATE POLICY "tutores_update_own" ON tutores FOR UPDATE
USING (
    user_id IN (
        SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
    )
);

CREATE POLICY "tutores_admin_recepcion_all" ON tutores FOR ALL
USING (get_user_rol() IN ('admin', 'recepcion'));

CREATE POLICY "tutores_medicos_select_pacientes" ON tutores FOR SELECT
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

-- MASCOTAS
CREATE POLICY "mascotas_tutores_select_own" ON mascotas FOR SELECT
USING (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

CREATE POLICY "mascotas_tutores_insert" ON mascotas FOR INSERT
WITH CHECK (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

CREATE POLICY "mascotas_tutores_update_pendientes" ON mascotas FOR UPDATE
USING (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
    AND estado = 'pendiente'
);

CREATE POLICY "mascotas_admin_recepcion_all" ON mascotas FOR ALL
USING (get_user_rol() IN ('admin', 'recepcion'));

CREATE POLICY "mascotas_medicos_select_citas" ON mascotas FOR SELECT
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

-- CITAS
CREATE POLICY "citas_tutores_select_own" ON citas FOR SELECT
USING (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

CREATE POLICY "citas_tutores_insert" ON citas FOR INSERT
WITH CHECK (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

CREATE POLICY "citas_tutores_update_cancelar" ON citas FOR UPDATE
USING (
    tutor_id IN (
        SELECT t.id FROM tutores t
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
    AND estado NOT IN ('atendida')
)
WITH CHECK (estado = 'cancelada');

CREATE POLICY "citas_admin_recepcion_all" ON citas FOR ALL
USING (get_user_rol() IN ('admin', 'recepcion'));

CREATE POLICY "citas_medicos_select_asignadas" ON citas FOR SELECT
USING (
    get_user_rol() = 'medico' AND
    profesional_id IN (
        SELECT p.id FROM profesionales p
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
    )
);

CREATE POLICY "citas_medicos_update_asignadas" ON citas FOR UPDATE
USING (
    get_user_rol() = 'medico' AND
    profesional_id IN (
        SELECT p.id FROM profesionales p
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
    )
);

-- HISTORIAS CLINICAS
CREATE POLICY "historias_tutores_select_mascotas" ON historias_clinicas FOR SELECT
USING (
    mascota_id IN (
        SELECT m.id FROM mascotas m
        INNER JOIN tutores t ON m.tutor_id = t.id
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

CREATE POLICY "historias_admin_all" ON historias_clinicas FOR ALL
USING (get_user_rol() = 'admin');

CREATE POLICY "historias_medicos_all_pacientes" ON historias_clinicas FOR ALL
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

-- EPISODIOS
CREATE POLICY "episodios_tutores_select_mascotas" ON episodios FOR SELECT
USING (
    historia_clinica_id IN (
        SELECT hc.id FROM historias_clinicas hc
        INNER JOIN mascotas m ON hc.mascota_id = m.id
        INNER JOIN tutores t ON m.tutor_id = t.id
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

CREATE POLICY "episodios_admin_all" ON episodios FOR ALL
USING (get_user_rol() = 'admin');

CREATE POLICY "episodios_medicos_all_propios" ON episodios FOR ALL
USING (
    get_user_rol() = 'medico' AND
    profesional_id IN (
        SELECT p.id FROM profesionales p
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
    )
);

-- SERVICIOS
CREATE POLICY "servicios_select_autenticados" ON servicios FOR SELECT
USING (get_user_id_from_auth() IS NOT NULL AND activo = TRUE);

CREATE POLICY "servicios_admin_all" ON servicios FOR ALL
USING (get_user_rol() = 'admin');

-- PROFESIONALES
CREATE POLICY "profesionales_select_autenticados" ON profesionales FOR SELECT
USING (get_user_id_from_auth() IS NOT NULL AND activo = TRUE);

CREATE POLICY "profesionales_admin_all" ON profesionales FOR ALL
USING (get_user_rol() = 'admin');

-- CONSULTORIOS
CREATE POLICY "consultorios_select_autenticados" ON consultorios FOR SELECT
USING (get_user_id_from_auth() IS NOT NULL);

CREATE POLICY "consultorios_admin_recepcion_all" ON consultorios FOR ALL
USING (get_user_rol() IN ('admin', 'recepcion'));

-- FARMACOS
CREATE POLICY "farmacos_select_autenticados" ON farmacos FOR SELECT
USING (get_user_id_from_auth() IS NOT NULL);

CREATE POLICY "farmacos_admin_all" ON farmacos FOR ALL
USING (get_user_rol() = 'admin');

-- LOTES FARMACOS
CREATE POLICY "lotes_select_autenticados" ON lotes_farmacos FOR SELECT
USING (get_user_id_from_auth() IS NOT NULL);

CREATE POLICY "lotes_admin_all" ON lotes_farmacos FOR ALL
USING (get_user_rol() = 'admin');

-- CONSUMOS FARMACOS
CREATE POLICY "consumos_medicos_insert" ON consumos_farmacos FOR INSERT
WITH CHECK (
    get_user_rol() = 'medico' AND
    prescrito_por IN (
        SELECT p.id FROM profesionales p
        WHERE p.user_id IN (
            SELECT id FROM users WHERE auth_user_id = get_user_id_from_auth()
        )
    )
);

CREATE POLICY "consumos_admin_medicos_select" ON consumos_farmacos FOR SELECT
USING (get_user_rol() IN ('admin', 'medico'));

CREATE POLICY "consumos_tutores_select_mascotas" ON consumos_farmacos FOR SELECT
USING (
    mascota_id IN (
        SELECT m.id FROM mascotas m
        INNER JOIN tutores t ON m.tutor_id = t.id
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

-- INVENTARIO MOVIMIENTOS
CREATE POLICY "inventario_movimientos_admin_select" ON inventario_movimientos FOR SELECT
USING (get_user_rol() = 'admin');

-- ADJUNTOS
CREATE POLICY "adjuntos_admin_all" ON adjuntos FOR ALL
USING (get_user_rol() = 'admin');

CREATE POLICY "adjuntos_tutores_select_mascotas" ON adjuntos FOR SELECT
USING (
    mascota_id IN (
        SELECT m.id FROM mascotas m
        INNER JOIN tutores t ON m.tutor_id = t.id
        INNER JOIN users u ON t.user_id = u.id
        WHERE u.auth_user_id = get_user_id_from_auth()
    )
);

CREATE POLICY "adjuntos_medicos_all_episodios" ON adjuntos FOR ALL
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

-- AUDITORIA
CREATE POLICY "auditoria_admin_select" ON auditoria FOR SELECT
USING (get_user_rol() = 'admin');

-- ============================================================================
-- PASO 4: SINCRONIZAR USUARIOS EXISTENTES CON JWT
-- ============================================================================

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

SELECT 'Script RLS V2 ejecutado exitosamente - Todas las políticas recreadas' AS status;
