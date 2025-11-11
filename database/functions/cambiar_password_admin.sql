-- Función para que el admin pueda cambiar contraseñas de usuarios
-- Esta función permite a los administradores cambiar contraseñas de otros usuarios

CREATE OR REPLACE FUNCTION cambiar_password_admin(
  p_user_email TEXT,
  p_nueva_password TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_auth_user_id UUID;
  v_result JSON;
BEGIN
  -- Validar que el usuario que ejecuta sea admin
  IF NOT EXISTS (
    SELECT 1 FROM users
    WHERE auth_user_id = auth.uid()
    AND rol = 'admin'
  ) THEN
    RAISE EXCEPTION 'Solo administradores pueden cambiar contraseñas';
  END IF;

  -- Obtener el auth_user_id del usuario a actualizar
  SELECT auth_user_id INTO v_auth_user_id
  FROM users
  WHERE email = p_user_email;

  IF v_auth_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuario no encontrado';
  END IF;

  -- Actualizar la contraseña en auth.users
  UPDATE auth.users
  SET
    encrypted_password = crypt(p_nueva_password, gen_salt('bf')),
    updated_at = NOW()
  WHERE id = v_auth_user_id;

  -- Retornar resultado exitoso
  v_result := json_build_object(
    'success', TRUE,
    'message', 'Contraseña actualizada exitosamente',
    'email', p_user_email
  );

  RETURN v_result;

EXCEPTION WHEN OTHERS THEN
  -- En caso de error, retornar información del error
  v_result := json_build_object(
    'success', FALSE,
    'error', SQLERRM
  );
  RETURN v_result;
END;
$$;

-- Dar permisos de ejecución a usuarios autenticados
GRANT EXECUTE ON FUNCTION cambiar_password_admin(TEXT, TEXT) TO authenticated;

-- Comentario
COMMENT ON FUNCTION cambiar_password_admin IS 'Permite a administradores cambiar contraseñas de usuarios. Solo ejecutable por admins.';
