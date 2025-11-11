// Controlador de Usuarios (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type { User, UserFormData, UserUpdateData } from '../models/User'

export class UsersController {
  /**
   * Obtener todos los usuarios
   */
  static async getAll(filtroRol?: string): Promise<User[]> {
    try {
      let query = supabase
        .from('users')
        .select('*')
        .is('deleted_at', null)
        .order('created_at', { ascending: false })

      if (filtroRol && filtroRol !== 'all') {
        query = query.eq('rol', filtroRol)
      }

      const { data, error } = await query
      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Error en UsersController.getAll:', error)
      throw error
    }
  }

  /**
   * Obtener un usuario por ID
   */
  static async getById(id: string): Promise<User | null> {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', id)
        .is('deleted_at', null)
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Error en UsersController.getById:', error)
      throw error
    }
  }

  /**
   * Obtener usuario actual autenticado
   */
  static async getCurrentUser(): Promise<User | null> {
    try {
      const { data: authData } = await supabase.auth.getUser()
      if (!authData?.user?.id) return null

      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('auth_user_id', authData.user.id)
        .is('deleted_at', null)
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Error en UsersController.getCurrentUser:', error)
      return null
    }
  }

  /**
   * Actualizar usuario
   */
  static async update(id: string, data: UserUpdateData): Promise<void> {
    try {
      const { error } = await supabase
        .from('users')
        .update(data)
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en UsersController.update:', error)
      throw error
    }
  }

  /**
   * Desactivar usuario (soft delete)
   */
  static async deactivate(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('users')
        .update({ activo: false })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en UsersController.deactivate:', error)
      throw error
    }
  }

  /**
   * Activar usuario
   */
  static async activate(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('users')
        .update({ activo: true })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en UsersController.activate:', error)
      throw error
    }
  }

  /**
   * Obtener estadísticas de usuarios
   */
  static async getStats(): Promise<{
    total: number
    admins: number
    medicos: number
    recepcion: number
    tutores: number
    activos: number
  }> {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('rol, activo')
        .is('deleted_at', null)

      if (error) throw error

      const stats = {
        total: data.length,
        admins: data.filter((u) => u.rol === 'admin').length,
        medicos: data.filter((u) => u.rol === 'medico').length,
        recepcion: data.filter((u) => u.rol === 'recepcion').length,
        tutores: data.filter((u) => u.rol === 'tutor').length,
        activos: data.filter((u) => u.activo).length,
      }

      return stats
    } catch (error) {
      console.error('Error en UsersController.getStats:', error)
      throw error
    }
  }
}
