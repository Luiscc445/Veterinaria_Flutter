import { createClient, SupabaseClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseServiceRoleKey = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY

let supabaseAdmin: SupabaseClient | null = null

// Solo crear cliente admin si la service role key está configurada
if (supabaseUrl && supabaseServiceRoleKey) {
  supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  })

  console.warn(
    '⚠️ ADVERTENCIA: Cliente Admin de Supabase está activo.\n' +
    'El Service Role Key da acceso completo a la base de datos.\n' +
    'Asegúrate de que esta aplicación NO sea accesible públicamente.'
  )
}

/**
 * Verifica si el cliente admin está disponible
 */
export const isAdminClientAvailable = (): boolean => {
  return supabaseAdmin !== null
}

/**
 * Obtiene el cliente admin si está disponible
 * Lanza un error si no está configurado
 */
export const getAdminClient = (): SupabaseClient => {
  if (!supabaseAdmin) {
    throw new Error(
      'Cliente Admin no configurado. ' +
      'Agrega VITE_SUPABASE_SERVICE_ROLE_KEY en tu archivo .env ' +
      'o usa el método alternativo de recuperación de contraseña.'
    )
  }
  return supabaseAdmin
}

/**
 * Actualiza la contraseña de un usuario (solo admin)
 * @param userId - ID del usuario en auth.users
 * @param newPassword - Nueva contraseña
 */
export const updateUserPassword = async (
  userId: string,
  newPassword: string
): Promise<{ success: boolean; error?: string }> => {
  try {
    if (!supabaseAdmin) {
      return {
        success: false,
        error: 'Cliente Admin no está configurado. Configura VITE_SUPABASE_SERVICE_ROLE_KEY en .env'
      }
    }

    const { error } = await supabaseAdmin.auth.admin.updateUserById(userId, {
      password: newPassword
    })

    if (error) {
      return {
        success: false,
        error: error.message
      }
    }

    return { success: true }
  } catch (error: any) {
    return {
      success: false,
      error: error.message || 'Error desconocido'
    }
  }
}

/**
 * Crea un nuevo usuario usando el cliente admin (solo admin)
 * @param email - Email del usuario
 * @param password - Contraseña
 * @param metadata - Metadata adicional del usuario
 */
export const createUser = async (
  email: string,
  password: string,
  metadata?: { nombre_completo?: string }
): Promise<{ success: boolean; userId?: string; error?: string }> => {
  try {
    if (!supabaseAdmin) {
      return {
        success: false,
        error: 'Cliente Admin no está configurado. Configura VITE_SUPABASE_SERVICE_ROLE_KEY en .env'
      }
    }

    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true, // Auto-confirmar el email
      user_metadata: metadata || {}
    })

    if (error) {
      return {
        success: false,
        error: error.message
      }
    }

    if (!data.user) {
      return {
        success: false,
        error: 'No se pudo crear el usuario'
      }
    }

    return {
      success: true,
      userId: data.user.id
    }
  } catch (error: any) {
    return {
      success: false,
      error: error.message || 'Error desconocido'
    }
  }
}

export { supabaseAdmin }
