-- ============================================================================
-- FIX: Función de auditoría para manejar creación desde cliente admin
-- ============================================================================
--
-- PROBLEMA:
-- Cuando se crea un usuario desde el cliente admin (service_role_key),
-- auth.uid() retorna el UUID del cliente admin, NO del usuario que se crea.
-- Ese UUID no existe en la tabla users, causando error de foreign key.
--
-- SOLUCIÓN:
-- Modificar la función registrar_auditoria() para que:
-- 1. Busque el ID del usuario en la tabla users que corresponda al auth.uid()
-- 2. Si no existe, use NULL (permitido en la columna usuario_id)
-- ============================================================================

CREATE OR REPLACE FUNCTION registrar_auditoria()
RETURNS TRIGGER AS $$
DECLARE
    registro_id UUID;
    datos_anteriores JSONB;
    datos_nuevos JSONB;
    v_usuario_id UUID;
BEGIN
    -- Determinar el ID del registro
    IF TG_OP = 'DELETE' THEN
        registro_id := OLD.id;
        datos_anteriores := row_to_json(OLD)::JSONB;
        datos_nuevos := NULL;
    ELSE
        registro_id := NEW.id;
        datos_anteriores := CASE WHEN TG_OP = 'UPDATE' THEN row_to_json(OLD)::JSONB ELSE NULL END;
        datos_nuevos := row_to_json(NEW)::JSONB;
    END IF;

    -- Buscar el usuario_id en la tabla users que corresponda al auth_user_id actual
    -- Si no existe (ej: operación desde service_role), usar NULL
    BEGIN
        SELECT id INTO v_usuario_id
        FROM users
        WHERE auth_user_id = auth.uid();
    EXCEPTION WHEN OTHERS THEN
        v_usuario_id := NULL;
    END;

    -- Si no se encontró por auth_user_id y estamos en la tabla users,
    -- usar el id del nuevo registro como usuario_id
    IF v_usuario_id IS NULL AND TG_TABLE_NAME = 'users' AND TG_OP IN ('INSERT', 'UPDATE') THEN
        v_usuario_id := NEW.id;
    END IF;

    -- Insertar en auditoría (con manejo de errores para evitar que falle la operación principal)
    BEGIN
        INSERT INTO auditoria (tabla, registro_id, accion, usuario_id, datos_anteriores, datos_nuevos)
        VALUES (
            TG_TABLE_NAME,
            registro_id,
            TG_OP,
            v_usuario_id, -- Usar el usuario_id encontrado o NULL
            datos_anteriores,
            datos_nuevos
        );
    EXCEPTION WHEN foreign_key_violation THEN
        -- Si aún falla por foreign key, insertar con NULL
        INSERT INTO auditoria (tabla, registro_id, accion, usuario_id, datos_anteriores, datos_nuevos)
        VALUES (
            TG_TABLE_NAME,
            registro_id,
            TG_OP,
            NULL, -- Usar NULL si hay conflicto de foreign key
            datos_anteriores,
            datos_nuevos
        );
    END;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentario actualizado
COMMENT ON FUNCTION registrar_auditoria() IS 'Función de trigger para registrar todas las operaciones en la tabla de auditoría. Maneja correctamente operaciones desde service_role_key.';
