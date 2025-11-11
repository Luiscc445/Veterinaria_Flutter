// Modelo de Usuario (Arquitectura MVC)
// Representa usuarios del sistema integrados con Supabase Auth

export type RolUsuario = 'admin' | 'medico' | 'recepcion' | 'tutor'

export interface User {
  id: string
  auth_user_id: string
  email: string
  nombre_completo: string
  telefono?: string
  rol: RolUsuario
  avatar_url?: string
  activo: boolean
  ultimo_acceso?: string
  created_at: string
  updated_at: string
  deleted_at?: string
}

export interface UserFormData {
  email: string
  nombre_completo: string
  telefono?: string
  rol: RolUsuario
  avatar_url?: string
}

export interface UserUpdateData {
  nombre_completo?: string
  telefono?: string
  avatar_url?: string
  activo?: boolean
}
