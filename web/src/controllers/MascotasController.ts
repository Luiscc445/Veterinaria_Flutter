// Controlador de Mascotas (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type { Mascota } from '../models/Mascota'

export class MascotasController {
  /**
   * Obtener todas las mascotas
   * IMPORTANTE: Para admin/recepción - acceso completo
   */
  static async getAll(filtro?: 'all' | 'pendiente' | 'aprobado'): Promise<Mascota[]> {
    try {
      let query = supabase
        .from('mascotas')
        .select('*')
        .is('deleted_at', null)
        .order('created_at', { ascending: false })

      if (filtro && filtro !== 'all') {
        query = query.eq('estado', filtro)
      }

      const { data, error } = await query

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Error en MascotasController.getAll:', error)
      throw error
    }
  }

  /**
   * Aprobar una mascota pendiente
   */
  static async aprobar(id: string): Promise<void> {
    try {
      const { data: currentUser } = await supabase.auth.getUser()
      if (!currentUser?.user?.id) throw new Error('Usuario no autenticado')

      // Obtener user_id del auth_user_id
      const { data: userData } = await supabase
        .from('users')
        .select('id')
        .eq('auth_user_id', currentUser.user.id)
        .single()

      if (!userData) throw new Error('Usuario no encontrado')

      const { error } = await supabase
        .from('mascotas')
        .update({
          estado: 'aprobado',
          fecha_aprobacion: new Date().toISOString(),
          aprobado_por: userData.id
        })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en MascotasController.aprobar:', error)
      throw error
    }
  }

  /**
   * Rechazar una mascota pendiente
   */
  static async rechazar(id: string, motivo?: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('mascotas')
        .update({
          estado: 'rechazado',
          motivo_rechazo: motivo
        })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en MascotasController.rechazar:', error)
      throw error
    }
  }

  /**
   * Obtener estadísticas de mascotas
   */
  static async getStats(): Promise<{
    total: number
    pendientes: number
    aprobadas: number
    rechazadas: number
  }> {
    try {
      const [total, pendientes, aprobadas, rechazadas] = await Promise.all([
        supabase.from('mascotas').select('id', { count: 'exact' }).is('deleted_at', null),
        supabase.from('mascotas').select('id', { count: 'exact' }).eq('estado', 'pendiente').is('deleted_at', null),
        supabase.from('mascotas').select('id', { count: 'exact' }).eq('estado', 'aprobado').is('deleted_at', null),
        supabase.from('mascotas').select('id', { count: 'exact' }).eq('estado', 'rechazado').is('deleted_at', null),
      ])

      return {
        total: total.count || 0,
        pendientes: pendientes.count || 0,
        aprobadas: aprobadas.count || 0,
        rechazadas: rechazadas.count || 0,
      }
    } catch (error) {
      console.error('Error en MascotasController.getStats:', error)
      throw error
    }
  }
}
