-- Función para crear usuarios desde el dashboard admin
-- Esta función permite crear usuarios en auth.users y users de forma automática

CREATE OR REPLACE FUNCTION crear_usuario_admin(
  p_email TEXT,
  p_password TEXT,
  p_nombre_completo TEXT,
  p_telefono TEXT,
  p_rol TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_auth_user_id UUID;
  v_user_id UUID;
  v_result JSON;
BEGIN
  -- Validar que el usuario que ejecuta sea admin
  IF NOT EXISTS (
    SELECT 1 FROM users
    WHERE auth_user_id = auth.uid()
    AND rol = 'admin'
  ) THEN
    RAISE EXCEPTION 'Solo administradores pueden crear usuarios';
  END IF;

  -- Crear usuario en auth.users usando la extensión auth
  -- Nota: Esto requiere que la función tenga permisos SECURITY DEFINER
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    p_email,
    crypt(p_password, gen_salt('bf')),
    NOW(),
    '{"provider":"email","providers":["email"]}',
    jsonb_build_object('nombre_completo', p_nombre_completo),
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
  )
  RETURNING id INTO v_auth_user_id;

  -- Crear usuario en la tabla users
  INSERT INTO users (
    auth_user_id,
    email,
    nombre_completo,
    telefono,
    rol,
    activo
  ) VALUES (
    v_auth_user_id,
    p_email,
    p_nombre_completo,
    p_telefono,
    p_rol,
    TRUE
  )
  RETURNING id INTO v_user_id;

  -- Retornar resultado
  v_result := json_build_object(
    'success', TRUE,
    'auth_user_id', v_auth_user_id,
    'user_id', v_user_id,
    'email', p_email
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
GRANT EXECUTE ON FUNCTION crear_usuario_admin(TEXT, TEXT, TEXT, TEXT, TEXT) TO authenticated;

-- Comentario
COMMENT ON FUNCTION crear_usuario_admin IS 'Crea un usuario en auth.users y users desde el dashboard admin. Solo ejecutable por administradores.';
